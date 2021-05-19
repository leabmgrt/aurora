//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 04.04.21.
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
    func loadFloatingIPs(callback: @escaping (Result<[CloudFloatingIP], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([.example])) }

        loadFloatingIPsNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var floatingIPs: [CloudFloatingIP] = json["floating_ips"].arrayValue.map { CloudFloatingIP($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()

                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadFloatingIPsNetworkCall(page: page) { floatingipResponse in
                            if let error2 = responseCheck(floatingipResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(floatingipResponse.data!)
                                floatingIPs.append(contentsOf: json2["floating_ips"].arrayValue.map { CloudFloatingIP($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(floatingIPs))
                    }
                } else {
                    return callback(.success(floatingIPs))
                }
            }
        }
    }

    private func loadFloatingIPsNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/floating_ips?per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }
}
