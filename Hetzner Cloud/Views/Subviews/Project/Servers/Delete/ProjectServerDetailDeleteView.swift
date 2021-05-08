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

struct ProjectServerDetailDeleteView: View {
    @ObservedObject var controller: ProjectServerDetailDeleteController
    @Environment(\.colorScheme) var colorScheme
    @State var showingFinalAlert = false

    var body: some View {
        if controller.project != nil && controller.server != nil {
            ScrollView {
                AppReadOnlyDisclaimerView()
                Group {
                    Group {
                        VStack(alignment: .leading) {
                            Text("Wait wait wait...").bold().font(.title)
                            Text("Are you sure you want to delete this server? Like, absolutely sure? The server will be stopped immediately and all data and backups will be ") + Text("gone.").bold()
                            Text("\nSeriously, the data will be gone forever. We'll keep snapshots of your server but if you don't have any, your data will be deleted, gone, destroyed and melted using flamethrowers 🔥\n(ok I'm not sure about the last part but you know what I mean).")
                            Text("\n(And if you want to prank a friend by deleting their server, this is a terrible prank.)")
                            Text("\n\nIf you want to proceed, click the button below.")

                            Button(action: {
                                showingFinalAlert = true
                            }, label: {
                                Text("Delete Server").bold().padding().foregroundColor(.white).background(controller.server!.protection.delete ? Color(UIColor.systemGray2) : Color.red).cornerRadius(7)
                            }).disabled(controller.server!.protection.delete).padding([.top, .bottom])
                            if controller.server!.protection.delete {
                                Text("This server is protected, this means you can't delete it right now. To delete the server, please remove the protection. If you already removed it, reload the page.").foregroundColor(.gray).font(.caption)
                            }
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading)
                }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding().navigationBarTitle(Text("Delete"))
            }.alert(isPresented: $showingFinalAlert, content: {
                Alert(title: Text("Are you absolutely sure?"), message: Text("Are you really sure you want to delete \"\(controller.server!.name)\"? We are not responsible for any data loss."), primaryButton: .destructive(Text("Delete"), action: {
                    print("delete")
                }), secondaryButton: .cancel(Text("Cancel").foregroundColor(.blue)))
            })
        } else {
            Text("hmm. Something went wrong. Please load this page again, maybe it'll work next time :/")
        }
    }
}

class ProjectServerDetailDeleteController: ObservableObject {
    @Published var project: CloudProject?
    @Published var server: CloudServer?

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }
}

struct ProjectServerDetailDeleteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectServerDetailDeleteView(controller: .init(project: .example, server: .example))
        }
    }
}
