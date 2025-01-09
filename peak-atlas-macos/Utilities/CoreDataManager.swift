//
//  CoreDataManager.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 05/11/24.
//

import Foundation
import CoreData
import AppKit

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer
    private var selectedCopiedItem: CopiedItem?

    init() {
        persistentContainer = NSPersistentContainer(name: "CopiedItem")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchCopiedItem() -> [CopiedItem] {
        let fetchRequest: NSFetchRequest<CopiedItem> = CopiedItem.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch people: \(error)")
            return []
        }
    }
    
    func fetchItemCollection() -> [ItemCollection] {
        let fetchRequest: NSFetchRequest<ItemCollection> = ItemCollection.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch people: \(error)")
            return []
        }
    }
    
    func addCopiedItem(id: UUID, itemId: Int, content: String, arrayContent: String, type: Int, isFavorite: Bool, timeStamp: Date, source: String, icon: String) {
        let copiedItem = CopiedItem(context: context)
        copiedItem.id = id
        copiedItem.itemId = Int32(itemId)
        if type == 1 {
            copiedItem.content = content
        } else if type == 2 {
            copiedItem.content = arrayContent
        }
        copiedItem.content = content
        copiedItem.type = Int32(type) // 1 = nonfile path, 2 = file path
        copiedItem.isFavorite = isFavorite
        copiedItem.timestamp = timeStamp
        copiedItem.source = source
        copiedItem.icon = icon
        copiedItem.collectionId = Int32(0)
        copiedItem.copiedFrequency = Int32(1)
        saveContext()
    }
    
    func copiedMultipleTimes(itemToUpdate: CopiedItem) {
        itemToUpdate.copiedFrequency += 1
        saveContext()
    }
    
    func addItemCollection(name: String) {
        let itemCollection = ItemCollection(context: context)
        itemCollection.collectionId = Int32(fetchItemCollection().count+1)
        itemCollection.collectionName = name
        saveContext()
    }
    
    func addItemToCollection(itemToUpdate: CopiedItem, collectionId: Int) {
        itemToUpdate.collectionId = Int32(collectionId)
        saveContext()
    }
    
    func toggleFavorite(itemToUpdate: CopiedItem) {
        if let itemToUpdate = fetchItemByTimeStamp(timestamp: itemToUpdate.timestamp ?? Date()) {
            // Update attributes programmatically without any bindings
            itemToUpdate.isFavorite = !itemToUpdate.isFavorite
            saveContext()
            print("CopiedItem updated!")
        } else {
            print("CopiedItem not found.")
        }
        saveContext()
    }
    
    func fetchItemByTimeStamp(timestamp: Date) -> CopiedItem? {
        let fetchRequest: NSFetchRequest<CopiedItem> = CopiedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "timestamp == %@", timestamp as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first // Return the first match, if any
        } catch {
            print("Failed to fetch CopiedItem: \(error)")
            return nil
        }
    }
    
    func clearAllData() {
        // Access the Core Data managed object context
        let context = context
        
        // Get all entities in the Core Data model
        guard let entities = context.persistentStoreCoordinator?.managedObjectModel.entities else { return }
        
        // Loop through each entity and delete its objects
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name ?? "")
            fetchRequest.includesPropertyValues = false // Optimizes performance by not fetching property data
            
            do {
                let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                objects?.forEach { context.delete($0) }
            } catch {
                print("Failed to fetch or delete objects for entity \(entity.name ?? ""): \(error)")
            }
        }
        
        // Save context to persist deletions
        do {
            try context.save()
        } catch {
            print("Failed to save context after deleting all data: \(error)")
        }
    }
    
    func deleteItem(content: String) {
        // Create a fetch request for the entity you want to delete from
        let fetchRequest: NSFetchRequest<CopiedItem> = CopiedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "content == %@", content)
        
        do {
            // Fetch the objects that match the predicate
            let objects = try context.fetch(fetchRequest)
            
            for object in objects {
                // Delete each object that matches the fetch request
                context.delete(object)
            }
            
            // Save the context to persist the deletion
            try context.save()
            print("Item(s) deleted successfully.")
            
        } catch let error as NSError {
            print("Could not delete item(s): \(error), \(error.userInfo)")
        }
    }
    
    func exportJSONToFile() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CopiedItem")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            // Convert Core Data objects to JSON format
            let jsonArray = results.map { object -> [String: Any] in
                var dict: [String: Any] = [:]
                for attribute in object.entity.attributesByName {
                    let attributeName = attribute.key
                    let attributeValue = object.value(forKey: attributeName)
                    
                    if let dateValue = attributeValue as? Date {
                        // Convert Date to ISO8601 string
                        let dateFormatter = ISO8601DateFormatter()
                        dict[attributeName] = dateFormatter.string(from: dateValue)
                    } else if let uuidValue = attributeValue as? UUID {
                        // Convert UUID to String
                        dict[attributeName] = uuidValue.uuidString
                    } else {
                        // Add other attributes directly
                        dict[attributeName] = attributeValue
                    }
                }
                return dict
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            
            // Open NSSavePanel to select the file location
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["json"]
            panel.nameFieldStringValue = "ExportedData.json"
            
            panel.begin { result in
                if result == .OK, let fileURL = panel.url {
                    do {
                        // Write JSON data to the selected file
                        try jsonData.write(to: fileURL)
                        print("JSON file saved to \(fileURL.path)")
                    } catch {
                        print("Failed to save JSON to file: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    func importJSONUsingFileBrowser(completion: @escaping() -> Void) {
        let context = persistentContainer.viewContext

        // Create an NSOpenPanel instance
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["json"]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Select JSON File to Import"
        
        // Display the panel
        panel.begin { result in
            if result == .OK, let fileURL = panel.url {
                do {
                    // Read the JSON file
                    let data = try Data(contentsOf: fileURL)
                    guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                        print("Invalid JSON format")
                        return
                    }

                    let dateFormatter = ISO8601DateFormatter()

                    // Import each JSON object into Core Data
                    for jsonDict in jsonArray {
                        let entity = NSEntityDescription.insertNewObject(forEntityName: "CopiedItem", into: context)

                        for (key, value) in jsonDict {
                            if let stringValue = value as? String, let dateValue = dateFormatter.date(from: stringValue) {
                                // Convert ISO8601 date strings to Date objects
                                entity.setValue(dateValue, forKey: key)
                            } else if let uuidString = value as? String, let uuidValue = UUID(uuidString: uuidString) {
                                // Convert UUID strings to UUID objects
                                entity.setValue(uuidValue, forKey: key)
                            } else {
                                // Set other values directly
                                entity.setValue(value, forKey: key)
                            }
                        }
                    }

                    // Save the context
                    try context.save()
                    print("Data successfully imported from \(fileURL.lastPathComponent).")
                    completion()
                } catch {
                    print("Failed to import JSON: \(error)")
                }
            } else {
                print("User cancelled file selection.")
            }
        }
    }
}

extension CoreDataManager {
    
}
