//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 05.04.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI

struct ProjectLoadBalancerDetailServicesView: View {
    @ObservedObject var controller: ProjectLoadBalancerDetailServicesController

    var body: some View {
        if controller.project != nil && controller.loadBalancer != nil {
            List {
                ForEach(controller.loadBalancer!.services, id: \.id) { service in
                    Section(header: Text("\(service.protocol.rawValue): \(String(service.listen_port)) -> \(String(service.destination_port))")) {
                        Text("Interval: \(service.health_check.interval)s | Timeout: \(service.health_check.timeout)s | Retries: \(service.health_check.retries) \(service.health_check.http != nil ? " | Domain: \(service.health_check.http!.domain ?? "---") | Path: \(service.health_check.http!.path) | Response: \(service.health_check.http!.response) | Status codes: \(controller.getStatusCodesAsString(service.health_check.http!.status_codes))" : "")").padding(4)

                        ForEach(controller.loadBalancer!.targets.filter { $0.type == .server }, id: \.id) { target in
                            let targetServer = controller.getServerById(target.server.id)
                            if targetServer != nil {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Circle().foregroundColor(getServerStatusColor(targetServer!.status)).frame(width: 20, height: 20, alignment: .center).shadow(color: getServerStatusColor(targetServer!.status), radius: 3, x: 0, y: 0)
                                        Text("\(targetServer!.name)").bold().font(.title3)
                                    }
                                    Text("Public IP: ").bold() + Text("\(targetServer!.public_net.ipv4.ip)")
                                    HStack {
                                        Text("Status: ").bold()
                                        let healthStatus = controller.getTargetServerStatusForListenPort(service.listen_port, serverId: targetServer!.id)
                                        if healthStatus == "healthy" {
                                            HStack {
                                                Image(systemName: "checkmark").foregroundColor(.white)
                                                Text("Healthy").foregroundColor(.white)
                                            }.padding(6).background(Color.green).cornerRadius(12)
                                        } else if healthStatus == "unhealthy" {
                                            HStack {
                                                Image(systemName: "xmark.circle").foregroundColor(.white)
                                                Text("Unhealthy").foregroundColor(.white)
                                            }.padding(6).background(Color.red).cornerRadius(12)
                                        } else {
                                            HStack {
                                                Image(systemName: "questionmark.circle").foregroundColor(.white)
                                                Text(healthStatus.capitalized).foregroundColor(.white)
                                            }.padding(6).background(Color.gray).cornerRadius(12)
                                        }
                                        Spacer()
                                    }
                                }.padding([.top, .bottom], 4)
                            } else {
                                Text("Something went wrong while loading the server (ID: \(target.server.id))").italic().padding(6)
                            }
                        }
                    }
                }
            }.listStyle(InsetGroupedListStyle()).navigationBarTitle(Text("Services"))
        } else {
            Text("oof... something went wrong. Please try again.")
        }
    }
}

class ProjectLoadBalancerDetailServicesController: ObservableObject {
    @Published var project: CloudProject?
    @Published var loadBalancer: CloudLoadBalancer?

    init(project: CloudProject, loadBalancer: CloudLoadBalancer) {
        self.project = project
        self.loadBalancer = loadBalancer
    }

    func getServerById(_ id: Int) -> CloudServer? {
        return project!.servers.first(where: { $0.id == id })
    }

    func getTargetServerStatusForListenPort(_ port: Int, serverId: Int) -> String {
        guard let targetServer = loadBalancer!.targets.first(where: { $0.type == .server && $0.server.id == serverId }) else { return "unknown" }
        guard let healthStatus = targetServer.health_status.first(where: { $0.listen_port == port }) else { return "unknown" }
        return healthStatus.status
    }

    func getStatusCodesAsString(_ codes: [String]) -> String {
        var finalString = ""
        for (index, code) in codes.enumerated() {
            finalString = "\(finalString)\(index == 0 ? "" : ", ")\(code)"
        }
        return finalString
    }
}

struct ProjectLoadBalancerDetailServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectLoadBalancerDetailServicesView(controller: .init(project: .example, loadBalancer: .example))
    }
}

/*

 */
