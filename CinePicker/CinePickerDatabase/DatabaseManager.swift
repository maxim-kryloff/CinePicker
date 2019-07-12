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
                fatalError("Unresolved DB error \(err), \(err.userInfo)")
            }
        }
    }
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return persistentContainer.persistentStoreCoordinator
    }
    
    public func getEntityDescription(forEntity coreDataEntity: DatabaseEntity) -> NSEntityDescription {
        guard let description = NSEntityDescription.entity(forEntityName: coreDataEntity.rawValue, in: self.viewContext) else {
            fatalError("Couldn't get entity description for '\(coreDataEntity.rawValue)' entity name")
        }
        
        return description
    }
    
    public func getFetchRequest(forEntity entity: DatabaseEntity) -> NSFetchRequest<NSManagedObject> {
        return NSFetchRequest<NSManagedObject>(entityName: entity.rawValue)
    }
    
    public func saveContext() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            fatalError("Can't write. \(error), \(error.userInfo)")
        }
    }
    
}
