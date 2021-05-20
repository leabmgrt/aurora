//
// Aurora
// File created by Adrian Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Alamofire
import Foundation
import SwiftKeychainWrapper
import SwiftyJSON

class HetznerCloudAPI {
    var project: CloudProject!
    var apikey: String!

    init(_ project: CloudProject) {
        self.project = project
        apikey = loadAPIKey()
    }

    private func loadAPIKey() -> String {
        return KeychainWrapper.standard.string(forKey: project.apikeyReferrer) ?? ""
    }

    func loadProject(callback: @escaping (Result<CloudProject, HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success(CloudProject(id: UUID(), name: "Project 1", apikeyReferrer: "ref", apikey: "", servers: [.example], volumes: [.example], floatingIPs: [.example], firewalls: [.example], networks: [.example], loadBalancers: [.example], persistentInstance: false))) }
        let dispatchGroup = DispatchGroup()

        var latestError: HCAPIError?

        dispatchGroup.enter()
        loadServers { [self] serverResult in
            switch serverResult {
            case let .success(servers):
                project.servers = servers
                project.servers.sort(by: { $0.name < $1.name })
                dispatchGroup.leave()
            case let .failure(serverError):
                latestError = serverError
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        loadFirewalls { [self] firewallResult in
            switch firewallResult {
            case let .success(firewalls):
                project.firewalls = firewalls
                project.firewalls.sort(by: { $0.name < $1.name })
                dispatchGroup.leave()
            case let .failure(firewallError):
                latestError = firewallError
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        loadVolumes { [self] volumeResult in
            switch volumeResult {
            case let .success(volumes):
                project.volumes = volumes
                project.volumes.sort(by: { $0.name < $1.name })
                dispatchGroup.leave()
            case let .failure(volumeError):
                latestError = volumeError
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        loadNetworks { [self] networkResult in
            switch networkResult {
            case let .success(networks):
                project.networks = networks
                project.networks.sort(by: { $0.name < $1.name })
                dispatchGroup.leave()
            case let .failure(networkError):
                latestError = networkError
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        loadFloatingIPs { [self] floatingipResult in
            switch floatingipResult {
            case let .success(floatingips):
                project.floatingIPs = floatingips
                project.floatingIPs.sort(by: { $0.name < $1.name })
                dispatchGroup.leave()
            case let .failure(floatingipError):
                latestError = floatingipError
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        loadLoadBalancers { [self] loadBalancerResult in
            switch loadBalancerResult {
            case let .success(loadBalancers):
                project.loadBalancers = loadBalancers
                project.loadBalancers.sort(by: { $0.name < $1.name })
                dispatchGroup.leave()
            case let .failure(loadBalancerError):
                latestError = loadBalancerError
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [self] in

            if latestError != nil {
                return callback(.failure(latestError!))
            } else {
                project.api = self
                project.api!.project = project
                return callback(.success(project))
            }
        }
    }

    func responseCheck(_ response: AFDataResponse<Any>) -> HCAPIError? {
        switch response.result {
        case .success:
            return checkJSONForError(response)
        case let .failure(err):
            return .init(type: .unknown, message: "The API request failed", details: err.localizedDescription)
        }
    }

    func checkJSONForError(_ response: AFDataResponse<Any>) -> HCAPIError? {
        if response.data == nil {
            return .init(type: .unknown, message: "The API didn't send any data", details: "")
        } else {
            let json = JSON(response.data!)
            if json["error"].exists() {
                return .init(json)
            } else {
                return nil
            }
        }
    }
}
