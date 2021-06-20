//
// Aurora
// File created by Lea Baumgart on 27.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI
import UIKit

class ServerListViewController: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<ServerListSection, ServerListItem>!
    private var collectionView: UICollectionView!
    private var secondaryViewControllers: [UINavigationController] = [
        // .init(rootViewController: ProjectLoadBalancersViewController()),
        // .init(rootViewController: ProjectFloatingIPsViewController()),
        // .init(rootViewController: ProjectNetworksViewController()),
        // .init(rootViewController: ProjectFirewallsViewController()),
        .init(rootViewController: ProjectSecurityViewController()),
    ]

    public var project: CloudProject? {
        didSet {
            if collectionView != nil {
                configureDataSource()
            }
        }
    }

    @objc func projectNotificationReceived(notification: Notification) {
        if let userInfo = notification.userInfo, userInfo["sender"] as? String == "projectdetail" {
            // do nothing
        } else {
            if let projectFromArray = cloudAppSplitViewController.loadedProjects.first(where: { $0.id == project!.id }) {
                project = projectFromArray
            }
        }
    }

    var refreshControl: UIRefreshControl!

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
        navigationController?.isToolbarHidden = true
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(projectNotificationReceived), name: .init("ProjectArrayUpdatedNotification"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = project != nil ? project!.name : "unknown" // PROJECT NAME
        configureHierarchy()
        configureDataSource()
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            // config.headerMode = section == 0 ? .none : .firstItemInSection
            config.headerMode = .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        refreshControl = .init()
        refreshControl.addTarget(self, action: #selector(loadProject), for: .valueChanged)
        collectionView.addSubview(refreshControl)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.bottom.equalTo(view.snp.bottom)
            make.trailing.equalTo(view.snp.trailing)
        }
    }

    @objc func loadProject() {
        project!.api!.loadProject { [self] projectresponse in
            switch projectresponse {
            case let .success(networkproject):
                project = networkproject
                if let index = cloudAppSplitViewController.loadedProjects.firstIndex(where: { $0.id == project!.id }) {
                    cloudAppSplitViewController.loadedProjects[index] = project!
                } else {
                    cloudAppSplitViewController.loadedProjects.append(project!)
                }
                NotificationCenter.default.post(name: Notification.Name("ProjectArrayUpdatedNotification"), object: nil, userInfo: ["sender": "projectdetail"])
                refreshControl.endRefreshing()
            case let .failure(err):
                cloudAppSplitViewController.showError(err)
                refreshControl.endRefreshing()
            }
        }
    }

    func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ServerListItem> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            var allowDropdownArrow = true
            if let childcount = item.childcount {
                content.secondaryText = "\(childcount)"
                content.prefersSideBySideTextAndSecondaryText = true
                content.secondaryTextProperties.alignment = .center
                content.secondaryTextProperties.color = .secondaryLabel
                if childcount == 0 {
                    allowDropdownArrow = false
                }
            }
            cell.contentConfiguration = content
            if allowDropdownArrow {
                cell.accessories = [.outlineDisclosure()]
            } else {
                cell.accessories = []
            }
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ServerListItem> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.image
            cell.contentConfiguration = content
            cell.accessories = []
        }

        // Creating the datasource
        dataSource = UICollectionViewDiffableDataSource<ServerListSection, ServerListItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: ServerListItem) -> UICollectionViewCell? in
            if indexPath.item == 0 /* , indexPath.section != 0 */ {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }

        let sections: [ServerListSection] = [.servers, .volumes, .floatingIPs, .firewalls, .networks, .loadBalancers]

        var snapshot = NSDiffableDataSourceSnapshot<ServerListSection, ServerListItem>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)

        for section in sections {
            if project != nil {
                var listItems = [ServerListItem]()
                switch section {
                /* case .tabs:
                 var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ServerListItem>()
                 sectionSnapshot.append(tabsItems)
                 dataSource.apply(sectionSnapshot, to: section) */
                case .servers:
                    listItems = project!.servers.map { ServerListItem(title: $0.name, image: UIImage(systemName: "server.rack"), childcount: nil) }
                case .volumes:
                    listItems = project!.volumes.map { ServerListItem(title: $0.name, image: UIImage(systemName: "externaldrive"), childcount: nil) }
                case .floatingIPs:
                    listItems = project!.floatingIPs.map { ServerListItem(title: $0.name, image: UIImage(systemName: "cloud"), childcount: nil) }
                case .firewalls:
                    listItems = project!.firewalls.map { ServerListItem(title: $0.name, image: UIImage(systemName: "flame"), childcount: nil) }
                case .networks:
                    listItems = project!.networks.map { ServerListItem(title: $0.name, image: UIImage(systemName: "network"), childcount: nil) }
                case .loadBalancers:
                    listItems = project!.loadBalancers.map { ServerListItem(title: $0.name, image: UIImage(systemName: "scale.3d"), childcount: nil) }
                }
                setupListItem(title: section.rawValue, items: listItems, section: section)
            }
        }
    }

    private func setupListItem(title: String, items: [ServerListItem], section: ServerListSection) {
        let headerItem = ServerListItem(title: title, image: nil, childcount: items.count)
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ServerListItem>()
        sectionSnapshot.append([headerItem])
        sectionSnapshot.append(items, to: headerItem)
        #if DEBUG
            if CommandLine.arguments.contains("projectdetail-collectionview-autoexpand") {
                sectionSnapshot.expand([headerItem])
            }
        #endif
        dataSource.apply(sectionSnapshot, to: section)
    }
}

