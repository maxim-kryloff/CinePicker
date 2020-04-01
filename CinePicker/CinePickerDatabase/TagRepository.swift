import CoreData

class TagRepository {
    
    private static var instance: TagRepository?
    
    public static var shared: TagRepository {
        if instance == nil {
            instance = TagRepository()
        }
        return instance!
    }
    
    public func getAll() -> [Tag] {
        let tagEntities = getTagEntities()
        let tags = createTags(from: tagEntities)
        return tags
    }
    
    private func getTagEntities() -> [TagEntity] {
        let viewContext = DatabaseManager.shared.viewContext
        do {
            return try viewContext.fetch(TagEntity.fetchRequest()) as! [TagEntity]
        } catch let error as NSError {
            fatalError("Couldn't get tag entities from DB. \(error), \(error.userInfo)")
        }
    }
    
    private func createTags(from tagEntities: [TagEntity]) -> [Tag] {
        let tags = tagEntities.map { (tagDAO) in Tag(name: tagDAO.name!, russianName: tagDAO.russianName!) }
        return tags
    }
    
    public func get(byName name: String) -> Tag? {
        let tags = getAll()
        let tag = tags.first { $0.name == name }
        return tag
    }
    
    public func getSystemTag(byName systemTagName: SystemTagName) -> Tag {
        let systemTag = get(byName: systemTagName.rawValue)!
        return systemTag
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
