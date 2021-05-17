//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 08.05.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI

struct ProjectServerDetailSnapshotsView: View {
    @ObservedObject var controller: ProjectServerDetailSnapshotsController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if controller.snapshots != nil {
                ScrollView {
                    AppReadOnlyDisclaimerView()
                    Group {
                        Group {
                            VStack(alignment: .leading) {
                                Text("Snapshots").bold().font(.title)
                                Text("Snapshots are instant copies of your servers disks.")
                                Text("You can create a new server from a snapshot and even transfer them to a different project.")
                                Text("It's recommended to power down your server before creating a backup to ensure data consistency on the disks.")
                                Text("Snapshots cost 0.0119€/GB/month.")

                                Button(action: {}, label: {
                                    Text("Take snapshot").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                                }).padding(.top)
                            }
                        }.frame(minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading)
                    }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding()

                    if controller.snapshots!.count > 0 {
                        ForEach(controller.snapshots!.sorted(by: { $0.created > $1.created }), id: \.id) { snapshot in
                            VStack(alignment: .leading) {
                                HStack {
                                    Circle().foregroundColor(getServerStatusColor(snapshot.status == .available ? .running : .starting)).frame(width: 25, height: 25, alignment: .center).shadow(color: getServerStatusColor(snapshot.status == .available ? .running : .starting), radius: 3, x: 0, y: 0)
                                    Text("\(snapshot.description)").bold()
                                    Spacer()
                                }
                                Text("Created: ").bold() + Text("\(RelativeDateTimeFormatter().localizedString(for: snapshot.created, relativeTo: Date()))")
                                Text("Disk size: ").bold() + Text("\(String(format: "%.2f", snapshot.image_size ?? 0)) GB")
                                Divider()
                            }.padding(4)
                        }.padding([.leading, .trailing])
                    } else {
                        Text("You currently don't have any snapshots. Try creating one!")
                    }
                }
            } else {
                VStack {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Text("Loading...").padding()
                }
            }
        }.navigationTitle(Text("Snapshots")).onAppear {
            if controller.snapshots == nil {
                controller.loadData()
            }
        }
    }
}

class ProjectServerDetailSnapshotsController: ObservableObject {
    @Published var project: CloudProject
    @Published var server: CloudServer
    @Published var snapshots: [CloudServerImage]? = nil

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
        snapshots = snapshots
    }

    func loadData() {
        project.api!.loadServerSnapshots(server.id) { result in
            switch result {
            case let .failure(err):
                cloudAppSplitViewController.showError(err)
            case let .success(newsnapshots):
                self.snapshots = newsnapshots
            }
        }
    }
}

struct ProjectServerDetailSnapshotsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailSnapshotsView(controller: .init(project: .example, server: .example))
    }
}
