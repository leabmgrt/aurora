//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import Foundation
import SwiftyJSON

public struct HCAPIError: Error {
    var type: HCAPIErrorType
    var message: String
    var details: String

    init(_ json: JSON) {
        type = HCAPIErrorType(rawValue: json["error"]["code"].string!) ?? .unknown
        message = json["error"]["message"].string!
        details = json["error"]["details"].rawString() ?? "*app error*"
    }

    init(type: HCAPIErrorType, message: String, details: String) {
        self.type = type
        self.message = message
        self.details = details
    }
}

enum HCAPIErrorType: String {
    case forbidden
    case invalid_input
    case json_error
    case locked
    case not_found
    case rate_limit_exceeded
    case resource_limit_exceeded
    case service_error
    case uniqueness_error
    case protected
    case maintenance
    case conflict
    case unsupported_error
    case token_readonly
    case unknown
}
