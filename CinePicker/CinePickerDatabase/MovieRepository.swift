import CoreData

class MovieRepository {
    
    private static var instance: MovieRepository?
    
    public static var shared: MovieRepository {
        if instance == nil {
            instance = MovieRepository()
        }
        
        return instance!
    }
    
    public func getAll() -> [Movie] {
        let viewContext = DatabaseManager.shared.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: DatabaseEntity.movie.rawValue)
        
        do {
            let movieDAOs = try viewContext.fetch(request)
            var movies: [Movie] = []
            
            for movieDAO in movieDAOs {
                guard let id = movieDAO.value(forKey: "id") as? Int else {
                    fatalError("Movie must have an id...")
                }
                
                guard let title = movieDAO.value(forKey: "title") as? String else {
                    fatalError("Movie must have an title...")
                }
                
                let originalTitle = movieDAO.value(forKey: "originalTitle") as? String ?? ""
                
                let imagePath = movieDAO.value(forKey: "imagePath") as? String ?? ""
                
                let releaseYear = movieDAO.value(forKey: "releaseYear") as? String ?? ""
                
                let movie = Movie(
                    id: id,
                    title: title,
                    originalTitle: originalTitle,
                    imagePath: imagePath,
                    releaseYear: releaseYear
                )
                
                movies.append(movie)
            }
            
            return movies
            
        } catch let error as NSError {
            fatalError("Couldn't get all movies from DB. \(error), \(error.userInfo)")
        }
    }
    
    public func save(movie: Movie) -> [Movie] {
        let managedContext = DatabaseManager.shared.viewContext
        
        let entity = DatabaseManager.shared.getEntityDescription(forEntity: .movie)
        let movieDAO = NSManagedObject(entity: entity, insertInto: managedContext)
        
        movieDAO.setValue(movie.id, forKey: "id")
        
        movieDAO.setValue(movie.title, forKey: "title")
        
        movieDAO.setValue(movie.originalTitle, forKey: "originalTitle")
        
        movieDAO.setValue(movie.imagePath, forKey: "imagePath")
        
        movieDAO.setValue(movie.releaseYear, forKey: "releaseYear")
        
        DatabaseManager.shared.saveContext()
        
        return getAll()
    }
    
    public func remove(movie: Movie) -> [Movie] {
        let viewContext = DatabaseManager.shared.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: DatabaseEntity.movie.rawValue)
        
        do {
            let movieDAOs = try viewContext.fetch(request)
            let modelToDelete = movieDAOs.first { $0.value(forKey: "id") as! Int == movie.id }!
            
            viewContext.delete(modelToDelete)
            DatabaseManager.shared.saveContext()
            
            return getAll()
            
        } catch let error as NSError {
            fatalError("Couldn't remove movie from DB. \(error), \(error.userInfo)")
        }
    }
    
    public func removeAll() -> [Movie] {
        let viewContext = DatabaseManager.shared.viewContext
        let coordinator = DatabaseManager.shared.persistentStoreCoordinator
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try coordinator.execute(deleteAllRequest, with: viewContext)
            return getAll()
            
        } catch let error as NSError {
            fatalError("Couldn't remove all movies from DB. \(error), \(error.userInfo)")
        }
    }
    
}
