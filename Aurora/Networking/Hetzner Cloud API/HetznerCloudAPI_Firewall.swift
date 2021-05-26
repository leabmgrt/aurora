//
// Aurora
// File created by Lea Baumgart on 29.03.21.
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
    func loadFirewalls(callback: @escaping (Result<[CloudFirewall], HCAPIError>) -> Void) {
        if cloudAppPreventNetworkActivityUseSampleData { return callback(.success([.example])) }
        if isASEC { return callback(.success([])) }

        loadFirewallNetworkCall(page: nil) { [self] firstResponse in
            if let error = responseCheck(firstResponse) {
                return callback(.failure(error))
            } else {
                let json = JSON(firstResponse.data!)
                var firewalls: [CloudFirewall] = json["firewalls"].arrayValue.map { CloudFirewall($0) }
                let lastPage = json["meta"]["pagination"]["last_page"].int!
                if lastPage > 1 {
                    let dispatchGroup = DispatchGroup()

                    for page in 2 ... lastPage {
                        dispatchGroup.enter()
                        loadFirewallNetworkCall(page: page) { firewallResponse in
                            if let error2 = responseCheck(firewallResponse) {
                                dispatchGroup.leave()
                                return callback(.failure(error2))
                            } else {
                                let json2 = JSON(firewallResponse.data!)
                                firewalls.append(contentsOf: json2["firewalls"].arrayValue.map { CloudFirewall($0) })
                                dispatchGroup.leave()
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        return callback(.success(firewalls))
                    }
                } else {
                    return callback(.success(firewalls))
                }
            }
        }
    }

    private func loadFirewallNetworkCall(page: Int?, callback: @escaping (AFDataResponse<Any>) -> Void) {
        AF.request("https://api.hetzner.cloud/v1/firewalls?per_page=50\(page != nil ? "&page=\(page!)" : "")", headers: [
            "Authorization": "Bearer \(apikey!)",
        ]).responseJSON { response in
            callback(response)
        }
    }
}
