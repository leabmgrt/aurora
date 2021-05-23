//
// Aurora
// File created by Lea Baumgart on 07.05.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct UsedLibrariesView: View {
    var body: some View {
        List {
            ForEach(AppUsedLibraries.usedLibraries) { library in
                VStack(alignment: .leading) {
                    Text("\(library.name)").bold().font(.headline)
                    Text("\(library.url.absoluteString)").foregroundColor(.secondary).font(.footnote)
                }.padding(4).onTapGesture {
                    if UIApplication.shared.canOpenURL(library.url) { UIApplication.shared.open(library.url) }
                }
            }

            ForEach(Array(AppUsedLibraries.usedLibraries.enumerated()), id: \.offset) { index, library in
                Section(footer: (index == AppUsedLibraries.usedLibraries.count - 1) ? Text("Thank you to all maintainers of these libraries, you're awesome! ^^") : Text("")) {
                    VStack(alignment: .leading) {
                        Text("\(library.name)").bold().font(.headline)
                        Text("\(library.license)").foregroundColor(.secondary).font(.footnote)
                    }.padding(4)
                }
            }
        }.listStyle(InsetGroupedListStyle()).navigationTitle(Text("Used Libraries"))
    }
}

struct UsedLibrariesVieew_Previews: PreviewProvider {
    static var previews: some View {
        UsedLibrariesView()
    }
}
