import CoreData

class TagRepository {
    
    private static var instance: TagRepository?
    
    public static var shared: TagRepository {
        if instance == nil {
            instance = TagRepository()
        }
        return instance!
    }
    
    private init() { }
    
    public func getSystemTag(byName systemTagName: SystemTagName) -> Tag {
        let systemTag = get(byName: systemTagName.rawValue)!
        return systemTag
    }
    
    private func get(byName name: String) -> Tag? {
        let fetchRequest: NSFetchRequest = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        let tagEntities = RepositoryUtils.shared.fetchTagEntities(fetchRequest)
        guard let tagEntity = tagEntities.first else {
            return nil
        }
        let tag =  RepositoryUtils.shared.createTag(from: tagEntity)
        return tag
    }
    
    public func save(tag: Tag) {
        let viewContext = DatabaseManager.shared.viewContext
        let entityDescription = DatabaseManager.shared.getEntityDescription(forEntity: .tag)
        let tagEntity = TagEntity(entity: entityDescription, insertInto: viewContext)
        setTagEntityProperties(from: tag, tagEntity: tagEntity)
        DatabaseManager.shared.saveContext()
    }
    
    private func setTagEntityProperties(from tag: Tag, tagEntity: TagEntity) {
        tagEntity.name = tag.name
        tagEntity.russianName = tag.russianName
    }
}
