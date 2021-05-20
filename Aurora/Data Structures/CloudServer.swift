//
// Aurora
// File created by Adrian Baumgart on 26.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Foundation
import SwiftyJSON

// DOCUMENTATION: https://docs.hetzner.cloud/#servers-get-a-server

struct CloudServer {
    var id: Int
    var name: String
    let status: CloudServerStatus
    let created: Date
    var public_net: CloudServerPublicNet
    var private_net: [CloudServerPrivateNet]
    var server_type: CloudServerType
    var datacenter: HetznerDatacenter
    var image: CloudServerImage?
    var backups: [CloudServerImage]
    var iso: CloudServerISO?
    var rescue_enabled: Bool
    var locked: Bool
    var backup_window: String?
    var outgoing_traffic: Double?
    var ingoing_traffic: Double?
    var included_traffic: Double?
    var protection: CloudServerProtection
    var labels: [String: String]
    var volumes: [Int]
    var load_balancers: [Int]
    var primary_disk_size: Double

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
        status = CloudServerStatus(rawValue: json["status"].string!)!
        created = ISO8601DateFormatter().date(from: json["created"].string!)!
        public_net = .init(json["public_net"])
        private_net = json["private_net"].arrayValue.map { CloudServerPrivateNet($0) }
        server_type = .init(json["server_type"])
        datacenter = .init(json["datacenter"])
        image = json["image"] != .null ? .init(json["image"]) : nil
        backups = []
        iso = json["iso"] != .null ? .init(json["iso"]) : nil
        rescue_enabled = json["rescue_enabled"].bool!
        locked = json["locked"].bool!
        backup_window = json["backup_window"].string
        outgoing_traffic = json["outgoing_traffic"].double
        ingoing_traffic = json["ingoing_traffic"].double
        included_traffic = json["included_traffic"].double
        protection = .init(json["protection"])
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
        volumes = json["volumes"].arrayValue.map { $0.intValue }
        load_balancers = json["load_balancers"].arrayValue.map { $0.intValue }
        primary_disk_size = json["primary_disk_size"].double!
    }

    static let example: CloudServer = {
        let json = ExampleJSON.cloudServer

        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudServer = CloudServer(parsedJSON!["server"])
        return cloudServer
    }()
}

struct CloudServerPublicNet {
    var ipv4: CloudServerIPv4
    var ipv6: CloudServerIPv6
    var floatingIPs: [Int]
    var firewalls: [CloudServerFirewallApplied]

    init(_ json: JSON) {
        ipv4 = .init(json["ipv4"])
        ipv6 = .init(json["ipv6"])
        floatingIPs = json["ipv4"].arrayValue.map { $0.intValue }
        firewalls = json["firewalls"].arrayValue.map { CloudServerFirewallApplied($0) }
    }
}

struct CloudServerPrivateNet {
    var network: Int
    var ip: String
    var alias_ips: [String]
    var mac_address: String

    init(_ json: JSON) {
        network = json["network"].int!
        ip = json["ip"].string!
        alias_ips = json["alias_ips"].arrayValue.map { $0.stringValue }
        mac_address = json["mac_address"].string!
    }
}

struct CloudServerIPv4 {
    var ip: String
    var blocked: Bool
    var dns_ptr: String

    init(_ json: JSON) {
        ip = json["ip"].string!
        blocked = json["blocked"].bool!
        dns_ptr = json["dns_ptr"].string!
    }
}

struct CloudServerIPv6 {
    var ip: String
    var blocked: Bool
    var dns_ptr: [CloudServerIPv6DNS_PTR]?

    init(_ json: JSON) {
        ip = json["ip"].string!
        blocked = json["blocked"].bool!
        dns_ptr = json["dns_ptr"].exists() && !json["dns_ptr"].isEmpty ? json["dns_ptr"].arrayValue.map { CloudServerIPv6DNS_PTR($0) } : nil
    }
}

struct CloudServerIPv6DNS_PTR {
    var ip: String
    var dns_ptr: String

    init(_ json: JSON) {
        ip = json["ip"].string!
        dns_ptr = json["dns_ptr"].string!
    }
}

struct CloudServerFirewallApplied {
    var id: Int
    var status: CloudServerFirewallStatus

    init(_ json: JSON) {
        id = json["id"].int!
        status = CloudServerFirewallStatus(rawValue: json["status"].string!)!
    }
}

struct CloudServerType {
    var id: String
    var name: String
    var description: String
    var cores: Double
    var memory: Double
    var disk: Double
    var deprecated: Bool
    var prices: [CloudServerTypePrice]
    var storage_type: CloudServerTypeStorageType
    var cpu_type: CloudServerTypeCPUType

    init(_ json: JSON) {
        id = "\(json["id"].int!)"
        name = json["name"].string!
        description = json["description"].string!
        cores = json["cores"].double!
        memory = json["memory"].double!
        disk = json["disk"].double!
        deprecated = json["deprecated"].bool ?? false
        prices = json["prices"].arrayValue.map { CloudServerTypePrice($0) }
        storage_type = CloudServerTypeStorageType(rawValue: json["storage_type"].string!)!
        cpu_type = CloudServerTypeCPUType(rawValue: json["cpu_type"].string!)!
    }
}

