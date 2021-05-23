//
// Aurora
// File created by Lea Baumgart on 21.05.21.
//
// Licensed under the MIT License
// Copyright © 2020 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct FloatingCardBackgroundView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
            content
        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2)
    }
}

struct FloatingCardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingCardBackgroundView {
            Text("")
        }
    }
}
