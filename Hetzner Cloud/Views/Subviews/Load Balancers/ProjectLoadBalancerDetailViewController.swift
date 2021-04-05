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

class ProjectLoadBalancerDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

struct ProjectLoadBalancerDetailView: View {
    @ObservedObject var controller: ProjectLoadBalancerDetailController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if controller.project != nil && controller.loadBalancer != nil {
            ScrollView {
                Group {
                    Group {
                        HStack(alignment: .center) {
                            Spacer()
                            ProjectLoadBalancerDetailHealthStatusBadge(mix: controller.getHealthCheckMix())
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .center, spacing: 10, pinnedViews: []) {
                        Group {
                            VStack {
                                HStack {
                                    Text("Configuration (\(controller.loadBalancer!.type.description))").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)
                                HStack {
                                    Image(systemName: "target")
                                    Text("\(controller.loadBalancer!.targets.count)/\(Int(controller.loadBalancer!.type.max_targets))").bold() + Text(" Targets")
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("\(controller.loadBalancer!.services.count)/\(Int(controller.loadBalancer!.type.max_services))").bold() + Text(" Services")
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "shield")
                                    Text("\(controller.getCertificateCount())/\(Int(controller.loadBalancer!.type.max_assigned_certificates))").bold() + Text(" Certificates")
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "network")
                                    Text("\(Int(controller.loadBalancer!.type.max_connections))").bold() + Text(" Connections")
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "plus.slash.minus")
                                    Text("Algorithm: ") + Text("\(controller.loadBalancer!.algorithm.type.humanString())").bold()
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "eurosign.circle")
                                    Text("\(String(format: "%.2f", controller.getMonthlyPrice()))/mo")
                                    Spacer()
                                }
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                        Group {
                            VStack {
                                HStack {
                                    Text("Health status").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)
                                HStack {
                                    ProjectLoadBalancerDetailHealthStatusBadge(mix: controller.getHealthCheckMix())
                                    Spacer()
                                }
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 12.0)
                                        .opacity(0.3)
                                        .foregroundColor(Color.gray)

                                    let mix = controller.getHealthCheckMix()
                                    let percentageHealthy = Float(mix.amountHealthy) / Float(mix.amountHealthy + mix.amountFailed)
                                    let percentageFailed = Float(mix.amountFailed) / Float(mix.amountHealthy + mix.amountFailed)
                                    ProgressCircleOverlay(percentage: percentageHealthy, startingPoint: 0, color: .green)
                                    ProgressCircleOverlay(percentage: percentageFailed, startingPoint: percentageHealthy, color: .red)
                                    VStack {
                                        Text("\(mix.amountHealthy)/\(mix.amountHealthy + mix.amountFailed)").bold()
                                        Text("Checks").foregroundColor(.gray)
                                    }
                                }.frame(width: 90, height: 90, alignment: .center).padding(16).padding(.bottom)
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                        Group {
                            VStack {
                                HStack {
                                    Text("Network (Public)").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)
                                HStack {
                                    Text("\(controller.loadBalancer!.public_net.enabled ? "Enabled" : "Disabled")").bold().foregroundColor(controller.loadBalancer!.public_net.enabled ? .green : .red)
                                    Spacer()
                                }
                                HStack {
                                    Text("IPv4: ") + Text("\(controller.loadBalancer!.public_net.ipv4.ip ?? "---")").bold()
                                    Spacer()
                                }
                                HStack {
                                    Text("IPv6: ") + Text("\(controller.loadBalancer!.public_net.ipv6.ip ?? "---")").bold()
                                    Spacer()
                                }
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                        Group {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Location").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)

                                Text("City: ") + Text("\(controller.loadBalancer!.location.city)").bold()
                                Text("Datacenter: ") + Text("\(controller.loadBalancer!.location.description)").bold()
                                Text("Country: ") + Text("\(controller.loadBalancer!.location.country)").bold()
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                    }.padding([.top, .bottom])
                    Group {
                        ProjectServerDetailOtherOptionsView(title: "Graphs") {
                            ProjectLoadBalancerDetailGraphsView(controller: .init(project: controller.project!, loadBalancer: controller.loadBalancer!))
                        }
                        ProjectServerDetailOtherOptionsView(title: "Targets") {
                            ProjectLoadBalancerDetailTargetView(controller: .init(project: controller.project!, loadBalancer: controller.loadBalancer!))
                        }
                        ProjectServerDetailOtherOptionsView(title: "Services") {
                            ProjectLoadBalancerDetailServicesView(controller: .init(project: controller.project!, loadBalancer: controller.loadBalancer!))
                        }
                        ProjectServerDetailOtherOptionsView(title: "Networking") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Rescale") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Delete") {
                            Text("Destination")
                        }
                    }
                }.padding()
            }.navigationBarTitle(Text("\(controller.loadBalancer!.name)"))
        } else {
            Text("Oh no... Something went really wrong. Please try again.")
        }
    }
}

