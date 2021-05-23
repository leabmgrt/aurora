//
// Aurora
// File created by Lea Baumgart on 21.05.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct ProjectServerDetailNetworkingView: View {
    @ObservedObject var controller: ProjectServerDetailNetworkingController

    var body: some View {
        List {
            Section(header: Text("Primary IPs")) {
                Group {
                    VStack(alignment: .leading) {
                        Text("\(controller.server.public_net.ipv4.ip)").bold()
                        Text("Reverse DNS: \(controller.server.public_net.ipv4.dns_ptr)").italic().foregroundColor(.secondary).font(.caption)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("\(controller.server.public_net.ipv6.ip)").bold()
                        Text("Reverse DNS: \(controller.server.public_net.ipv6.dns_ptr.count) Entr\(controller.server.public_net.ipv6.dns_ptr.count == 1 ? "y" : "ies")").italic().foregroundColor(.secondary).font(.caption)
                    }
                }
            }
            Section(header: Text("Floating IPs")) {
                let floatingIPs = controller.project.floatingIPs.filter { $0.server == controller.server.id }
                if floatingIPs.count > 0 {
                    ForEach(floatingIPs, id: \.id) { ip in
                        Text("\(ip.ip)").bold()
                    }
                } else {
                    Text("No Floating IPs assigned to this server").italic().foregroundColor(.secondary)
                }
            }

            Section(header: Text("Private IPs")) {
                let privateNetwork = controller.server.private_net
                if privateNetwork.count > 0 {
                    ForEach(privateNetwork, id: \.network) { network in
                        let networkInProject = controller.project.networks.filter { $0.id == network.network }.first!
                        VStack(alignment: .leading) {
                            Text("\(network.ip)").bold()
                            Text("Network: ") + Text("\(networkInProject.name)").bold()
                            if network.alias_ips.count > 0 {
                                Text("Alias IPs: \(network.alias_ips.joined(separator: ", "))")
                            }
                        }
                    }
                } else {
                    Text("Server not attached to any network").italic().foregroundColor(.secondary)
                }
            }

            Section(header: Text("Usage")) {
                let ingoingTraffic = controller.server.ingoing_traffic ?? 0
                let outgoingTraffic = controller.server.outgoing_traffic ?? 0
                let includedTraffic = controller.server.included_traffic ?? 0

                Group {
                    VStack(alignment: .leading) {
                        Text("Ingoing Traffic").bold()
                        Text("\(ByteCountFormatter.string(fromByteCount: Int64(ingoingTraffic), countStyle: .binary)) / \(ByteCountFormatter.string(fromByteCount: Int64(includedTraffic), countStyle: .binary))")
                        ServerNetworkingProgressbarView(used: ingoingTraffic, included: includedTraffic)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Outgoing Traffic").bold()
                        Text("\(ByteCountFormatter.string(fromByteCount: Int64(outgoingTraffic), countStyle: .binary)) / \(ByteCountFormatter.string(fromByteCount: Int64(includedTraffic), countStyle: .binary))")
                        ServerNetworkingProgressbarView(used: outgoingTraffic, included: includedTraffic)
                    }
                }
            }
        }.listStyle(GroupedListStyle()).navigationBarTitle(Text("Networking"))
    }
}

struct ServerNetworkingProgressbarView: View {
    var percentage: Float

    init(used: Double, included: Double) {
        percentage = Float(used) / Float(included)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                Rectangle().frame(width: min(CGFloat(percentage) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(getColor())
                    .animation(.easeInOut)
            }.cornerRadius(45)
        }
    }

    func getColor() -> Color {
        if percentage < 0.5 {
            return .green
        } else if percentage < 0.75 {
            return .orange
        } else {
            return .red
        }
    }
}

class ProjectServerDetailNetworkingController: ObservableObject {
    @Published var project: CloudProject
    @Published var server: CloudServer

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }
}

struct ProjectServerDetailNetworkingView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailNetworkingView(controller: .init(project: .example, server: .example))
    }
}
