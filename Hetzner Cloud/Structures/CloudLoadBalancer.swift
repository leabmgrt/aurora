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

struct CloudLoadBalancer {
    var id: Int
    var name: String
    var public_net: CloudLoadBalancerPublicNet
    var private_net: [CloudLoadBalancerPrivateNet]
    var location: CloudLoadBalancerLocation
    var type: CloudLoadBalancerType
    var protection: CloudLoadBalancerProtection
    var labels: [String: String]
    var created: Date
    var services: [CloudLoadBalancerService]
    var targets: [CloudLoadBalancerTarget]
    var algorithm: CloudLoadBalancerAlgorithm
    var outgoing_traffic: Int?
    var ingoing_traffic: Int?
    var included_traffic: Int

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
        public_net = .init(json["public_net"])
        private_net = json["private_net"].arrayValue.map { CloudLoadBalancerPrivateNet($0) }
        location = .init(json["location"])
        type = .init(json["load_balancer_type"])
        protection = .init(json["protection"])
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
        created = ISO8601DateFormatter().date(from: json["created"].string!)!
        services = json["services"].arrayValue.map { CloudLoadBalancerService($0) }
        targets = json["targets"].arrayValue.map { CloudLoadBalancerTarget($0) }
        algorithm = .init(json["algorithm"])
        outgoing_traffic = json["outgoing_traffic"].int
        ingoing_traffic = json["ingoing_traffic"].int
        included_traffic = json["included_traffic"].int!
    }

    static let example: CloudLoadBalancer = {
        let json = ExampleJSON.cloudLoadBalancer

        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudLoadBalancer = CloudLoadBalancer(parsedJSON!)
        return cloudLoadBalancer
    }()
}

struct CloudLoadBalancerPublicNet {
    var enabled: Bool
    var ipv4: CloudLoadBalancerPublicNetIPv4
    var ipv6: CloudLoadBalancerPublicNetIPv6

    init(_ json: JSON) {
        enabled = json["enabled"].bool!
        ipv4 = .init(json["ipv4"])
        ipv6 = .init(json["ipv6"])
    }
}

struct CloudLoadBalancerPublicNetIPv4 {
    var ip: String?

    init(_ json: JSON) {
        ip = json["ip"].string
    }
}

struct CloudLoadBalancerPublicNetIPv6 {
    var ip: String?

    init(_ json: JSON) {
        ip = json["ip"].string
    }
}

struct CloudLoadBalancerPrivateNet {
    var network: Int
    var ip: String

    init(_ json: JSON) {
        network = json["network"].int!
        ip = json["ip"].string!
    }
}

struct CloudLoadBalancerLocation {
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

struct CloudLoadBalancerType {
    var id: Double
    var name: String
    var description: String
    var max_connections: Double
    var max_services: Double
    var max_targets: Double
    var max_assigned_certificates: Double
    var deprecated: String?
    var prices: [CloudLoadBalancerTypePrice]

    init(_ json: JSON) {
        id = json["id"].double!
        name = json["name"].string!
        description = json["description"].string!
        max_connections = json["max_connections"].double!
        max_services = json["max_services"].double!
        max_targets = json["max_targets"].double!
        max_assigned_certificates = json["max_assigned_certificates"].double!
        deprecated = json["deprecated"].string
        prices = json["prices"].arrayValue.map { CloudLoadBalancerTypePrice($0) }
    }
}

struct CloudLoadBalancerTypePrice {
    var location: String
    var price_hourly: CloudLoadBalancerTypePriceValues
    var price_monthly: CloudLoadBalancerTypePriceValues

    init(_ json: JSON) {
        location = json["location"].string!
        price_hourly = .init(json["price_hourly"])
        price_monthly = .init(json["price_monthly"])
    }
}

struct CloudLoadBalancerTypePriceValues {
    var net: String
    var gross: String

    init(_ json: JSON) {
        net = json["net"].string!
        gross = json["gross"].string!
    }
}

struct CloudLoadBalancerProtection {
    var delete: Bool

    init(_ json: JSON) {
        delete = json["delete"].bool!
    }
}

struct CloudLoadBalancerService {
    var `protocol`: CloudLoadBalancerServiceProtocol
    var listen_port: Int
    var destination_port: Int
    var proxyprotocol: Bool
    var health_check: CloudLoadBalancerServiceHealthCheck
    var http: CloudLoadBalancerServiceHTTP

