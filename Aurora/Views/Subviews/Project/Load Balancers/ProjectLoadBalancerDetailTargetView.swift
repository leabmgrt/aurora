//
// Aurora
// File created by Adrian Baumgart on 05.04.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct ProjectLoadBalancerDetailTargetView: View {
    @ObservedObject var controller: ProjectLoadBalancerDetailTargetController

    var body: some View {
        List {
            ForEach(controller.loadBalancer.targets.filter { $0.type == .server }, id: \.id) { target in
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
                            ProjectLoadBalancerDetailHealthStatusBadge(mix: controller.getHealthCheckMixByServerId(targetServer!.id), showNumbers: true)
                        }
                    }.padding([.top, .bottom], 4)
                } else {
                    Text("Something went wrong while loading the server (ID: \(target.server.id))").italic().padding(6)
                }
            }
        }.navigationBarTitle(Text("Targets"))
    }
}

class ProjectLoadBalancerDetailTargetController: ObservableObject {
    @Published var project: CloudProject
    @Published var loadBalancer: CloudLoadBalancer

    init(project: CloudProject, loadBalancer: CloudLoadBalancer) {
        self.project = project
        self.loadBalancer = loadBalancer
    }

    func getServerById(_ id: Int) -> CloudServer? {
        return project.servers.first(where: { $0.id == id })
    }

    func getHealthCheckMixByServerId(_ id: Int) -> ProjectLoadBalancerDetailHealthCheckMix {
        guard let target = loadBalancer.targets.first(where: { $0.type == .server && $0.server.id == id }) else { return .init(amountHealthy: 0, amountFailed: 0) }

        let healthyChecks = target.health_status.filter { $0.status == "healthy" }.count
        let unhealthyChecks = target.health_status.filter { $0.status == "unhealthy" }.count

        return .init(amountHealthy: healthyChecks, amountFailed: unhealthyChecks)
    }
}

struct ProjectLoadBalancerDetailTargetView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectLoadBalancerDetailTargetView(controller: .init(project: .example, loadBalancer: .example))
    }
}
