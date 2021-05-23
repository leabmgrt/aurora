//
// Aurora
// File created by Lea Baumgart on 23.05.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct AppReadOnlyDisclaimerView: View {
    var body: some View {
        Group {
            Text("Currently the app is read-only. This will change with a future update. Until then, the buttons below won't do anything ;)").foregroundColor(.white).padding()
        }.background(Rectangle().fill(Color.accentColor)).cornerRadius(12).padding([.leading, .trailing]).padding([.top, .bottom], 4)
    }
}

struct AppReadOnlyDisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        AppReadOnlyDisclaimerView()
    }
}
