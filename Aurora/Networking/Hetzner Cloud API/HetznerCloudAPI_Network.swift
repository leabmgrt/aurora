//
// Aurora
// File created by Lea Baumgart on 04.04.21.
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
    func loadNetworks(callback: @escaping (Result<[CloudNetwork], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([.example])) }

        loadNetworksNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var networks: [CloudNetwork] = json["networks"].arrayValue.map { CloudNetwork($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()

                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadNetworksNetworkCall(page: page) { networkResponse in
                            if let error2 = responseCheck(networkResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(networkResponse.data!)
                                networks.append(contentsOf: json2["networks"].arrayValue.map { CloudNetwork($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(networks))
                    }
                } else {
                    return callback(.success(networks))
                }
            }
        }
    }

    private func loadNetworksNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/networks?per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }
}
