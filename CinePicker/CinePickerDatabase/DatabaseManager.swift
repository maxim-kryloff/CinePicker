import CoreData
import Foundation

class DatabaseManager {
    
    private static var instance: DatabaseManager?
    
    public static var shared: DatabaseManager {
        if instance == nil {
            instance = DatabaseManager()
        }
        return instance!
    }
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "CinePickerDatabase")
        persistentContainer.loadPersistentStores { (_, error) in
            if let err = error as NSError? {
                fatalError("Unresolved DB error \(err), \(err.userInfo).")
            }
        }
    }
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func getEntityDescription(forEntity coreDataEntity: DatabaseEntity) -> NSEntityDescription {
        guard let description = NSEntityDescription.entity(forEntityName: coreDataEntity.rawValue, in: self.viewContext) else {
            fatalError("Couldn't get entity description for '\(coreDataEntity.rawValue)'.")
        }
        return description
    }
    
    public func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                fatalError("Could't save into context. \(error), \(error.userInfo).")
            }
        }
    }
}
