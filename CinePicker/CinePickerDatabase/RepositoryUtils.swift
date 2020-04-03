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
    
    let viewContext = DatabaseManager.shared.viewContext
    
    public func fetchTagEntities(_ fetchRequest: NSFetchRequest<TagEntity>) -> [TagEntity] {
        do {
            let tagEntities = try viewContext.fetch(fetchRequest)
            return tagEntities
        } catch let error as NSError {
            fatalError("Couldn't get tag entities. \(error), \(error.userInfo)")
        }
    }
    
    public func createTag(from tagEntity: TagEntity) -> Tag {
        let tag = Tag(name: tagEntity.name!, russianName: tagEntity.russianName!)
        return tag
    }
}
