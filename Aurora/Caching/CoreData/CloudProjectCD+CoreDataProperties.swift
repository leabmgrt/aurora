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

import Foundation
import CoreData


extension CloudProjectCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CloudProjectCD> {
        return NSFetchRequest<CloudProjectCD>(entityName: "CloudProjectCD")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var apikeyReferrer: String?

}

extension CloudProjectCD : Identifiable {

}
