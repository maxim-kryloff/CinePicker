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
    
    public func getAll() -> [Tag] {
        let tagEntities = RepositoryUtils.shared.getTagEntities()
        let tags = createTags(from: tagEntities)
        return tags
    }
    
    private func createTags(from tagEntities: [TagEntity]) -> [Tag] {
        let tags: [Tag] = tagEntities.map { (tagEntity) in
            let tag = Tag(name: tagEntity.name!, russianName: tagEntity.russianName!)
            return tag
        }
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
