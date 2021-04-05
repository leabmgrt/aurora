//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 28.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import Foundation
import SwiftyJSON

struct CloudFloatingIP {
    var id: Int
    var name: String
    var description: String?
    var ip: String
    var type: CloudFloatingIPType
    var server: Int?
    var dns_ptr: [CloudFloatingIPDNS_PTR]
    var home_location: CloudFloatingIPHomeLocation
    var blocked: Bool
    var protection: CloudFloatingIPProtection
    var labels: [String: String]
    var created: Date

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
        description = json["description"].string
        ip = json["ip"].string!
        type = CloudFloatingIPType(rawValue: json["type"].string!)!
        server = json["server"].int
        dns_ptr = json["dns_ptr"].arrayValue.map { CloudFloatingIPDNS_PTR($0) }
        home_location = .init(json["home_location"])
        blocked = json["blocked"].bool!
        protection = .init(json["protection"])
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
        created = ISO8601DateFormatter().date(from: json["created"].string!)!
    }

    static let example: CloudFloatingIP = {
        let json = ExampleJSON.cloudFloatingIP
        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudFloatingIP = CloudFloatingIP(parsedJSON!)
        return cloudFloatingIP
    }()
}

struct CloudFloatingIPDNS_PTR {
    var ip: String
    var dns_ptr: String

    init(_ json: JSON) {
        ip = json["ip"].string!
        dns_ptr = json["dns_ptr"].string!
    }
}

struct CloudFloatingIPHomeLocation {
    var id: Int
    var name: String
    var description: String
    var country: String
    var city: String
    var latitude: Double
    var longitude: Double
    var network_zone: String

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
        description = json["description"].string!
        country = json["country"].string!
        city = json["city"].string!
        latitude = json["latitude"].double!
        longitude = json["longitude"].double!
        network_zone = json["network_zone"].string!
    }
}

struct CloudFloatingIPProtection {
    var delete: Bool

    init(_ json: JSON) {
        delete = json["delete"].bool!
    }
}

enum CloudFloatingIPType: String {
    case ipv4, ipv6
    
    func getHumanName() -> String {
        switch self {
        case .ipv4: return "IPv4"
        case .ipv6: return "IPv6"
        }
    }
}
