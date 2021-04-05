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

class ProjectFirewallDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
}

struct ProjectFirewallDetailView: View {
    @ObservedObject var controller: ProjectFirewallDetailController
    @State private var selectedView = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if controller.firewall != nil && controller.project != nil {
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Applied to: ").bold() + Text("\(controller.firewall!.applied_to.count) Resource\(controller.firewall!.applied_to.count != 1 ? "s" : "")")
                        if controller.firewall!.applied_to.count > 0 {
                            if controller.isFullyApplied() {
                                HStack {
                                    Image(systemName: "checkmark").foregroundColor(.white)
                                    Text("Fully applied").foregroundColor(.white)
                                }.padding(6).background(Color.green).cornerRadius(12)
                            }
                            else {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle").foregroundColor(.white)
                                    Text("Partially applied").foregroundColor(.white)
                                }.padding(6).background(Color.orange).cornerRadius(12)
                            }
                        }
                        else {
                            Text("Not applied").foregroundColor(.white).padding(6).background(Color.gray).cornerRadius(12)
                        }
                    }
                }
                Picker(selection: $selectedView, label: Text(""), content: {
                    Text("Rules").tag(0)
                    Text("Resources").tag(1)
                }).pickerStyle(SegmentedPickerStyle())
                if selectedView == 0 {
                    List {
                        Section(header: Text("Inbound")) {
                            if controller.firewall!.rules.filter({ $0.direction == .in }).count > 0 {
                                ForEach(controller.firewall!.rules.filter({ $0.direction == .in }), id: \.id) { (rule) in
                                    VStack(alignment: .leading) {
                                        Text("\(rule.protocol.rawValue.uppercased()) ").bold() + Text("\(rule.port != nil ? String(rule.port!) : "")")
                                        CloudFirewallTagView(ips: rule.source_ips)
                                    }
                                }
                            }
                            else {
                                Text("All inbound traffic will be dropped.").italic()
                            }
                        }
                        Section(header: Text("Outbound")) {
                            if controller.firewall!.rules.filter({ $0.direction == .out }).count > 0 {
                                ForEach(controller.firewall!.rules.filter({ $0.direction == .out }), id: \.id) { (rule) in
                                    VStack(alignment: .leading) {
                                        Text("\(rule.protocol.rawValue.uppercased()) ").bold() + Text("\(rule.port != nil ? String(rule.port!) : "")")
                                        CloudFirewallTagView(ips: rule.destination_ips)
                                    }
                                }
                            }
                            else {
                                Text("All outbound traffic is allowed.").italic()
                            }
                        }
                    }
                }
                else {
                    if controller.appliedServers().count != 0 {
                        List {
                            ForEach(controller.appliedServers(), id: \.id) { (appliedServer) in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Circle().foregroundColor(getServerStatusColor(appliedServer.status)).frame(width: 20, height: 20, alignment: .center).shadow(color: getServerStatusColor(appliedServer.status), radius: 3, x: 0, y: 0)
                                        Text("\(appliedServer.name) ").bold() + Text("(\(appliedServer.public_net.ipv4.ip))").foregroundColor(.gray).italic()
                                    }
                                    if appliedServer.public_net.firewalls.first(where: {$0.id == controller.firewall!.id})!.status == .pending {
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle").foregroundColor(.white)
                                            Text("Pending").foregroundColor(.white)
                                        }.padding(6).background(Color.orange).cornerRadius(12)
                                    }
                                    else {
                                        HStack {
                                            Image(systemName: "checkmark").foregroundColor(.white)
                                            Text("Applied").foregroundColor(.white)
                                        }.padding(6).background(Color.green).cornerRadius(12)
                                    }
                                }.padding([.top, .bottom], 4)
                            }
                        }
                    }
                    else {
                        VStack {
                            Spacer()
                            Text("No resources").bold().font(.title2)
                            Text("This firewall isn't applied to any resource").foregroundColor(.gray).padding(.top, 4)
                            Spacer()
                        }
                    }
                }
            }.padding().navigationBarTitle(Text("\(controller.firewall!.name)"))
        } else {
            Text("no data")
        }
    }
}

struct CloudFirewallTagView: View {
    var ips: [String]

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        } .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.ips, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.ips.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.ips.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String) -> some View {
        var newText: String = ""
        var isItalic: Bool = false
        if text == "0.0.0.0/0" {
            newText = "Any IPv4"
            isItalic = true
        }
        else if text == "::/0" {
            newText = "Any IPv6"
            isItalic = true
        }
        else {
            newText = text
            isItalic = false
        }
        
        if isItalic {
            return Text(newText)
                .italic()
                .padding(.all, 5)
                .font(.body)
                .background(Color(UIColor.systemGray3))
                .foregroundColor(Color.white)
                .cornerRadius(5)
        }
        else {
            return Text(newText)
                .padding(.all, 5)
                .font(.body)
                .background(Color(UIColor.systemGray3))
                .foregroundColor(Color.white)
                .cornerRadius(5)
        }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

class ProjectFirewallDetailController: ObservableObject {
    @Published var project: CloudProject? = nil
    @Published var firewall: CloudFirewall? = nil
    
    func isFullyApplied() -> Bool {
        let firewallAppliedToServerIDs: [Int] = firewall!.applied_to.map { Int($0.server.id ) }
        var isFullyApplied = true
        for server in project!.servers.filter({ firewallAppliedToServerIDs.contains($0.id) }) {
            if let serverfirewall = server.public_net.firewalls.first(where: { $0.id == firewall!.id}) {
                if serverfirewall.status == .pending { isFullyApplied = false }
            }
        }
        return isFullyApplied
    }
    
    func appliedServers() -> [CloudServer] {
        let firewallAppliedToServerIDs: [Int] = firewall!.applied_to.map { Int($0.server.id ) }
        return project!.servers.filter({ firewallAppliedToServerIDs.contains($0.id) })
    }
}

/* struct ProjectFirewallDetailView_Preview: PreviewProvider {
     static var previews: some View {
         NavigationView {
             ProjectFirewallDetailView(controller: .init())
         }
     }
 }
 */
