//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 04.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI

struct ProjectServerDetailBackupsView: View {
    
    @ObservedObject var controller: ProjectServerDetailBackupsController
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if controller.project != nil && controller.server != nil {
            ScrollView {
                Group {
                    Group {
                        VStack(alignment: .leading) {
                            Text("Title").bold().font(.title)
                            Text("bla bla bla")
                            
                            Button(action: {}, label: {
                                Text("Run manual backup").bold().padding().foregroundColor(.white).background(Color.accentColor).cornerRadius(7)
                            }).padding(.top)
                            Button(action: {}, label: {
                                Text("Disable backups").bold().padding().foregroundColor(.white).background(Color.gray).cornerRadius(7)
                            })
                        }
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .topLeading)
                }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).padding().navigationBarTitle(Text("Backups"))
                /*Group {
                    ForEach([], id: \.id) { (backup) in
                        /*
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
                         }).frame(height: 36)*/
                        Text("a")
                    }
                }*/
            }
        }
        else {
            Text("Something went wrong, please try again :/")
        }
    }
}

class ProjectServerDetailBackupsController: ObservableObject {
    @Published var server: CloudServer? = nil
    @Published var project: CloudProject? = nil
    
    init(server: CloudServer, project: CloudProject) {
        self.server = server
        self.project = project
    }
}

struct ProjectServerDetailBackupsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectServerDetailBackupsView(controller: .init(server: .example, project: .example))
    }
}
