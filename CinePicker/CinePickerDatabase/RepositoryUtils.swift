import CoreData

class RepositoryUtils {
    
    private static var instance: RepositoryUtils?
    
    public static var shared: RepositoryUtils {
        if instance == nil {
            instance = RepositoryUtils()
        }
        return instance!
    }
    
    private init() { }
    
    public func getTagEntities() -> [TagEntity] {
        let viewContext = DatabaseManager.shared.viewContext
        do {
            let request: NSFetchRequest = TagEntity.fetchRequest()
            let tagEntities = try viewContext.fetch(request)
            return tagEntities
        } catch let error as NSError {
            fatalError("Couldn't get tag entities. \(error), \(error.userInfo)")
        }
    }
}
