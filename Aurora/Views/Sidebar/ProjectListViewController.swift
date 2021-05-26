//
// Aurora
// File created by Lea Baumgart on 26.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SnapKit
import SwiftKeychainWrapper
import SwiftUI
import UIKit

class ProjectListViewController: UIViewController {
    var projects = [CloudProjectInList]()

    var tableView: UITableView!
    var refreshControl: UIRefreshControl!

    override func viewWillAppear(_: Bool) {
        navigationItem.title = "Projects"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewProjectButton))
        navigationController?.isToolbarHidden = false
        toolbarItems = [UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))]
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(projectNotificationReceived), name: .init("ProjectArrayUpdatedNotification"), object: nil)
    }
    
    @objc func projectNotificationReceived(notification: Notification) {
        if let userInfo = notification.userInfo, userInfo["sender"] as? String == "projectlist" {
            // do nothing
        }
        else {
            projects = cloudAppSplitViewController.loadedProjects.map { CloudProjectInList($0) }
            for (index, _) in projects.enumerated() {
                self.projects[index].connectionError = false
                self.projects[index].didLoad = true
                self.projects[index].error = nil
            }
            self.projects.sort(by: { $0.project.name > $1.project.name })
            reloadTableView()
        }
    }

    @objc func openSettings() {
        let settingsController = SettingsController()
        let settingsViewHC = UIHostingController(rootView: SettingsView(controller: settingsController))
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewHC)
        settingsNavigationController.navigationBar.prefersLargeTitles = true
        present(settingsNavigationController, animated: true, completion: nil)
    }

    @objc func createNewProjectButton() {
        if cloudAppPreventNetworkActivityUseSampleData {
            EZAlertController.alert("Development mode active", message: "The app currently uses example data and doesn't communicate with the Hetzner Cloud API.\n\nIf you're a normal user, please report this issue immediately.\n\nIf you're a developer, change \"cloudAppPreventNetworkActivityUseSampleData\" inside \"SceneDelegate.swift\" to \"false\"")
            return
        }
        let createProjectAlert = UIAlertController(title: "New Project", message: "Please enter a name and an API key for the project here", preferredStyle: .alert)

        createProjectAlert.addTextField { textfield in
            textfield.placeholder = "Name"
            textfield.tag = 1
        }

        createProjectAlert.addTextField { textfield in
            textfield.placeholder = "API key"
            textfield.isSecureTextEntry = true
            textfield.tag = 2
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let nameTextField = createProjectAlert.textFields?.first(where: { $0.tag == 1 }) else { return }
            guard let apiTextField = createProjectAlert.textFields?.first(where: { $0.tag == 2 }) else { return }

            // If the following code doesn't run someone really fucked up

            let newProjectName = nameTextField.text ?? ""
            let newProjectAPIKey = apiTextField.text ?? ""

            if newProjectName == "" || newProjectAPIKey == "" {
                EZAlertController.alert("Error", message: "Please enter a name and an API key")
            } else {
                _ = CloudProject(name: newProjectName, apikey: newProjectAPIKey, persistentInstance: true) // is automatically saved and cached
                self.loadProjects()
            }
        }

        createProjectAlert.addAction(createAction)
        createProjectAlert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))

        present(createProjectAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView = UITableView(frame: view.frame, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProjectListCell.self, forCellReuseIdentifier: "projectCell")
        view.addSubview(tableView)

        refreshControl = .init()
        refreshControl.addTarget(self, action: #selector(loadProjects), for: .valueChanged)
        tableView.addSubview(refreshControl)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
        }

        loadProjects()
    }

    @objc func loadProjects() {
        projects = HCAppCache.default.loadProjects().map { CloudProjectInList($0) }
        reloadTableView()
        let dispatchGroup = DispatchGroup()
        cloudAppSplitViewController.loadedProjects.removeAll()
        for (index, project) in projects.enumerated() {
            dispatchGroup.enter()
            project.project.api!.loadProject { projectresponse in
                switch projectresponse {
                case let .success(networkproject):
                    cloudAppSplitViewController.loadedProjects.append(networkproject)
                    self.projects[index].project.api!.project = networkproject
                    self.projects[index].project = networkproject
                    self.projects[index].connectionError = false
                    self.projects[index].didLoad = true
                    self.projects[index].error = nil
                    dispatchGroup.leave()
                case let .failure(err):
                    // cloudAppSplitViewController.showError(err)
                    self.projects[index].connectionError = true
                    self.projects[index].didLoad = false
                    self.projects[index].error = err
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [self] in
            self.projects.sort(by: { $0.project.name > $1.project.name })
            NotificationCenter.default.post(name: Notification.Name("ProjectArrayUpdatedNotification"), object: nil, userInfo: ["sender": "projectlist"])
            reloadTableView()
            refreshControl.endRefreshing()
        }
    }

    func reloadTableView() {
        tableView.reloadData()

        // TOOD: Fix this

        /* if projects.isEmpty {
             tableView.setEmptyMessage(message: "No projects", subtitle: "Try adding a project by clicking the \"+\" button above")
         }
         else {
             tableView.restore()
         } */
    }

    func confirmProjectDeletion(_ project: CloudProject) {
        EZAlertController.alert("Delete Project?", message: "Are you sure you want to delete\"\(project.name)\"? This only deletes the project locally, not at Hetzner", actions: [UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            project.delete()
            self.loadProjects()
        }), UIAlertAction(title: "Cancel", style: .cancel, handler: nil)])
    }
}

