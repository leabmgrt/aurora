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

struct CloudFirewall {
    var id: Int
    var name: String
    var labels: [String: String]
    var created: Date
    var rules: [CloudFirewallRule]
    var applied_to: [CloudFirewallAppliedTo]

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
        created = ISO8601DateFormatter().date(from: json["created"].string!) ?? Date()
        rules = json["rules"].arrayValue.map { CloudFirewallRule($0) }
        applied_to = json["applied_to"].arrayValue.map { CloudFirewallAppliedTo($0) }
    }

    static let example: CloudFirewall = {
        let json = ExampleJSON.cloudFirewall

        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudFirewall = CloudFirewall(parsedJSON!)
        return cloudFirewall
    }()
}

struct CloudFirewallRule: Identifiable {
    var id = UUID()
    var direction: CloudFirewallRuleDirection
    var source_ips: [String]
    var destination_ips: [String]
    var `protocol`: CloudFirewallRuleProtocol
    var port: String?

    init(_ json: JSON) {
        direction = CloudFirewallRuleDirection(rawValue: json["direction"].string!)!
        source_ips = json["source_ips"].arrayValue.map { $0.stringValue }
        destination_ips = json["destination_ips"].arrayValue.map { $0.stringValue }
        self.protocol = CloudFirewallRuleProtocol(rawValue: json["protocol"].string!)!
        port = json["port"].string
    }
}

struct CloudFirewallAppliedTo {
    var type: CloudFirewallAppliedToType
    var server: CloudFirewallAppliedToServer

    init(_ json: JSON) {
        type = CloudFirewallAppliedToType(rawValue: json["type"].string!)!
        server = .init(json["server"])
    }
}

struct CloudFirewallAppliedToServer {
    var id: Double

    init(_ json: JSON) {
        id = json["id"].double!
    }
}

enum CloudFirewallRuleDirection: String {
    case `in`, out
}

enum CloudFirewallRuleProtocol: String {
    case tcp, udp, icmp
}

enum CloudFirewallAppliedToType: String {
    case server
}
