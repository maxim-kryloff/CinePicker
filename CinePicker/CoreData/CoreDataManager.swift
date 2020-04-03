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
                fatalError("Unresolved error \(err), \(err.userInfo)")
            }
        }
    }
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return persistentContainer.persistentStoreCoordinator
    }
    
    public func getEntityDescription(forEntity coreDataEntity: CoreDataEntity) -> NSEntityDescription {
        guard let description = NSEntityDescription.entity(forEntityName: coreDataEntity.rawValue, in: self.viewContext) else {
            fatalError("Couldn't get entity description for '\(coreDataEntity)' entity name")
        }
        
        return description
    }
    
    public func saveContext() {
        do {
            try viewContext.save()
        } catch let error as NSError {
            NSLog("Can't write. \(error), \(error.userInfo)")
            abort()
        }
    }
    
}

extension DatabaseManager {
    
    public enum CoreDataEntity: String {
        
        case movie = "MovieEntity"
        
        case tag = "TagEntity"
        
    }
    
}
