//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 26.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import Foundation
import SwiftyJSON

struct HetznerDatacenter {
    var id: String
    var name: String
    var description: String
    var location: HetznerDatacenterLocation
    var server_types: HetznerDatacenterServerTypes

    init(_ json: JSON) {
        id = "\(json["id"].int!)"
        name = json["name"].string!
        description = json["description"].string!
        location = .init(json["location"])
        server_types = .init(json["server_types"])
    }
}

struct HetznerDatacenterLocation {
    var id: String
    var name: String
    var description: String
    var country: String
    var city: String
    var latitude: Double
    var longitude: Double
    var network_zone: String

    init(_ json: JSON) {
        id = "\(json["id"].int!)"
        name = json["name"].string!
        description = json["description"].string!
        country = json["country"].string!
        city = json["city"].string!
        latitude = json["latitude"].double!
        longitude = json["longitude"].double!
        network_zone = json["network_zone"].string!
    }
}

struct HetznerDatacenterServerTypes {
    var supported: [Int]
    var available: [Int]
    var available_for_migration: [Int]

    init(_ json: JSON) {
        supported = json["supported"].arrayValue.map { $0.intValue }
        available = json["available"].arrayValue.map { $0.intValue }
        available_for_migration = json["available_for_migration"].arrayValue.map { $0.intValue }
    }
}
