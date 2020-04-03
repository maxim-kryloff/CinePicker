import CoreData

class MovieRepository {
    
    private static var instance: MovieRepository?
    
    public static var shared: MovieRepository {
        if instance == nil {
            instance = MovieRepository()
        }
        
        return instance!
    }
    
    private init() { }
    
    public func getBookmarks() -> [Movie] {
        let managedContext = CoreDataManager.shared.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "MovieEntity")
        
        do {
            let movieDAOs = try managedContext.fetch(request)
            var movies: [Movie] = []
            
            for movieDAO in movieDAOs {
                let movie = Movie.buildMovie(fromDAO: movieDAO)
                movies.append(movie)
            }
            
            return movies
            
        } catch let error as NSError {
            print("Can't read. \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    public func saveBookmark(movie: Movie) -> [Movie] {
        let managedContext = CoreDataManager.shared.viewContext
        
        let entity = CoreDataManager.shared.getEntityDescription(forEntityName: "MovieEntity")
        let movieDAO = NSManagedObject(entity: entity, insertInto: managedContext)
        
        movieDAO.setValue(movie.id, forKey: "id")
        
        movieDAO.setValue(movie.title, forKey: "title")
        
        movieDAO.setValue(movie.originalTitle, forKey: "originalTitle")
        
        movieDAO.setValue(movie.imagePath, forKey: "imagePath")
        
        movieDAO.setValue(movie.releaseYear, forKey: "releaseYear")
        
        CoreDataManager.shared.saveContext()
        
        return getBookmarks()
    }
    
    public func removeBookmark(movie: Movie) -> [Movie] {
        let managedContext = CoreDataManager.shared.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "MovieEntity")
        
        do {
            let movieDAOs = try managedContext.fetch(request)
            let modelToDelete = movieDAOs.first { $0.value(forKey: "id") as! Int == movie.id }!
            
            managedContext.delete(modelToDelete)
            CoreDataManager.shared.saveContext()

        } catch let error as NSError {
            print("Can't delete. \(error), \(error.userInfo)")
        }
        
        return getBookmarks()
    }
    
    public func eraseBookmarks() -> [Movie] {
        let managedContext = CoreDataManager.shared.viewContext
        let coordinator = CoreDataManager.shared.persistentStoreCoordinator
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
        let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try coordinator.execute(deleteAllRequest, with: managedContext)
        } catch let error as NSError {
            print("Can't delete. \(error), \(error.userInfo)")
        }
        
        return getBookmarks()
    }
    
}
