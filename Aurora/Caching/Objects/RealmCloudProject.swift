//
// Aurora
// File created by Adrian Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//
import Foundation
import RealmSwift

class RealmCloudProject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var apikeyReferrer: String = ""

    func assign(_ project: CloudProject) {
        id = project.id.uuidString
        name = project.name
        apikeyReferrer = project.apikeyReferrer
    }

    func toProject() -> CloudProject {
        return .init(id: UUID(uuidString: id)!, name: name, apikeyReferrer: apikeyReferrer, persistentInstance: true)
    }
}