struct CloudServerTypePrice {
    var location: String
    var price_hourly: CloudServerTypePriceValues
    var price_monthly: CloudServerTypePriceValues

    init(_ json: JSON) {
        location = json["location"].string!
        price_hourly = .init(json["price_hourly"])
        price_monthly = .init(json["price_monthly"])
    }
}

struct CloudServerTypePriceValues {
    var net: String
    var gross: String

    init(_ json: JSON) {
        net = json["net"].string!
        gross = json["gross"].string!
    }
}

struct CloudServerImage {
    var id: Int
    var type: CloudServerImageType
    var status: CloudServerImageStatus
    var name: String?
    var description: String
    var image_size: Double?
    var disk_size: Double
    var created: Date
    var created_from: CloudServerImageCreatedFrom?
    var bound_to: Int?
    var os_flavor: CloudServerImageOSFlavor
    var os_version: String?
    var rapid_deploy: Bool
    var protection: CloudServerImageProtection
    var deprecated: String?
    var labels: [String: String]

    init(_ json: JSON) {
        id = json["id"].int!
        type = CloudServerImageType(rawValue: json["type"].string!)!
        status = CloudServerImageStatus(rawValue: json["status"].string!)!
        name = json["name"].string
        description = json["description"].string!
        image_size = json["image_size"].double
        disk_size = json["disk_size"].double!
        created = ISO8601DateFormatter().date(from: json["created"].string!)!
        created_from = json["created_from"] != .null ? .init(json["created_from"]) : nil
        bound_to = json["bound_to"].int
        os_flavor = CloudServerImageOSFlavor(rawValue: json["os_flavor"].string!)!
        os_version = json["os_version"].string
        rapid_deploy = json["rapid_deploy"].bool!
        protection = .init(json["protection"])
        deprecated = json["deprecated"].string
        labels = Dictionary(uniqueKeysWithValues: json["labels"].dictionaryValue.map { key, value in
            (key, value.stringValue)
        })
    }
}

struct CloudServerImageCreatedFrom {
    var id: Int
    var name: String

    init(_ json: JSON) {
        id = json["id"].int!
        name = json["name"].string!
    }
}

struct CloudServerImageProtection {
    var delete: Bool

    init(_ json: JSON) {
        delete = json["delete"].bool!
    }
}

struct CloudServerISO {
    var id: String
    var name: String?
    var description: String
    var type: CloudServerISOType
    var deprecated: String?

    init(_ json: JSON) {
        id = "\(json["id"].int!)"
        name = json["name"].string
        description = json["description"].string!
        type = CloudServerISOType(rawValue: json["type"].string!)!
        deprecated = json["deprecated"].string
    }
}

struct CloudServerProtection {
    var delete: Bool
    var rebuild: Bool

    init(_ json: JSON) {
        delete = json["delete"].bool!
        rebuild = json["rebuild"].bool!
    }
}

struct CloudServerMetrics {
    var start: Date
    var end: Date
    var step: Double
    var time_series: [CloudServerMetricsTimeSeries]

    init(_ json: JSON) {
        let dateFormatter = ISO8601DateFormatter()
        start = dateFormatter.date(from: json["start"].string!.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression))!
        end = dateFormatter.date(from: json["end"].string!)!
        step = json["step"].double!
        time_series = json["time_series"].map { key, json in
            CloudServerMetricsTimeSeries(json, key: key)
        }
    }

    static let example: CloudServerMetrics = {
        let json = ExampleJSON.cloudServerMetrics

        let data = json.data(using: .utf8)
        let parsedJSON = try? JSON(data: data!)
        let cloudServerMetrics = CloudServerMetrics(parsedJSON!["metrics"])
        return cloudServerMetrics
    }()
}

struct CloudServerMetricsTimeSeries {
    var name: String
    var values: [CloudServerMetricsTimeSeriesValue]

    init(_ json: JSON, key: String) {
        name = key
        values = json["values"].arrayValue.map { CloudServerMetricsTimeSeriesValue($0) }
    }
}

struct CloudServerMetricsTimeSeriesValue {
    var date: Date
    var value: Double

    init(_ json: JSON) {
        date = Date(timeIntervalSince1970: TimeInterval(json[0].int!))
        value = Double(json[1].string!)!
    }
}

enum CloudServerStatus: String {
    case initializing, starting, running, stopping, off, deleting, rebuilding, migrating, unknown
}

enum CloudServerFirewallStatus: String {
    case applied, pending
}

enum CloudServerTypeStorageType: String {
    case local, network
}

enum CloudServerTypeCPUType: String {
    case shared, dedicated
}

enum CloudServerImageType: String {
    case system, snapshot, backup, temporary
}

enum CloudServerImageStatus: String {
    case available, creating
}

enum CloudServerImageOSFlavor: String {
    case ubuntu, centos, debian, fedora, unknown
}

enum CloudServerISOType: String {
    case `public`, `private`
}
