//
// Aurora
// File created by Lea Baumgart on 28.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Foundation
import SwiftyJSON

struct CloudVolume {
    var id: Int
    var created: Date
    var name: String
    var server: Int?
    var location: CloudVolumeLocation
    var size: Double
    var linux_device: String
    var protection: CloudVolumeProtection
    var labels: [String: String]
    var status: CloudVolumeStatus
    var format: String?

    init(_ json: JSON) {
        id = json["id"].int!
        created = ISO8601DateFormatter().date(from: json["created"].string!)!
        name = json["name"].string!
        server = json["server"].int
        location = .init(json["location"])
        size = json["size"].double!
        linux_device = json["linux_device"].string!
        protection = .init(json["protection"])
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
        status = CloudVolumeStatus(rawValue: json["status"].string!)!
        format = json["format"].string
    }

    static let example: CloudVolume = {
        let json = ExampleJSON.cloudVolume
        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudVolume = CloudVolume(parsedJSON!)
        return cloudVolume
    }()
}

struct CloudVolumeLocation {
    var id: Double
    var name: String
    var description: String
    var country: String
    var city: String
    var latitude: Double
    var longitude: Double
    var network_zone: String

    init(_ json: JSON) {
        id = json["id"].double!
        name = json["name"].string!
        description = json["description"].string!
        country = json["country"].string!
        city = json["city"].string!
        latitude = json["latitude"].double!
        longitude = json["longitude"].double!
        network_zone = json["network_zone"].string!
    }
}

struct CloudVolumeProtection {
    var delete: Bool

    init(_ json: JSON) {
        delete = json["delete"].bool!
    }
}

enum CloudVolumeStatus: String {
    case creating, available
}
