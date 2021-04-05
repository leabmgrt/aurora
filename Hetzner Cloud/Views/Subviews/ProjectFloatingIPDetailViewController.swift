//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 27.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI
import UIKit

class ProjectFloatingIPDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

struct ProjectFloatingIPDetailView: View {
    @ObservedObject var controller: ProjectFloatingIPDetailController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if controller.project != nil && controller.floatingip != nil {
            ScrollView {
                Group {
                    Group {
                        HStack(alignment: .top) {
                            Spacer()
                            VStack(alignment: .trailing) {
                                if controller.floatingip!.protection.delete {
                                    HStack {
                                        Text("Locked").foregroundColor(.gray).italic()
                                        Image(systemName: "lock").foregroundColor(.gray)
                                    }
                                }
                                if controller.floatingip!.server != nil {
                                    HStack {
                                        Text("Assigned to: ") + Text("\(controller.project!.servers.first(where: { $0.id == controller.floatingip!.server! })?.name ?? "unknown")").bold()
                                        Image(systemName: "checkmark.circle").foregroundColor(.green)
                                    }
                                } else {
                                    HStack {
                                        Text("Unassigned").foregroundColor(.gray).italic()
                                        Image(systemName: "xmark.circle").foregroundColor(.red)
                                    }
                                }

                                if controller.floatingip!.blocked {
                                    HStack {
                                        Text("Blocked").foregroundColor(.red)
                                        Image(systemName: "hand.raised").foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], alignment: .center, spacing: 10, pinnedViews: []) {
                        Group {
                            VStack {
                                HStack {
                                    Text("Configuration").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)
                                HStack(alignment: .top) {
                                    Image(systemName: "network")
                                    Text("IP: ") + Text("\(controller.floatingip!.ip)").bold()
                                    Spacer()
                                }
                                HStack(alignment: .top) {
                                    Image(systemName: "gearshape.2")
                                    Text("Type: ") + Text("\(controller.floatingip!.type.getHumanName())").bold()
                                    Spacer()
                                }
                                ForEach(controller.floatingip!.dns_ptr, id: \.ip) { dnsptr in
                                    HStack(alignment: .top) {
                                        Image(systemName: "number")
                                        Text("Reverse DNS (\(dnsptr.ip)): ") + Text("\(dnsptr.dns_ptr)").bold()
                                        Spacer()
                                    }
                                }
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                        Group {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Location").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)

                                Text("City: ") + Text("\(controller.floatingip!.home_location.city)").bold()
                                Text("Datacenter: ") + Text("\(controller.floatingip!.home_location.description)").bold()
                                Text("Country: ") + Text("\(controller.floatingip!.home_location.country)").bold()
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)
                    }.padding([.top, .bottom])
                }.padding()
            }.navigationBarTitle(Text("\(controller.floatingip!.name)"))
        } else {
            Text("wait... something went wrong. Please try again. Sowwyy >.<")
        }
    }
}

class ProjectFloatingIPDetailController: ObservableObject {
    @Published var project: CloudProject? = nil
    @Published var floatingip: CloudFloatingIP? = nil

    init(project: CloudProject, floatingip: CloudFloatingIP) {
        self.project = project
        self.floatingip = floatingip
    }
}
