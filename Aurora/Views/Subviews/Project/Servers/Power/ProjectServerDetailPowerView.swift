//
// Aurora
// File created by Adrian Baumgart on 03.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//
import SwiftUI

struct ProjectServerDetailPowerView: View {
    @ObservedObject var controller: ProjectServerDetailPowerController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            AppReadOnlyDisclaimerView()
            
            FloatingCardBackgroundView {
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
            }.padding()

            FloatingCardBackgroundView {
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
            }.padding()
        }.navigationBarTitle(Text("Power"))
    }
}

struct ProjectServerDetailPowerView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailPowerView(controller: .init(project: .example, server: .example))
    }
}

class ProjectServerDetailPowerController: ObservableObject {
    @Published var project: CloudProject
    @Published var server: CloudServer

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }
}

struct AppReadOnlyDisclaimerView: View {
    var body: some View {
        Group {
            Text("Currently the app is read-only. This will change with a future update. Until then, the buttons below won't do anything ;)").foregroundColor(.white).padding()
        }.background(Rectangle().fill(Color.accentColor)).cornerRadius(12).padding([.leading, .trailing]).padding([.top, .bottom], 4)
    }
}
