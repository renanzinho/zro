//
//  CoreDataFacade.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import CoreData

class CoreDataService {
    public static var shared = CoreDataService()
    var user: User!

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var persistentContainer: NSPersistentContainer

    init() {
        let container: NSPersistentContainer = {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
             */
            let container = NSPersistentContainer(name: "zro")

            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                } else {
                    print(storeDescription)
                }
            })

            return container
        }()

        self.persistentContainer = container

        self.user = self.fetchAll()
    }

    // MARK: - Core Data Saving support
    func saveContext() throws {
        if context.hasChanges {
            do {
                try self.context.save()

            } catch let error as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                throw error
            }
        }
    }

    func fetchAll() -> User {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")

        do {
            let user = try context.fetch(fetchRequest)
            if let first = user.first {
                return first
            } else {
                let newUser = User(context: self.context)
                newUser.favoriteNewsURL = []
                return newUser
            }
        } catch {
            let newUser = User(context: self.context)
            newUser.favoriteNewsURL = []
            return newUser
        }
    }

    func insertUrl(_ url: String) {
        self.user.favoriteNewsURL?.append(url)

        do {
            try self.saveContext()
        } catch {
        }

    }

    func deleteUrl(_ url: String) {
        self.user.favoriteNewsURL = self.user.favoriteNewsURL?.filter({ $0 != url })
        do {
            try self.saveContext()
        } catch {
        }
    }

    func isFav(_ url: String) -> Bool {
        return self.user.favoriteNewsURL?.contains(url) ?? false
    }

}
