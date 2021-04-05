//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 03.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import UIKit

class GlobalSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showError(_ error: HCAPIError) {
        EZAlertController.alert("Error: \(error.type.rawValue)", message: "\(error.message)\n\nDetails: \(error.details)")
    }
}
