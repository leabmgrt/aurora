//
// Aurora
// File created by Lea Baumgart on 29.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import CoreData
import Foundation
import UIKit

class HCAppCache {
    static let `default` = HCAppCache()

    func saveProject(_ project: CloudProject) {
        if cloudAppPreventNetworkActivityUseSampleData { return }
        removeProject(project)
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            appDelegate.persistentContainer.performBackgroundTask { managedContext in
                let entity = NSEntityDescription.entity(forEntityName: "CloudProjectCD", in: managedContext)
                let newProject = NSManagedObject(entity: entity!, insertInto: managedContext)

                newProject.setValue(project.id.uuidString, forKey: "id")
                newProject.setValue(project.name, forKey: "name")
                newProject.setValue(project.apikeyReferrer, forKey: "apikeyReferrer")

                do {
                    try managedContext.save()
                } catch {
                    print("failed saving to CoreData")
                }
            }
        }
    }

    func loadProjects() -> [CloudProject] {
        if cloudAppPreventNetworkActivityUseSampleData { return [.example] }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CloudProjectCD")
        request.returnsObjectsAsFaults = false

        do {
            let result = try managedContext.fetch(request)
            var projects = [CloudProject]()

            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: "id") as! String
                let name = data.value(forKey: "name") as! String
                let apikeyReferrer = data.value(forKey: "apikeyReferrer") as! String

                projects.append(CloudProject(id: UUID(uuidString: id)!, name: name, apikeyReferrer: apikeyReferrer, persistentInstance: true))
            }

            var uniqueProjects: [CloudProject] = []
            for project in projects {
                if uniqueProjects.first(where: { $0.id == project.id }) == nil {
                    uniqueProjects.append(project)
                }
            }

            return uniqueProjects
        } catch {
            print("failed to fetch data from CoreData")
            return []
        }
    }

    func removeProject(_ project: CloudProject) {
        if cloudAppPreventNetworkActivityUseSampleData { return }

        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            appDelegate.persistentContainer.performBackgroundTask { managedContext in
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CloudProjectCD")
                request.predicate = NSPredicate(format: "id = %@", project.id.uuidString)
                request.returnsObjectsAsFaults = false

                do {
                    // let managedContext = appDelegate.persistentContainer.viewContext

                    let result = try managedContext.fetch(request)
                    for data in result as! [NSManagedObject] {
                        managedContext.delete(data)
                        try managedContext.save()
                    }
                } catch {
                    print("failed fetching data from CoreData")
                }
            }
        }
    }
}
