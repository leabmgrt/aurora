//
// Aurora
// File created by Lea Baumgart on 03.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Alamofire
import Foundation
import SwiftyJSON

extension HetznerCloudAPI {
    func loadVolumes(callback: @escaping (Result<[CloudVolume], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([.example])) }

        loadVolumeNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var volumes: [CloudVolume] = json["volumes"].arrayValue.map { CloudVolume($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()

                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadVolumeNetworkCall(page: page) { volumeResponse in
                            if let error2 = responseCheck(volumeResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(volumeResponse.data!)
                                volumes.append(contentsOf: json2["volumes"].arrayValue.map { CloudVolume($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(volumes))
                    }
                } else {
                    return callback(.success(volumes))
                }
            }
        }
    }

    private func loadVolumeNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/volumes?per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }
}
