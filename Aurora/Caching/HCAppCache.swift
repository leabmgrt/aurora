//
// Aurora
// File created by Lea Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import Foundation
import RealmSwift

class HCAppCache {
    static let `default` = HCAppCache()

    func saveProject(_ project: CloudProject) {
        if cloudAppPreventNetworkActivityUseSampleData { return }
        do {
            let realm = try Realm()

            let object = RealmCloudProject()
            object.assign(project)

            let existingObjectList = realm.objects(RealmCloudProject.self).filter {
                $0.id == project.id.uuidString
            }

            if let existingObject = existingObjectList.first {
                try realm.write {
                    realm.delete(existingObject)
                }
            }
            try realm.write {
                realm.add(object)
            }
        } catch {
            // TODO: Error Handling
        }
    }

    func loadProjects() -> [CloudProject] {
        if cloudAppPreventNetworkActivityUseSampleData { return [.example] }
        do {
            let realm = try Realm()
            let existingObjects = realm.objects(RealmCloudProject.self)
            let projects: [CloudProject] = Array(existingObjects).map { $0.toProject() }
			var uniqueProjects: [CloudProject] = []
			for project in projects {
				if uniqueProjects.first(where: { $0.id == project.id }) == nil {
					uniqueProjects.append(project)
				}
			}
			
            return uniqueProjects
        } catch {
            // TODO: Error Handling
            return []
        }
    }

    func removeProject(_ project: CloudProject) {
        if cloudAppPreventNetworkActivityUseSampleData { return }
        do {
            let realm = try Realm()

            let existingObjectList = realm.objects(RealmCloudProject.self).filter {
                $0.id == project.id.uuidString
            }

            try realm.write {
                realm.delete(existingObjectList)
            }
        } catch {
            // TODO: Error Handling
        }
    }
}
