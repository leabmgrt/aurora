//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import Alamofire
import Foundation
import SwiftyJSON

extension HetznerCloudAPI {
    func loadServers(callback: @escaping (Result<[CloudServer], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([.example])) }

        loadServerNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var servers: [CloudServer] = json["servers"].arrayValue.map { CloudServer($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()

                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadServerNetworkCall(page: page) { serverResponse in
                            if let error2 = responseCheck(serverResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(serverResponse.data!)
                                servers.append(contentsOf: json2["servers"].arrayValue.map { CloudServer($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(servers))
                    }
                } else {
                    return callback(.success(servers))
                }
            }
        }
    }

    private func loadServerNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/servers?per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }

    func loadServerBackups(_ serverId: Int, callback: @escaping (Result<[CloudServerImage], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([])) }

        loadServerBackupsNetworkCall(page: nil, server: serverId) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var backups: [CloudServerImage] = json["images"].arrayValue.map { CloudServerImage($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()
                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadServerBackupsNetworkCall(page: page, server: serverId) { backupResponse in
                            if let error2 = responseCheck(backupResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(backupResponse.data!)
                                backups.append(contentsOf: json2["images"].arrayValue.map { CloudServerImage($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(backups))
                    }
                } else {
                    return callback(.success(backups))
                }
            }
        }
    }

    private func loadServerBackupsNetworkCall(page: Int?, server: Int, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/images?type=backup&bound_to=\(server)&per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }

    func loadServerSnapshots(_ serverId: Int?, callback: @escaping (Result<[CloudServerImage], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([])) }

        loadServerSnapshotsNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var snapshots: [CloudServerImage] = json["images"].arrayValue.map { CloudServerImage($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()
                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadServerSnapshotsNetworkCall(page: page) { snapshotResponse in
                            if let error2 = responseCheck(snapshotResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(snapshotResponse.data!)
                                snapshots.append(contentsOf: json2["images"].arrayValue.map { CloudServerImage($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        let filteredSnapshots = (serverId != nil) ? snapshots.filter { $0.created_from!.id == serverId! } : snapshots
                        return callback(.success(filteredSnapshots))
                    }
                } else {
                    let filteredSnapshots = (serverId != nil) ? snapshots.filter { $0.created_from!.id == serverId! } : snapshots
                    return callback(.success(filteredSnapshots))
                }
            }
        }
    }

    private func loadServerSnapshotsNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/images?type=snapshot&per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }

    func loadServerMetrics(_ id: Int, minutes: Int, step: Int = 1000, callback: @escaping (Result<CloudServerMetrics, HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success(.example)) }

        let isoDateSubtracted = ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())!)
        let isoDateCurrent = ISO8601DateFormatter().string(from: Date())

        AF.request("https://api.hetzner.cloud/v1/servers/\(id)/metrics?type=cpu,disk,network&start=\(isoDateSubtracted)&end=\(isoDateCurrent)&step=\(step)", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { [self] response in
            if let error = responseCheck(response) {
                return callback(.failure(error))
            } else {
                let json = JSON(response.data!)
                let metrics = CloudServerMetrics(json["metrics"])
                return callback(.success(metrics))
            }
        }
    }
}
