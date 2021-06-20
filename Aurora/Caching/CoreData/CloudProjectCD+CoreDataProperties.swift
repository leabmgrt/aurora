//
// Aurora
// File created by Adrian Baumgart on 20.06.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//
//

import CoreData
import Foundation

public extension CloudProjectCD {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CloudProjectCD> {
        return NSFetchRequest<CloudProjectCD>(entityName: "CloudProjectCD")
    }

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var apikeyReferrer: String?
}

extension CloudProjectCD: Identifiable {}
