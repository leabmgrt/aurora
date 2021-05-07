//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 07.05.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI

struct LegalNoticeView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("Information in accordance with Section 5 TMG").bold().font(.headline).padding(.bottom)
                Text("Adrian Baumgart\nKarl-Gehrig-Straße 2\n69226 Nußloch\nGermany").padding(.bottom)
                Text("Contact Information").bold().font(.headline)
                HStack {
                    Text("Telephone:")
                    Button {
                        let url = URL(string: "tel:+4915165909306")!
                        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
                    } label: {
                        Text("+4915165909306").underline()
                    }
                }
                HStack {
                    Text("E-Mail:")
                    Button {
                        let url = URL(string: "mailto:adrian@abmgrt.dev")!
                        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
                    } label: {
                        Text("adrian@abmgrt.dev").underline()
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(16).navigationTitle(Text("Legal Notice"))
    }
}

struct LegalNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        LegalNoticeView()
    }
}
