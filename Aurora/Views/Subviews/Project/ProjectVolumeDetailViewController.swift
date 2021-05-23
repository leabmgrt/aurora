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

struct ProjectVolumeDetailView: View {
    @ObservedObject var controller: ProjectVolumeDetailController

    var body: some View {
        ScrollView {
            Group {
                Group {
                    HStack(alignment: .top) {
                        HStack(alignment: .center) {
                            Circle().foregroundColor(controller.volume.status == .available ? .green : .orange).frame(width: 25, height: 25, alignment: .center).shadow(color: controller.volume.status == .available ? .green : .orange, radius: 3, x: 0, y: 0)
                            Text("\(controller.volume.status.rawValue)").bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            if controller.volume.protection.delete {
                                HStack {
                                    Text("Locked").foregroundColor(.gray).italic()
                                    Image(systemName: "lock").foregroundColor(.gray)
                                }
                            }
                            if controller.volume.server != nil {
                                HStack {
                                    Text("Attached to: ") + Text("\(controller.project.servers.first(where: { $0.id == controller.volume.server! })?.name ?? "unknown")").bold()
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350), alignment: .top)], alignment: .center, spacing: 10, pinnedViews: [], content: {
                    FloatingCardBackgroundView {
                        VStack {
                            HStack {
                                Text("Configuration").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)
                            HStack(alignment: .top) {
                                Image(systemName: "folder").frame(width: 20)
                                Text("Path: ") + Text("\(controller.volume.linux_device)").bold()
                                Spacer()
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "internaldrive").frame(width: 20)
                                Text("\(Int(controller.volume.size))").bold() + Text(" GB")
                                Spacer()
                            }
                            HStack(alignment: .top) {
                                Image(systemName: "wrench.and.screwdriver").frame(width: 20)
                                // Text("\(String(format: "%.2f", Double(controller.server!.server_type.prices.first!.price_monthly.gross)!))/mo")
                                Text("Format: ") + Text("\(controller.volume.format ?? "not formatted")").bold()
                                Spacer()
                            }
                        }
                    }

                    FloatingCardBackgroundView {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Location").bold().font(.title3)
                                Spacer()
                            }.padding(.bottom)

                            Text("City: ") + Text("\(controller.volume.location.city)").bold()
                            Text("Datacenter: ") + Text("\(controller.volume.location.description)").bold()
                            Text("Country: ") + Text("\(controller.volume.location.country)").bold()
                        }
                    }
                }).padding([.top, .bottom])
            }.padding()
        }.navigationBarTitle(Text(controller.volume.name))
    }
}

class ProjectVolumeDetailController: ObservableObject {
    @Published var project: CloudProject
    @Published var volume: CloudVolume

    init(project: CloudProject, volume: CloudVolume) {
        self.project = project
        self.volume = volume
    }
}