    init(_ json: JSON) {
        self.protocol = CloudLoadBalancerServiceProtocol(rawValue: json["protocol"].string!)!
        listen_port = json["listen_port"].int!
        destination_port = json["destination_port"].int!
        proxyprotocol = json["proxyprotocol"].bool!
        health_check = .init(json["health_check"])
        http = .init(json["http"])
    }
}

struct CloudLoadBalancerServiceHealthCheck {
    var `protocol`: CloudLoadBalancerServiceHealthCheckProtocol
    var port: Int
    var timeout: Int
    var retries: Int
    var http: CloudLoadBalancerServiceHealthCheckHTTP

    init(_ json: JSON) {
        self.protocol = CloudLoadBalancerServiceHealthCheckProtocol(rawValue: json["protocol"].string!)!
        port = json["port"].int!
        timeout = json["timeout"].int!
        retries = json["retries"].int!
        http = .init(json["http"])
    }
}

struct CloudLoadBalancerServiceHealthCheckHTTP {
    var domain: String?
    var path: String
    var response: String
    var status_codes: [String]
    var tls: Bool

    init(_ json: JSON) {
        domain = json["domain"].string
        path = json["path"].string!
        response = json["response"].string!
        status_codes = json["status_codes"].arrayValue.map { $0.stringValue }
        tls = json["tls"].bool!
    }
}

struct CloudLoadBalancerServiceHTTP {
    var cookie_name: String
    var cookie_lifetime: Int
    var certificates: [Int]
    var redirect_http: Bool
    var sticky_sessions: Bool

    init(_ json: JSON) {
        cookie_name = json["cookie_name"].string!
        cookie_lifetime = json["cookie_lifetime"].int!
        certificates = json["certificates"].arrayValue.map { $0.intValue }
        redirect_http = json["redirect_http"].bool!
        sticky_sessions = json["sticky_sessions"].bool!
    }
}

struct CloudLoadBalancerTarget {
    var type: CloudLoadBalancerTargetType
    var server: CloudLoadBalancerTargetServer
    var health_status: [CloudLoadBalancerTargetHealthStatus]
    var use_private_ip: Bool
    var label_selector: CloudLoadBalancerTargetLabelSelector
    var ip: CloudLoadBalancerTargetIP
    var targets: [CloudLoadBalancerTargetTarget]

    init(_ json: JSON) {
        type = CloudLoadBalancerTargetType(rawValue: json["type"].string!)!
        server = .init(json["server"])
        health_status = json["health_status"].arrayValue.map { CloudLoadBalancerTargetHealthStatus($0) }
        use_private_ip = json["use_private_ip"].bool!
        label_selector = .init(json["label_selector"])
        ip = .init(json["ip"])
        targets = json["targets"].arrayValue.map { CloudLoadBalancerTargetTarget($0) }
    }
}

struct CloudLoadBalancerTargetServer {
    var id: Int

    init(_ json: JSON) {
        id = json["id"].int!
    }
}

struct CloudLoadBalancerTargetHealthStatus {
    var listen_port: Int
    var status: String

    init(_ json: JSON) {
        listen_port = json["listen_port"].int!
        status = json["status"].string!
    }
}

struct CloudLoadBalancerTargetLabelSelector {
    var selector: String

    init(_ json: JSON) {
        selector = json["selector"].string!
    }
}

struct CloudLoadBalancerTargetIP {
    var ip: String

    init(_ json: JSON) {
        ip = json["ip"].string!
    }
}

struct CloudLoadBalancerTargetTarget {
    var type: String
    var server: CloudLoadBalancerTargetTargetServer
    var health_status: [CloudLoadBalancerTargetTargetHealthStatus]
    var use_private_ip: Bool

    init(_ json: JSON) {
        type = json["type"].string!
        server = .init(json["server"])
        health_status = json["health_status"].arrayValue.map { CloudLoadBalancerTargetTargetHealthStatus($0) }
        use_private_ip = json["use_private_ip"].bool!
    }
}

struct CloudLoadBalancerTargetTargetServer {
    var id: Int

    init(_ json: JSON) {
        id = json["id"].int!
    }
}

struct CloudLoadBalancerTargetTargetHealthStatus {
    var listen_port: Int
    var status: String

    init(_ json: JSON) {
        listen_port = json["listen_port"].int!
        status = json["status"].string!
    }
}

struct CloudLoadBalancerAlgorithm {
    var type: CloudLoadBalancerAlgorithmType

    init(_ json: JSON) {
        type = CloudLoadBalancerAlgorithmType(rawValue: json["type"].string!)!
    }
}

enum CloudLoadBalancerAlgorithmType: String {
    case round_robin, least_connections
}

enum CloudLoadBalancerServiceProtocol: String {
    case tcp, http, https
}

enum CloudLoadBalancerServiceHealthCheckProtocol: String {
    case tcp, http
}

enum CloudLoadBalancerTargetType: String {
    case server, label_selector, ip
}
