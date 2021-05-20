//
// Aurora
// File created by Adrian Baumgart on 28.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Foundation
import SwiftyJSON

struct CloudNetwork {
    var id: Int
    var name: String
    var ip_range: String
    var subnets: [CloudNetworkSubnet]
    var routes: [CloudNetworkRoute]
    var servers: [Int]
    var load_balancers: [Int]
    var protection: CloudNetworkProtection
    var labels: [String: String]
    var created: Date

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
        ip_range = json["ip_range"].string!
        subnets = json["subnets"].arrayValue.map { CloudNetworkSubnet($0) }
        routes = json["routes"].arrayValue.map { CloudNetworkRoute($0) }
        servers = json["servers"].arrayValue.map { $0.intValue }
        load_balancers = json["load_balancers"].arrayValue.map { $0.intValue }
        protection = .init(json["protection"])
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
        created = ISO8601DateFormatter().date(from: json["created"].string!)!
    }

    static let example: CloudNetwork = {
        let json = ExampleJSON.cloudNetwork

        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudNetwork = CloudNetwork(parsedJSON!)
        return cloudNetwork
    }()
}

struct CloudNetworkSubnet {
    var id = UUID()
    var type: CloudNetworkSubnetType
    var ip_range: String
    var network_zone: String
    var gateway: String

    init(_ json: JSON) {
        type = CloudNetworkSubnetType(rawValue: json["type"].string!)!
        ip_range = json["ip_range"].string!
        network_zone = json["network_zone"].string!
        gateway = json["gateway"].string!
    }
}

struct CloudNetworkRoute {
    var id = UUID()
    var destination: String
    var gateway: String

    init(_ json: JSON) {
        destination = json["destination"].string!
        gateway = json["gateway"].string!
    }
}

struct CloudNetworkProtection {
    var delete: Bool

    init(_ json: JSON) {
        delete = json["delete"].bool!
    }
}

enum CloudNetworkSubnetType: String {
    case cloud, server, vswitch
}
