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
        let viewContext = DatabaseManager.shared.viewContext
        let request = DatabaseManager.shared.getFetchRequest(forEntity: .tag)
        let tagDAOs: [NSManagedObject]
        do {
            tagDAOs = try viewContext.fetch(request)
        } catch let error as NSError {
            fatalError("Couldn't get all tags from DB. \(error), \(error.userInfo)")
        }
        let tags: [Tag] = tagDAOs.map { (tagDAO) in
            guard let name = tagDAO.value(forKey: "name") as? String else {
                fatalError("Tag must have a name.")
            }
            guard let russianName = tagDAO.value(forKey: "russianName") as? String else {
                fatalError("Tag must have a russian name.")
            }
            let tag = Tag(name: name, russianName: russianName)
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
        guard let systemTag = get(byName: systemTagName.rawValue) else {
            fatalError("Tag with name '\(SystemTagName.willCheckItOut.rawValue)' wasn't found.")
        }
        return systemTag
    }
    
    public func save(tag: Tag) {
        let viewContext = DatabaseManager.shared.viewContext
        let entity = DatabaseManager.shared.getEntityDescription(forEntity: .tag)
        let tagDAO = NSManagedObject(entity: entity, insertInto: viewContext)
        tagDAO.setValue(tag.name, forKey: "name")
        tagDAO.setValue(tag.russianName, forKey: "russianName")
        DatabaseManager.shared.saveContext()
    }
}
