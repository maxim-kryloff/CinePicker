import CoreData
import Foundation

class CoreDataProxy {
    
    private static var instance: CoreDataProxy?
    
    public static var shared: CoreDataProxy {
        if instance == nil {
            instance = CoreDataProxy()
        }
        return instance!
    }
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "CinePickerDatabase")
        persistentContainer.loadPersistentStores { (_, error) in
            if let err = error as NSError? {
                fatalError("Unresolved Core Data error \(err), \(err.userInfo).")
            }
        }
    }
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func createEntityDescription(forEntity coreDataEntity: CoreDataEntity) -> NSEntityDescription {
        guard let description = NSEntityDescription.entity(forEntityName: coreDataEntity.rawValue, in: self.viewContext) else {
            fatalError("Couldn't create entity description for '\(coreDataEntity.rawValue)'.")
        }
        return description
    }
    
    public func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                fatalError("Could't save context changes. \(error), \(error.userInfo).")
            }
        }
    }
}
