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

class ProjectNetworkDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

struct ProjectNetworkDetailView: View {
    @ObservedObject var controller: ProjectNetworkDetailController
    @State private var selectedView = 0

    var body: some View {
        if controller.project != nil && controller.network != nil {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text("IP range: ").bold() + Text("\(controller.network!.ip_range)")
                    }
                }
                Picker(selection: $selectedView, label: Text("")) {
                    Text("Resources").tag(0)
                    Text("Subnets").tag(1)
                    Text("Routes").tag(2)
                }.pickerStyle(SegmentedPickerStyle())

                if selectedView == 0 {
                    if controller.getServersInNetwork().count > 0 {
                        List {
                            ForEach(controller.getServersInNetwork(), id: \.id) { server in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Circle().foregroundColor(getServerStatusColor(server.status)).frame(width: 20, height: 20, alignment: .center).shadow(color: getServerStatusColor(server.status), radius: 3, x: 0, y: 0)
                                        Text("\(server.name)").bold().font(.title3)
                                    }
                                    Text("Private IP: ").bold() + Text("\(server.private_net.filter { $0.network == controller.network!.id }.first!.ip)")
                                }.padding([.top, .bottom], 4)
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            Text("No resources").bold().font(.title2)
                            Text("There are no resources in this network").foregroundColor(.gray).padding(.top, 4)
                            Spacer()
                        }
                    }
                } else if selectedView == 1 {
                    List {
                        ForEach(controller.network!.subnets, id: \.id) { subnet in
                            Section(header: Text("\(subnet.ip_range) (\(subnet.network_zone.lowercased()))")) {
                                ForEach(controller.getServersInSubnet(subnet.id), id: \.id) { server in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Circle().foregroundColor(getServerStatusColor(server.status)).frame(width: 20, height: 20, alignment: .center).shadow(color: getServerStatusColor(server.status), radius: 3, x: 0, y: 0)
                                            Text("\(server.name)").bold().font(.title3)
                                        }
                                        Text("Private IP: ").bold() + Text("\(server.private_net.filter { $0.network == controller.network!.id }.first!.ip)")
                                        if server.private_net.filter({ $0.network == controller.network!.id }).first!.alias_ips.count > 0 {
                                            Text("Alias IPs:")
                                            CloudFirewallTagView(ips: server.private_net.filter { $0.network == controller.network!.id }.first!.alias_ips)
                                        }
                                    }.padding([.top, .bottom], 4)
                                }
                            }
                        }
                    }
                } else {
                    if controller.network!.routes.count > 0 {
                        List {
                            ForEach(controller.network!.routes, id: \.id) { route in
                                VStack(alignment: .leading) {
                                    Text("Destination: \(route.destination)").bold().font(.title3)
                                    Text("Gateway: ").bold() + Text("\(route.gateway)")
                                }.padding([.top, .bottom], 4)
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            Text("No routes").bold().font(.title2)
                            Text("There are no routes in this network").foregroundColor(.gray).padding(.top, 4)
                            Spacer()
                        }
                    }
                }
            }.padding().navigationBarTitle(Text(controller.network!.name))
        } else {
            Text("oh no... Something went really wrong. Please try again :(")
        }
    }
}

class ProjectNetworkDetailController: ObservableObject {
    @Published var project: CloudProject? = nil
    @Published var network: CloudNetwork? = nil

    init(project: CloudProject, network: CloudNetwork) {
        self.project = project
        self.network = network
    }

    func getServersInNetwork() -> [CloudServer] {
        return project!.servers.filter { $0.private_net.contains(where: { $0.network == network!.id }) }
    }

    func getServersInSubnet(_ subnet: UUID) -> [CloudServer] {
        let serversInNetwork = getServersInNetwork()
        let subnetByID = network!.subnets.first(where: { $0.id == subnet })! // This is the subnet we need

        /*
         let subnetIPRangeWithoutSlash = String(subnetByID.ip_range.split(separator: "/").first!) // Get IP range of subnet to later filter out all servers
         let bitLengthForPrefix = String(subnetByID.ip_range.split(separator: "/").last!) // The thingy after the slash
         */

        let regexToDetectLastIPDotAndBitPrefix = try! NSRegularExpression(pattern: ".([0-9])+/([0-9])+", options: .caseInsensitive) // xxx.xxx.xxx.0/24 <- detect ".0/24"

        let subnetIPRangeToDetectOtherServersInSubnet = regexToDetectLastIPDotAndBitPrefix.stringByReplacingMatches(in: subnetByID.ip_range, options: [], range: NSRange(location: 0, length: subnetByID.ip_range.count), withTemplate: "")

        print(subnetIPRangeToDetectOtherServersInSubnet)

        var serversInSubnet = serversInNetwork.filter { $0.private_net.first(where: { $0.network == network!.id })!.ip.starts(with: subnetIPRangeToDetectOtherServersInSubnet) }
        serversInSubnet.append(contentsOf: serversInNetwork.filter { $0.private_net.first(where: { $0.network == network!.id })!.alias_ips.filter { $0.starts(with: subnetIPRangeToDetectOtherServersInSubnet) }.count != 0 })

        return serversInSubnet

        // this was painful
    }
}