extension ServerListViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var detailView: UIViewController?

        let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        if indexPath.row == 0 { return }
        switch sectionIdentifier {
        case .servers:
            let detailController = ProjectServerDetailController(project: project!, server: project!.servers[indexPath.row - 1])
            detailView = UIHostingController(rootView: ProjectServerDetailView(controller: detailController))
        case .volumes:
            let detailController = ProjectVolumeDetailController(project: project!, volume: project!.volumes[indexPath.row - 1])
            detailView = UIHostingController(rootView: ProjectVolumeDetailView(controller: detailController))
        case .floatingIPs:
            let detailController = ProjectFloatingIPDetailController(project: project!, floatingip: project!.floatingIPs[indexPath.row - 1])
            detailView = UIHostingController(rootView: ProjectFloatingIPDetailView(controller: detailController))
        case .firewalls:
            let detailController = ProjectFirewallDetailController(project: project!, firewall: project!.firewalls[indexPath.row - 1])
            detailView = UIHostingController(rootView: ProjectFirewallDetailView(controller: detailController))
        case .networks:
            let detailController = ProjectNetworkDetailController(project: project!, network: project!.networks[indexPath.row - 1])
            detailView = UIHostingController(rootView: ProjectNetworkDetailView(controller: detailController))
        case .loadBalancers:
            let detailController = ProjectLoadBalancerDetailController(project: project!, loadBalancer: project!.loadBalancers[indexPath.row - 1])
            detailView = UIHostingController(rootView: ProjectLoadBalancerDetailView(controller: detailController))
        }

        /* if indexPath.section == 0 { // Security
             detailView = UIViewController()
         } else */
        /* if sectionIdentifier == .servers { // Servers
             let detailController = ProjectServerDetailController(project: project!, server: project!.servers[indexPath.row - 1])
             detailView = UIHostingController(rootView: ProjectServerDetailView(controller: detailController))

         } else if indexPath.section == 1 { // Volumes
             let detailController = ProjectVolumeDetailController(project: project!, volume: project!.volumes[indexPath.row - 1])
             detailView = UIHostingController(rootView: ProjectVolumeDetailView(controller: detailController))
         } else if indexPath.section == 2 { // Floating IPs
             let detailController = ProjectFloatingIPDetailController(project: project!, floatingip: project!.floatingIPs[indexPath.row - 1])
             detailView = UIHostingController(rootView: ProjectFloatingIPDetailView(controller: detailController))
         } else if indexPath.section == 3 { // Firewalls
             let detailController = ProjectFirewallDetailController(project: project!, firewall: project!.firewalls[indexPath.row - 1])
             detailView = UIHostingController(rootView: ProjectFirewallDetailView(controller: detailController))
         } else if indexPath.section == 4 { // Network
             let detailController = ProjectNetworkDetailController(project: project!, network: project!.networks[indexPath.row - 1])
             detailView = UIHostingController(rootView: ProjectNetworkDetailView(controller: detailController))
         } else { // Load Balancers
             let detailController = ProjectLoadBalancerDetailController(project: project!, loadBalancer: project!.loadBalancers[indexPath.row - 1])
             detailView = UIHostingController(rootView: ProjectLoadBalancerDetailView(controller: detailController))
         } */

        splitViewController?.showsSecondaryOnlyButton = true

        if let collapsed = splitViewController?.isCollapsed, collapsed {
            navigationController?.pushViewController(detailView!, animated: true)
        } else {
            let detailNavigationController = UINavigationController(rootViewController: detailView!)
            detailNavigationController.navigationBar.prefersLargeTitles = true
            splitViewController?.setViewController(detailNavigationController, for: .secondary)
        }
    }
}

struct ServerListItem: Hashable {
    let title: String?
    let image: UIImage?
    private let identifier = UUID()
    let childcount: Int?
}

let tabsItems: [ServerListItem] = [
    // .init(title: "Volumes", image: UIImage(systemName: "cube")),
    // .init(title: "Load Balancers", image: UIImage(systemName: "scale.3d")),
    // .init(title: "Floating IPs", image: UIImage(systemName: "cloud")),
    // .init(title: "Networks", image: UIImage(systemName: "network")),
    // .init(title: "Firewalls", image: UIImage(systemName: "flame")),
    .init(title: "Security", image: UIImage(systemName: "key"), childcount: nil),
]

/* let serverItems: [ServerListItem] = [
 .init(title: "Main", image: UIImage(systemName: "server.rack"))] */

enum ServerListSection: String {
    case servers = "Servers"
    case volumes = "Volumes"
    case floatingIPs = "Floating IPs"
    case firewalls = "Firewalls"
    case networks = "Networks"
    case loadBalancers = "Load Balancers"
    // case tabs
}
