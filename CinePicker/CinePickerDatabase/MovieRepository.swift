import CoreData

class MovieRepository {
    
    private static var instance: MovieRepository?
    
    public static var shared: MovieRepository {
        if instance == nil {
            instance = MovieRepository()
        }
        
        return instance!
    }
    
    public func getAll() -> [SavedMovie] {
        let viewContext = DatabaseManager.shared.viewContext
        let request = DatabaseManager.shared.getFetchRequest(forEntity: .movie)
        let movieDAOs: [NSManagedObject]
        do {
            movieDAOs = try viewContext.fetch(request)
        } catch let error as NSError {
            fatalError("Couldn't get all movies from DB. \(error), \(error.userInfo)")
        }
        let savedMovies: [SavedMovie] = movieDAOs.map { (movieDAO) in
            guard let id = movieDAO.value(forKey: "id") as? Int else {
                fatalError("Movie must have an id...")
            }
            guard let title = movieDAO.value(forKey: "title") as? String else {
                fatalError("Movie must have a title...")
            }
            let originalTitle = movieDAO.value(forKey: "originalTitle") as? String ?? ""
            let imagePath = movieDAO.value(forKey: "imagePath") as? String ?? ""
            let releaseYear = movieDAO.value(forKey: "releaseYear") as? String ?? ""
            guard let tagDAOs = movieDAO.value(forKey: "tags") as? NSSet else {
                fatalError("Movie must have tags...")
            }
            let tags: [Tag] = tagDAOs.map { (tagDAO) in
                guard let tagDAO = tagDAO as? NSManagedObject else {
                    fatalError("TagDAO must be instance of NSManagedObject...")
                }
                guard let tagName = tagDAO.value(forKey: "name") as? String else {
                    fatalError("Tag must have a name...")
                }
                guard let tagRussianName = tagDAO.value(forKey: "russianName") as? String else {
                    fatalError("Tag must have a russian name...")
                }
                let tag = Tag(name: tagName, russianName: tagRussianName)
                return tag
            }
            let savedMovie = SavedMovie(
                id: id,
                title: title,
                originalTitle: originalTitle,
                imagePath: imagePath,
                releaseYear: releaseYear,
                tags: tags
            )
            return savedMovie
        }
        return savedMovies
    }
    
    public func get(byId id: Int) -> SavedMovie? {
        let savedMovies = getAll()
        let savedMovie = savedMovies.first { $0.id == id }
        return savedMovie
    }
    
    public func save(movie: SavedMovie) {
        let viewContext = DatabaseManager.shared.viewContext
        let entityDescription = DatabaseManager.shared.getEntityDescription(forEntity: .movie)
        let movieDAO = NSManagedObject(entity: entityDescription, insertInto: viewContext)
        updateManagedObject(viewContext: viewContext, movieDAO: movieDAO, movie: movie)
        DatabaseManager.shared.saveContext()
    }
    
    public func update(movie: SavedMovie) {
        let viewContext = DatabaseManager.shared.viewContext
        let request = DatabaseManager.shared.getFetchRequest(forEntity: .movie)
        let movieDAOs: [NSManagedObject]
        do {
            movieDAOs = try viewContext.fetch(request)
        } catch let error as NSError {
            fatalError("Couldn't remove movie from DB. \(error), \(error.userInfo)")
        }
        let movieDAO = movieDAOs.first { $0.value(forKey: "id") as! Int == movie.id }!
        updateManagedObject(viewContext: viewContext, movieDAO: movieDAO, movie: movie)
        DatabaseManager.shared.saveContext()
    }
    
    public func remove(movie: SavedMovie) {
        let viewContext = DatabaseManager.shared.viewContext
        let request = DatabaseManager.shared.getFetchRequest(forEntity: .movie)
        let movieDAOs: [NSManagedObject]
        do {
            movieDAOs = try viewContext.fetch(request)
        } catch let error as NSError {
            fatalError("Couldn't remove movie from DB. \(error), \(error.userInfo)")
        }
        let modelToDelete = movieDAOs.first { $0.value(forKey: "id") as! Int == movie.id }!
        viewContext.delete(modelToDelete)
        DatabaseManager.shared.saveContext()
    }
    
    public func removeAll() {
        let viewContext = DatabaseManager.shared.viewContext
        let request = DatabaseManager.shared.getFetchRequest(forEntity: .movie)
        let movieDAOs: [NSManagedObject]
        do {
            movieDAOs = try viewContext.fetch(request)
        } catch let error as NSError {
            fatalError("Couldn't remove movie from DB. \(error), \(error.userInfo)")
        }
        for movieDAO in movieDAOs {
            viewContext.delete(movieDAO)
        }
        DatabaseManager.shared.saveContext()
    }
    
    private func updateManagedObject(viewContext: NSManagedObjectContext, movieDAO: NSManagedObject, movie: SavedMovie) {
        let tagRequest = DatabaseManager.shared.getFetchRequest(forEntity: .tag)
        var tagDAOs: [NSManagedObject]
        do {
            tagDAOs = try viewContext.fetch(tagRequest)
        } catch let error as NSError {
            fatalError("Couldn't get all tags from DB. \(error), \(error.userInfo)")
        }
        tagDAOs = tagDAOs.filter { (tagDAO) in
            let tagNameFromDAO = tagDAO.value(forKey: "name") as! String
            return movie.tags.contains { $0.name == tagNameFromDAO }
        }
        movieDAO.setValue(movie.id, forKey: "id")
        movieDAO.setValue(movie.title, forKey: "title")
        movieDAO.setValue(movie.originalTitle, forKey: "originalTitle")
        movieDAO.setValue(movie.imagePath, forKey: "imagePath")
        movieDAO.setValue(movie.releaseYear, forKey: "releaseYear")
        let tagDAOSet = NSSet(array: tagDAOs)
        movieDAO.setValue(tagDAOSet, forKey: "tags")
    }
}
