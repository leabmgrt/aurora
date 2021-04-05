//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 03.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//
import SwiftUI

struct ProjectServerDetailPowerView: View {
    
    @ObservedObject var controller: ProjectServerDetailPowerController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if controller.project != nil && controller.server != nil {
            ScrollView {
                Group {
                    Group {
                        VStack(alignment: .leading) {
                            Text("Power").bold().font(.title)
                            Text("Welcome to the ✨ power menu ✨. There are multiple things you can do here.")
                            Text("\n\"Attempt shutdown\" will send an ACPI signal to your server. If your server is using a standard configuration, it will do a soft shutdown.")
                            Text("\n\"Power off\" will do a hard shutdown of your server, the same as pulling the power cord. This action may cause data loss. (Which is probably bad)")
                            Text("\nPlease note that powered down servers are still billed. If you don't need your server, delete it.")

                            Button(action: {}, label: {
                                Text("Attempt shutdown").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                            }).padding(.top)
                            Button(action: {}, label: {
                                Text("Power off").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                            })
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading)
                }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding().navigationBarTitle(Text("Power"))

                Group {
                    Group {
                        VStack(alignment: .leading) {
                            Text("Power Reset").bold().font(.title)
                            Text("\"Power cycle\" will issue a hard reset for your server. This action may cause data loss.")

                            Button(action: {}, label: {
                                Text("Power cycle").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                            }).padding(.top)
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading)
                }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding().navigationBarTitle(Text("Power"))
            }
        } else {
            Text("hmm... Something went wrong. Please load this page again, maybe it'll work next time :/")
        }
    }
}

struct ProjectServerDetailPowerView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailPowerView(controller: .init(project: .example, server: .example))
    }
}

class ProjectServerDetailPowerController: ObservableObject {
    @Published var project: CloudProject?
    @Published var server: CloudServer?

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }
}