struct ProjectLoadBalancerDetailHealthStatusBadge: View {
    var mix: ProjectLoadBalancerDetailHealthCheckMix = .init(amountHealthy: 0, amountFailed: 0)
    var showNumbers: Bool = false
    var body: some View {
        Group {
            if mix.amountFailed == 0 && mix.amountHealthy > 0 {
                HStack {
                    Image(systemName: "checkmark").foregroundColor(.white)
                    Text("\(showNumbers ? "\(mix.amountHealthy)/\(mix.amountHealthy + mix.amountFailed)" : "Healthy")").foregroundColor(.white)
                }.padding(6).background(Color.green).cornerRadius(12)
            } else if mix.amountFailed > 0 && mix.amountHealthy > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle").foregroundColor(.white)
                    Text("\(showNumbers ? "\(mix.amountHealthy)/\(mix.amountHealthy + mix.amountFailed)" : "Mixed")").foregroundColor(.white)
                }.padding(6).background(Color.orange).cornerRadius(12)
            } else if mix.amountFailed > 0 && mix.amountHealthy == 0 {
                HStack {
                    Image(systemName: "xmark.circle").foregroundColor(.white)
                    Text("\(showNumbers ? "\(mix.amountHealthy)/\(mix.amountHealthy + mix.amountFailed)" : "Unhealthy")").foregroundColor(.white)
                }.padding(6).background(Color.red).cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "questionmark.circle").foregroundColor(.white)
                    Text("\(showNumbers ? "\(mix.amountHealthy)/\(mix.amountHealthy + mix.amountFailed)" : "Unknown")").foregroundColor(.white)
                }.padding(6).background(Color.gray).cornerRadius(12)
            }
        }
    }
}

struct ProgressCircleOverlay: View {
    var percentage: Float
    var startingPoint: Float
    var color: Color

    var body: some View {
        Circle()
            .trim(from: CGFloat(startingPoint), to: CGFloat(min(self.percentage + startingPoint, 1.0)))
            .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
            .foregroundColor(color)
            .rotationEffect(Angle(degrees: 270.0))
            .animation(.linear(duration: 0.5))
    }
}

class ProjectLoadBalancerDetailController: ObservableObject {
    @Published var project: CloudProject?
    @Published var loadBalancer: CloudLoadBalancer?

    init(project: CloudProject, loadBalancer: CloudLoadBalancer) {
        self.project = project
        self.loadBalancer = loadBalancer
    }

    func getHealthCheckMix() -> ProjectLoadBalancerDetailHealthCheckMix {
        var healthyChecks = 0
        var unhealthyChecks = 0

        for target in loadBalancer!.targets {
            healthyChecks += target.health_status.filter { $0.status == "healthy" }.count
            unhealthyChecks += target.health_status.filter { $0.status == "unhealthy" }.count
        }

        return .init(amountHealthy: healthyChecks, amountFailed: unhealthyChecks)
    }

    func getCertificateCount() -> Int {
        var certcount = 0
        for service in loadBalancer!.services {
            certcount += service.http?.certificates.count ?? 0
        }
        return certcount
    }

    func getMonthlyPrice() -> Double {
        return Double(loadBalancer!.type.prices.first(where: { $0.location == loadBalancer!.location.name })!.price_monthly.gross)!
    }
}

struct ProjectLoadBalancerDetailHealthCheckMix {
    var amountHealthy: Int
    var amountFailed: Int
}
