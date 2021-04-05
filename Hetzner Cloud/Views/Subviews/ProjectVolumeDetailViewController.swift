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

class ProjectVolumeDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
}

struct ProjectVolumeDetailView: View {
    @ObservedObject var controller: ProjectVolumeDetailController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if controller.project != nil && controller.volume != nil {
            ScrollView {
                Group {
                    Group {
                        HStack(alignment: .top) {
                            HStack(alignment: .center) {
                                Circle().foregroundColor(controller.volume!.status == .available ? .green : .orange).frame(width: 25, height: 25, alignment: .center).shadow(color: controller.volume!.status == .available ? .green : .orange, radius: 3, x: 0, y: 0)
                                Text("\(controller.volume!.status.rawValue)").bold()
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                if controller.volume!.protection.delete {
                                    HStack {
                                        Text("Locked").foregroundColor(.gray).italic()
                                        Image(systemName: "lock").foregroundColor(.gray)
                                    }
                                }
                                if controller.volume!.server != nil {
                                    HStack {
                                        Text("Attached to: ") + Text("\(controller.project!.servers.first(where: { $0.id == controller.volume!.server! })?.name ?? "unknown")").bold()
                                        Image(systemName: "externaldrive.badge.checkmark").foregroundColor(.green)
                                    }
                                } else {
                                    HStack {
                                        Text("Not attached").foregroundColor(.gray).italic()
                                        Image(systemName: "externaldrive.badge.xmark").foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], alignment: .center, spacing: 10, pinnedViews: [], content: {
                        Group {
                            VStack {
                                HStack {
                                    Text("Configuration").bold().font(.title3)
                                    Spacer()
                                }.padding(.bottom)
                                HStack(alignment: .top) {
                                    Image(systemName: "folder")
                                    Text("Path: ") + Text("\(controller.volume!.linux_device)").bold()
                                    Spacer()
                                }
                                HStack(alignment: .top) {
                                    Image(systemName: "internaldrive")
                                    Text("\(Int(controller.volume!.size))").bold() + Text(" GB")
                                    Spacer()
                                }
                                HStack(alignment: .top) {
                                    Image(systemName: "wrench.and.screwdriver")
                                    // Text("\(String(format: "%.2f", Double(controller.server!.server_type.prices.first!.price_monthly.gross)!))/mo")
                                    Text("Format: ") + Text("\(controller.volume!.format ?? "not formatted")").bold()
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

                                Text("City: ") + Text("\(controller.volume!.location.city)").bold()
                                Text("Datacenter: ") + Text("\(controller.volume!.location.description)").bold()
                                Text("Country: ") + Text("\(controller.volume!.location.country)").bold()
                            }
                        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)
                    }).padding([.top, .bottom])
                }.padding()
            }.navigationBarTitle(Text(controller.volume!.name))
        } else {
            Text("Something went wrong, please try again :/")
        }
    }
}

class ProjectVolumeDetailController: ObservableObject {
    @Published var project: CloudProject?
    @Published var volume: CloudVolume?

    init(project: CloudProject, volume: CloudVolume) {
        self.project = project
        self.volume = volume
    }
}
