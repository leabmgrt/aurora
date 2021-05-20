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
import SwiftKeychainWrapper
import SwiftyJSON

public struct CloudProject {
    var id = UUID()
    var name: String
    var apikeyReferrer: String
    var servers: [CloudServer]
    var volumes: [CloudVolume]
    var floatingIPs: [CloudFloatingIP]
    var firewalls: [CloudFirewall]
    var networks: [CloudNetwork]
    var loadBalancers: [CloudLoadBalancer]
    var api: HetznerCloudAPI?

    init(id: UUID = UUID(), name: String, apikeyReferrer: String? = nil, apikey: String = "", servers: [CloudServer] = [], volumes: [CloudVolume] = [], floatingIPs: [CloudFloatingIP] = [], firewalls: [CloudFirewall] = [], networks: [CloudNetwork] = [], loadBalancers: [CloudLoadBalancer] = [], persistentInstance: Bool) {
        self.id = id
        self.name = name
        self.apikeyReferrer = apikeyReferrer ?? ""
        self.servers = servers
        self.volumes = volumes
        self.floatingIPs = floatingIPs
        self.firewalls = firewalls
        self.networks = networks
        self.loadBalancers = loadBalancers
        if apikeyReferrer == nil, persistentInstance { saveKey(apikey, updateCache: persistentInstance) }
        if persistentInstance { saveToCache() }
        api = .init(self)
    }

    static let example: CloudProject = .init(name: "Project 1", servers: [.example], volumes: [.example], floatingIPs: [.example], firewalls: [.example], networks: [.example], loadBalancers: [.example], persistentInstance: false)

    func saveToCache() {
        if cloudAppPreventNetworkActivityUseSampleData { return }
        HCAppCache.default.saveProject(self)
    }

    func delete() {
        if cloudAppPreventNetworkActivityUseSampleData { return }
        KeychainWrapper.standard.removeObject(forKey: apikeyReferrer)
        HCAppCache.default.removeProject(self)
    }

    mutating func saveKey(_ key: String, updateCache: Bool = true) {
        if cloudAppPreventNetworkActivityUseSampleData { return }
        if apikeyReferrer != "" {
            KeychainWrapper.standard.removeObject(forKey: apikeyReferrer) // Remove existing key if the referrer isn't nil
        }

        apikeyReferrer = "" // Temporarily set the referrer to nothing

        var stopCheckingForFreeUUID = false
        var newReferrer = ""

        while !stopCheckingForFreeUUID { // Loop to prevent accidentally overwriting any other keys/data (use unique referrer)
            newReferrer = UUID().uuidString
            stopCheckingForFreeUUID = !KeychainWrapper.standard.hasValue(forKey: newReferrer) // Stops checking if there's no value for the new uuid
        }

        KeychainWrapper.standard.set(key, forKey: newReferrer) // save key in keychain
        apikeyReferrer = newReferrer // Set new referrer
        if updateCache { HCAppCache.default.saveProject(self) } // Update cache
        api = .init(self) // Update API
    }

    func loadKey() -> String {
        return KeychainWrapper.standard.string(forKey: apikeyReferrer) ?? ""
    }
}