extension ProjectListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedproject = projects[indexPath.row]

        if selectedproject.didLoad, !selectedproject.connectionError, selectedproject.error == nil {
            // finished loading
            let serverListVC = ServerListViewController()
            serverListVC.project = selectedproject.project
            if let collapsed = splitViewController?.isCollapsed, collapsed {
                navigationController?.pushViewController(serverListVC, animated: true)
            } else {
                splitViewController?.setViewController(UINavigationController(rootViewController: serverListVC), for: .supplementary)
            }
        } else if !selectedproject.didLoad && !selectedproject.connectionError && selectedproject.error == nil {
            // didn't load yet, chill
            EZAlertController.alert("Not loaded", message: "Please wait until all information was fetched from the API.")
        } else if !selectedproject.didLoad, selectedproject.connectionError, selectedproject.error != nil {
            cloudAppSplitViewController.showError(selectedproject.error!)
        } else {
            EZAlertController.alert("Error", message: "Something went wrong. Please contact the developers.")
        }
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmProjectDeletion(projects[indexPath.row].project)
        }
    }
}

extension ProjectListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return projects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell", for: indexPath) as! ProjectListCell
        cell.controller.project = projects[indexPath.row]
        return cell
    }
}

class ProjectListCell: UITableViewCell {
    var swiftuiView: UIView!
    var controller = ProjectListCellController()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        swiftuiView = UIHostingController(rootView: ProjectListCellView(controller: controller)).view
        swiftuiView.backgroundColor = .clear
        contentView.addSubview(swiftuiView)
        swiftuiView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.equalTo(contentView.snp.leading)
            make.bottom.equalTo(contentView.snp.bottom)
            make.trailing.equalTo(contentView.snp.trailing)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ProjectListCellView: View {
    @ObservedObject var controller: ProjectListCellController
    var body: some View {
        HStack {
            Image(systemName: "folder").resizable().aspectRatio(contentMode: .fit)
                .frame(width: 25).foregroundColor(.accentColor).padding(.trailing, 2)
            VStack(alignment: .leading) {
                Text("\(controller.project.project.name)").bold().font(.title3)
                Text("\(controller.project.project.servers.count) Server\(controller.project.project.servers.count == 1 ? "" : "s")").foregroundColor(.gray).font(.caption)
            }
            Spacer()
            if !controller.project.didLoad && !controller.project.connectionError {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            } else if controller.project.connectionError {
                Image(systemName: "bolt.circle").resizable().aspectRatio(contentMode: .fit).frame(width: 20).foregroundColor(.red)
            }
        }.padding()
    }
}

class ProjectListCellController: ObservableObject {
    @Published var project: CloudProjectInList = .init(.example)
}

struct ProjectListCellView_Preview: PreviewProvider {
    static var previews: some View {
        ProjectListCellView(controller: .init())
    }
}

struct CloudProjectInList {
    var didLoad: Bool = false
    var connectionError: Bool = false
    var error: HCAPIError?
    var project: CloudProject

    init(_ project: CloudProject) {
        self.project = project
        didLoad = false
        connectionError = false
        error = nil
    }
}
