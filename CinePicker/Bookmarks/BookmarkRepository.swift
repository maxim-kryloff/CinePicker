import CoreData

class BookmarkRepository {
    
    private static var instance: BookmarkRepository?
    
    public static var shared: BookmarkRepository {
        if instance == nil {
            instance = BookmarkRepository()
        }
        
        return instance!
    }
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Bookmarks")
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let err = error as NSError? {
                fatalError("Unresolved error \(err), \(err.userInfo)")
            }
        }
    }
    
    public func getBookmarks() -> [Movie] {
        let managedContext = persistentContainer.viewContext
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
        let managedContext = persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "MovieEntity", in: managedContext)!
        let movieDAO = NSManagedObject(entity: entity, insertInto: managedContext)
        
        movieDAO.setValue(movie.id, forKey: "id")
        
        movieDAO.setValue(movie.title, forKey: "title")
        
        movieDAO.setValue(movie.originalTitle, forKey: "originalTitle")
        
        movieDAO.setValue(movie.imagePath, forKey: "imagePath")
        
        movieDAO.setValue(movie.rating, forKey: "rating")
        
        movieDAO.setValue(movie.voteCount, forKey: "voteCount")
        
        movieDAO.setValue(movie.releaseYear, forKey: "releaseYear")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Can't write. \(error), \(error.userInfo)")
        }
        
        return getBookmarks()
    }
    
    public func removeBookmark(movie: Movie) -> [Movie] {
        let managedContext = persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "MovieEntity")
        
        do {
            let movieDAOs = try managedContext.fetch(request)
            let modelToDelete = movieDAOs.first { $0.value(forKey: "id") as! Int == movie.id }!
            
            managedContext.delete(modelToDelete)
            try managedContext.save()

        } catch let error as NSError {
            print("Can't delete. \(error), \(error.userInfo)")
        }
        
        return getBookmarks()
    }
    
    public func eraseBookmarks() -> [Movie] {
        let managedContext = persistentContainer.viewContext
        let coordinator = persistentContainer.persistentStoreCoordinator
        
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
