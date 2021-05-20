//
// Aurora
// File created by Adrian Baumgart on 04.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct ProjectServerDetailBackupsView: View {
    @ObservedObject var controller: ProjectServerDetailBackupsController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if controller.backups != nil {
                ScrollView {
                    AppReadOnlyDisclaimerView()
                    Group {
                        Group {
                            VStack(alignment: .leading) {
                                Text("Backups").bold().font(.title)
                                Text("Backups are automated copies of your server disks. Every server has seven slots for backups available.")
                                Text("If all slots are full and a new backup is created, the oldest one will be deleted.")
                                Text("It's recommended to power down your server before creating a backup to ensure data consistency on the disks.")
                                Text("Enabling backups for your server will cost 20% of your server plan per month.")

                                Button(action: {}, label: {
                                    Text("Run manual backup").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                                }).padding(.top)
                                Button(action: {}, label: {
                                    Text("Disable backups").bold().padding().foregroundColor(.white).background(Color.gray).cornerRadius(7)
                                })
                            }
                        }.frame(minWidth: 0,
                                maxWidth: .infinity,
                                alignment: .topLeading)
                    }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding()
                    if controller.backups!.count > 0 {
                        ForEach(controller.backups!.sorted(by: { $0.created > $1.created }), id: \.id) { backup in
                            VStack(alignment: .leading) {
                                HStack {
                                    Circle().foregroundColor(getServerStatusColor(backup.status == .available ? .running : .starting)).frame(width: 25, height: 25, alignment: .center).shadow(color: getServerStatusColor(backup.status == .available ? .running : .starting), radius: 3, x: 0, y: 0)
                                    Text("\(backup.description)").bold()
                                    Spacer()
                                }
                                Text("Created: ").bold() + Text("\(RelativeDateTimeFormatter().localizedString(for: backup.created, relativeTo: Date()))")
                                Text("Disk size: ").bold() + Text("\(String(format: "%.2f", backup.image_size ?? 0)) GB")
                                Divider()
                            }.padding(4)
                        }.padding([.leading, .trailing])
                    } else {
                        Text("You currently don't have any backups. Try creating one!")
                    }
                }
            } else {
                VStack {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Text("Loading...").padding()
                }
            }
        }.navigationBarTitle(Text("Backups"))
            .onAppear {
                if controller.backups == nil {
                    controller.loadData()
                }
            }
    }
}

class ProjectServerDetailBackupsController: ObservableObject {
    @Published var project: CloudProject
    @Published var server: CloudServer
    @Published var backups: [CloudServerImage]? = nil

    init(project: CloudProject, server: CloudServer) {
        self.server = server
        self.project = project
        backups = nil
    }

    func loadData() {
        project.api!.loadServerBackups(server.id) { result in
            switch result {
            case let .failure(err):
                cloudAppSplitViewController.showError(err)
            case let .success(newbackups):
                self.backups = newbackups
            }
        }
    }
}

struct ProjectServerDetailBackupsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailBackupsView(controller: .init(project: .example, server: .example))
    }
}
