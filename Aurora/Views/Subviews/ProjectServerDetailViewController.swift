//
//  ProjectServerDetailViewController.swift
//  Hetzner Cloud
//
//  Created by Adrian Baumgart on 27.03.21.
//

import SwiftUI
import UIKit

class ProjectServerDetailViewController: UIViewController {
    var controller: ProjectServerDetailController?
    var hostingController: UIHostingController<ProjectServerDetailView>?
    var server: CloudServer? {
        didSet {
            if controller != nil {
                controller?.server = server
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        controller = .init()
        controller!.server = server
        hostingController = .init(rootView: ProjectServerDetailView(controller: controller!))
        view.addSubview(hostingController!.view)

        hostingController!.view.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(8)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
        }

        // Do any additional setup after loading the view.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

struct ProjectServerDetailView: View {
    @ObservedObject var controller: ProjectServerDetailController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            Group {
                Group {
                    HStack(alignment: .center) {
                        Circle().foregroundColor(getServerStatusColor()).frame(width: 25, height: 25, alignment: .center).shadow(color: getServerStatusColor(), radius: 3, x: 0, y: 0)
                        Text("\(controller.server!.status.rawValue)").bold()
                        Spacer()
                        Toggle(isOn: .constant(controller.server!.status != .off), label: {
                            Text("")
                        })

                    }.padding(.bottom)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], alignment: .center, spacing: nil, pinnedViews: [], content: {
                    Group {
                        VStack {
                            HStack {
                                Text("Configuration (\(controller.server!.server_type.name))").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)
                            HStack {
                                Image(systemName: "cpu")
                                Text("\(Int(controller.server!.server_type.cores)) VCPU\(controller.server!.server_type.cores != 1 ? "s" : "")")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "memorychip")
                                Text("\(Int(controller.server!.server_type.memory)) GB RAM")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "internaldrive")
                                Text("\(Int(controller.server!.server_type.disk)) GB DISK (\(controller.server!.server_type.storage_type.rawValue.lowercased()))")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "eurosign.circle")
                                Text("\(String(format: "%.2f", Double(controller.server!.server_type.prices.first!.price_monthly.gross)!))/mo")
                                Spacer()
                            }
                        }
                    }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                    Group {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Network (Public)").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)

                            Text("IPv4: ") + Text("\(controller.server!.public_net.ipv4.ip)").bold()
                            Text("IPv6: ") + Text("\(controller.server!.public_net.ipv6.ip)").bold()
                        }
                    }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                    Group {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Location").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)

                            Text("City: ") + Text("\(controller.server!.datacenter.location.city)").bold()
                            Text("Datacenter: ") + Text("\(controller.server!.datacenter.location.description)").bold()
                            Text("Country: ") + Text("\(controller.server!.datacenter.location.country)").bold()
                        }
                    }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                }).padding([.top, .bottom])
                Group {
                    Group {
                        ProjectServerDetailOtherOptionsView(title: "Graphs") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Backups") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Snapshots") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Load Balancers") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Networking") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Firewalls") {
                            Text("Destination")
                        }
                        ProjectServerDetailOtherOptionsView(title: "Volumes") {
                            Text("Destination")
                        }
                    }
                    Group {
                        ProjectServerDetailOtherOptionsView(title: "Power") {
                            Text("Destination")
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
                            Text("Destination")
                        }
                    }
                }
            }.padding()
        }.navigationBarTitle(Text("\(controller.server?.name ?? "")"))
        /* if controller.server != nil {
             GeometryReader(content: { geometry in
                 ScrollView {
                     Group {
                         HStack {
                             Circle().foregroundColor(getServerStatusColor()).frame(width: 25, height: 25, alignment: .center)
                             Text("\(controller.server!.status.rawValue)").bold()
                             Spacer()
                             Toggle(isOn: .constant(controller.server!.status != .off), label: {
                                 Text("")
                             })

                         }.padding(.bottom)
                         Group {
                             VStack {
                                 HStack {
                                     Text("Configuration (\(controller.server!.server_type.name))").bold().font(.title3)
                                     Spacer()
                                 }.padding(.bottom)
                                 HStack {
                                     Image(systemName: "cpu")
                                     Text("\(Int(controller.server!.server_type.cores)) VCPU\(controller.server!.server_type.cores != 1 ? "s" : "")")
                                     Spacer()
                                 }
                                 HStack {
                                     Image(systemName: "memorychip")
                                     Text("\(Int(controller.server!.server_type.memory)) GB RAM")
                                     Spacer()
                                 }
                                 HStack {
                                     Image(systemName: "externaldrive")
                                     Text("\(Int(controller.server!.server_type.disk)) GB DISK (\(controller.server!.server_type.storage_type.rawValue.lowercased()))")
                                     Spacer()
                                 }
                                 HStack {
                                     Image(systemName: "eurosign.circle")
                                     Text("\(String(format: "%.2f", Double(controller.server!.server_type.prices.first!.price_monthly.gross)!))/mo")
                                     Spacer()
                                 }
                             }
                         }.padding().frame(width: geometry.size.width, alignment: .center).background(Rectangle().fill(colorScheme == .dark ? Color.init(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color.init(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                         Group {
                             VStack(alignment: .leading) {
                                 HStack {
                                     Text("Network (Public)").bold().font(.title3)
                                     Spacer()
                                 }.padding(.bottom)

                                 Text("IPv4: ") + Text("\(controller.server!.public_net.ipv4.ip)").bold()
                                 Text("IPv6: ") + Text("\(controller.server!.public_net.ipv6.ip)").bold()

                             }
                         }.padding().frame(width: geometry.size.width, alignment: .center).background(Rectangle().fill(colorScheme == .dark ? Color.init(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color.init(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding([.top, .bottom])

                         Group {
                             VStack(alignment: .leading) {
                                 HStack {
                                     Text("Location").bold().font(.title3)
                                     Spacer()
                                 }.padding(.bottom)

                                 Text("City: ") + Text("\(controller.server!.datacenter.location.city)").bold()
                                 Text("Datacenter: ") + Text("\(controller.server!.datacenter.location.description)").bold()
                                 Text("Country: ") + Text("\(controller.server!.datacenter.location.country)").bold()

                             }
                         }.padding().frame(width: geometry.size.width, alignment: .center).background(Rectangle().fill(colorScheme == .dark ? Color.init(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color.init(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding(.bottom)
                         //List {
                         Group {
                             Group {
                                 ProjectServerDetailOtherOptionsView(title: "Graphs") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Backups") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Snapshots") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Load Balancers") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Networking") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Firewalls") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Volumes") {
                                     Text("Destination")
                                 }
                             }
                             Group {
                                 ProjectServerDetailOtherOptionsView(title: "Power") {
                                     Text("Destination")
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
                                     Text("Destination")
                                 }
                             }

                         }
                     }
                 }
             }).padding()
         }
         else {
             Text("hi")
         }*/

        /* ScrollView {
             if controller.server != nil {
                 GeometryReader(content: { geometry in
                     Group {
                         HStack {
                             Circle().foregroundColor(getServerStatusColor()).frame(width: 25, height: 25, alignment: .center)
                             Text("\(controller.server!.status.rawValue)").bold()
                             Spacer()
                             Toggle(isOn: .constant(controller.server!.status != .off), label: {
                                 Text("")
                             })

                         }.padding(.bottom)
                         Group {
                             VStack {
                                 HStack {
                                     Text("Configuration (\(controller.server!.server_type.name))").bold().font(.title3)
                                     Spacer()
                                 }.padding(.bottom)
                                 HStack {
                                     Image(systemName: "cpu")
                                     Text("\(Int(controller.server!.server_type.cores)) VCPU\(controller.server!.server_type.cores != 1 ? "s" : "")")
                                     Spacer()
                                 }
                                 HStack {
                                     Image(systemName: "memorychip")
                                     Text("\(Int(controller.server!.server_type.memory)) GB RAM")
                                     Spacer()
                                 }
                                 HStack {
                                     Image(systemName: "externaldrive")
                                     Text("\(Int(controller.server!.server_type.disk)) GB DISK (\(controller.server!.server_type.storage_type.rawValue.lowercased()))")
                                     Spacer()
                                 }
                                 HStack {
                                     Image(systemName: "eurosign.circle")
                                     Text("\(String(format: "%.2f", Double(controller.server!.server_type.prices.first!.price_monthly.gross)!))/mo")
                                     Spacer()
                                 }
                             }
                         }.padding().frame(width: geometry.size.width, alignment: .center).background(Rectangle().fill(colorScheme == .dark ? Color.init(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color.init(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)

                         Group {
                             VStack(alignment: .leading) {
                                 HStack {
                                     Text("Network (Public)").bold().font(.title3)
                                     Spacer()
                                 }.padding(.bottom)

                                 Text("IPv4: ") + Text("\(controller.server!.public_net.ipv4.ip)").bold()
                                 Text("IPv6: ") + Text("\(controller.server!.public_net.ipv6.ip)").bold()

                             }
                         }.padding().frame(width: geometry.size.width, alignment: .center).background(Rectangle().fill(colorScheme == .dark ? Color.init(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color.init(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding([.top, .bottom])

                         Group {
                             VStack(alignment: .leading) {
                                 HStack {
                                     Text("Location").bold().font(.title3)
                                     Spacer()
                                 }.padding(.bottom)

                                 Text("City: ") + Text("\(controller.server!.datacenter.location.city)").bold()
                                 Text("Datacenter: ") + Text("\(controller.server!.datacenter.location.description)").bold()
                                 Text("Country: ") + Text("\(controller.server!.datacenter.location.country)").bold()

                             }
                         }.padding().frame(width: geometry.size.width, alignment: .center).background(Rectangle().fill(colorScheme == .dark ? Color.init(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color.init(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding(.bottom)
                         //List {
                         Group {
                             Group {
                                 ProjectServerDetailOtherOptionsView(title: "Graphs") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Backups") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Snapshots") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Load Balancers") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Networking") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Firewalls") {
                                     Text("Destination")
                                 }
                                 ProjectServerDetailOtherOptionsView(title: "Volumes") {
                                     Text("Destination")
                                 }
                             }
                             Group {
                                 ProjectServerDetailOtherOptionsView(title: "Power") {
                                     Text("Destination")
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
                                     Text("Destination")
                                 }
                             }

                         }
                     }//.padding()
                     //}.listStyle(PlainListStyle()).frame(width: geometry.size.width, height: geometry.size.height - 50)
                 })
             }
             else {
                 Text("")
             }
         } */
        /* GeometryReader(content: { geometry in
             ScrollView {

             }.navigationBarTitle(Text("\(controller.server?.name ?? "")"))
         })
         .padding() */
        /* NavigationView {

         }.navigationViewStyle(StackNavigationViewStyle()) */
    }

    func getServerStatusColor() -> Color {
        switch controller.server?.status {
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
        default:
            return .gray
        }
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
            ProjectServerDetailView(controller: .init())
        }.navigationViewStyle(StackNavigationViewStyle())
            .previewDevice("iPad Pro (12.9-inch) (4th generation)")
        // .preferredColorScheme(.dark)
    }
}

class ProjectServerDetailController: ObservableObject {
    @Published var server: CloudServer? = CloudProject.example.servers.first!
}
