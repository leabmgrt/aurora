//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 05.04.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import Alamofire
import Foundation
import SwiftyJSON

extension HetznerCloudAPI {
    func loadLoadBalancers(callback: @escaping (Result<[CloudLoadBalancer], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([.example])) }

        loadLoadBalancerNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var loadBalancers: [CloudLoadBalancer] = json["load_balancers"].arrayValue.map { CloudLoadBalancer($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!

                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()

                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadLoadBalancerNetworkCall(page: page) { loadBalancerResponse in
                            if let error2 = responseCheck(loadBalancerResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(loadBalancerResponse.data!)
                                loadBalancers.append(contentsOf: json2["load_balancers"].arrayValue.map { CloudLoadBalancer($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(loadBalancers))
                    }
                } else {
                    return callback(.success(loadBalancers))
                }
            }
        }
    }

    private func loadLoadBalancerNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/load_balancers?per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }
}
