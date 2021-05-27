//
// Aurora
// File created by Lea Baumgart on 03.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import UIKit

class GlobalSplitViewController: UISplitViewController {
    public var loadedProjects = [CloudProject]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showError(_ error: HCAPIError) {
        EZAlertController.alert("Error: \(error.type.rawValue)", message: "\(error.message)\n\nDetails: \(error.details)")
    }
}
