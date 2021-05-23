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

class ProjectServerDetailViewController: UIViewController {
    var controller: ProjectServerDetailController?
    var hostingController: UIHostingController<ProjectServerDetailView>?
    var server: CloudServer? {
        didSet {
            if controller != nil {
                controller?.server = server!
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

struct ProjectServerDetailView: View {
    @ObservedObject var controller: ProjectServerDetailController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            Group {
                Group {
                    HStack(alignment: .center) {
                        Circle().foregroundColor(getServerStatusColor(controller.server.status)).frame(width: 25, height: 25, alignment: .center).shadow(color: getServerStatusColor(controller.server.status), radius: 3, x: 0, y: 0)
                        Text("\(controller.server.status.rawValue)").bold()
                        Spacer()
                        if controller.server.protection.delete && controller.server.protection.rebuild {
                            Text("Locked").foregroundColor(.gray).italic()
                            Image(systemName: "lock").foregroundColor(.gray)
                        }
                        /* Toggle(isOn: .constant(controller.server!.status != .off), label: {
                             Text("")
                         }) */

                    }.padding(.bottom)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), alignment: .top)], alignment: .center, spacing: 10, pinnedViews: [], content: {
                    FloatingCardBackgroundView {
                        VStack {
                            HStack {
                                Text("Configuration (\(controller.server.server_type.name))").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)
                            HStack {
                                Image(systemName: "cpu")
                                Text("\(Int(controller.server.server_type.cores)) VCPU\(controller.server.server_type.cores != 1 ? "s" : "")")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "memorychip")
                                Text("\(Int(controller.server.server_type.memory)) GB RAM")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "internaldrive")
                                Text("\(Int(controller.server.server_type.disk)) GB DISK (\(controller.server.server_type.storage_type.rawValue.lowercased()))")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "eurosign.circle")
                                let pricing = controller.server.server_type.prices.first(where: { $0.location == controller.server.datacenter.location.name })!
                                Text("\(String(format: "%.2f", Double(pricing.price_monthly.gross)!))/mo")
                                Spacer()
                            }
                        }
                    }

                    FloatingCardBackgroundView {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Network (Public)").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)

                            Text("IPv4: ") + Text("\(controller.server.public_net.ipv4.ip)").bold()
                            Text("IPv6: ") + Text("\(controller.server.public_net.ipv6.ip)").bold()
                        }
                    }

                    FloatingCardBackgroundView {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Location").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)

                            Text("City: ") + Text("\(controller.server.datacenter.location.city)").bold()
                            Text("Datacenter: ") + Text("\(controller.server.datacenter.description)").bold()
                            Text("Country: ") + Text("\(controller.server.datacenter.location.country)").bold()
                        }
                    }

                }).padding([.top, .bottom])
                Group {
                    Group {
                        ProjectServerDetailOtherOptionsView(title: "Graphs") {
                            ProjectServerDetailGraphsView(controller: .init(project: controller.project, server: controller.server))
                        }
                        ProjectServerDetailOtherOptionsView(title: "Backups") {
                            ProjectServerDetailBackupsView(controller: .init(project: controller.project, server: controller.server))
                        }
                        ProjectServerDetailOtherOptionsView(title: "Snapshots") {
                            ProjectServerDetailSnapshotsView(controller: .init(project: controller.project, server: controller.server))
                        }
                        /* ProjectServerDetailOtherOptionsView(title: "Load Balancers") {
                             Text("Destination")
                         } */
                        ProjectServerDetailOtherOptionsView(title: "Networking") {
                            ProjectServerDetailNetworkingView(controller: .init(project: controller.project, server: controller.server))
                        }
                        ProjectServerDetailOtherOptionsView(title: "Firewalls") {
                            ProjectServerDetailFirewallsView(controller: .init(project: controller.project, server: controller.server))
                        }
                        /* ProjectServerDetailOtherOptionsView(title: "Volumes") {
                             Text("Destination")
                         } */
                    }
                    /* Group {
                         ProjectServerDetailOtherOptionsView(title: "Power") {
                             ProjectServerDetailPowerView(controller: .init(project: controller.project, server: controller.server))
                         }
                         ProjectServerDetailOtherOptionsView(title: "Rescue") {
                             Text("Destination")
                         }
                         ProjectServerDetailOtherOptionsView(title: "ISO Images") {
                             Text("Destination")
                         }
                         ProjectServerDetailOtherOptionsView(title: "Rescale") {
                             Text("Destination")
                         }
                         ProjectServerDetailOtherOptionsView(title: "Rebuild") {
                             Text("Destination")
                         }
                         ProjectServerDetailOtherOptionsView(title: "Delete") {
                             ProjectServerDetailDeleteView(controller: .init(project: controller.project, server: controller.server))
                         }
                     } */
                }
            }.padding()
        }.navigationBarTitle(Text("\(controller.server.name)"))
    }
}

func getServerStatusColor(_ status: CloudServerStatus) -> Color {
    switch status {
    case .deleting:
        return .orange
    case .initializing:
        return .orange
    case .migrating:
        return .orange
    case .off:
        return .red
    case .rebuilding:
        return .orange
    case .running:
        return .green
    case .starting:
        return .orange
    case .stopping:
        return .orange
    case .unknown:
        return .gray
    }
}

struct ProjectServerDetailOtherOptionsView<Content: View>: View {
    var title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                NavigationLink(
                    destination: content,
                    label: {
                        Group {
                            HStack {
                                Text("\(title)").foregroundColor(Color(UIColor.label))
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                ).frame(width: geometry.size.width)
                Divider()
            }
        }).frame(height: 36)
    }
}

struct ProjectServerDetailView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectServerDetailView(controller: .init(project: .example, server: .example))
        }.navigationViewStyle(StackNavigationViewStyle())
            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
        // .preferredColorScheme(.dark)
    }
}

class ProjectServerDetailController: ObservableObject {
    @Published var server: CloudServer
    @Published var project: CloudProject

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }
}
