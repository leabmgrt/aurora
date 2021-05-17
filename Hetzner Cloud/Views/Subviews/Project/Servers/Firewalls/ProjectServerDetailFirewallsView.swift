//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 09.05.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI

struct ProjectServerDetailFirewallsView: View {
    @ObservedObject var controller: ProjectServerDetailFirewallsController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            ScrollView {
                AppReadOnlyDisclaimerView()
                Group {
                    Group {
                        VStack(alignment: .leading) {
                            Text("Firewalls").bold().font(.title)
                            Text("Firewalls allow you to restrict or allow traffic based on rules.")
                            Text("Inbound rules define the traffic that is allowed, all other inbound traffic will be dropped.")
                            Text("All outbound traffic is allowed as long as no outbound rule is specified")

                            Button(action: {}, label: {
                                Text("Apply Firewall").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                            }).padding(.top)
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading)
                }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding()

                if controller.server.public_net.firewalls.count > 0 {
                    ForEach(controller.server.public_net.firewalls, id: \.id) { firewall in
                        let firewallInfo = controller.project.firewalls.first(where: { $0.id == firewall.id })!
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(firewallInfo.name)").bold().padding(.trailing)
                                    Text("\(firewallInfo.rules.count) Rules").foregroundColor(.secondary).font(.footnote)
                                }
                                if firewall.status == .applied {
                                    HStack {
                                        Image(systemName: "checkmark").foregroundColor(.white)
                                        Text("Fully applied").foregroundColor(.white)
                                    }.padding(6).background(Color.green).cornerRadius(12)
                                } else {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle").foregroundColor(.white)
                                        Text("Partially applied").foregroundColor(.white)
                                    }.padding(6).background(Color.orange).cornerRadius(12)
                                }
                            }
                            Divider()
                        }.padding(4)
                    }.padding([.leading, .trailing])
                } else {
                    Text("You currently don't have any firewalls applied to this server. Try applying one!")
                }
            }
        }.navigationBarTitle(Text("Firewalls"))
    }
}

class ProjectServerDetailFirewallsController: ObservableObject {
    @Published var project: CloudProject
    @Published var server: CloudServer

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }
}

struct ProjectServerDetailFirewallsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailFirewallsView(controller: .init(project: .example, server: .example))
    }
}
