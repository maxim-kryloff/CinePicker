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
            let movies = buildMovieModels(from: movieDAOs)
            
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
        
        movieDAO.setValue(movie.overview, forKey: "overview")
        
        let genreIdsString = getStringFrom(genreIds: movie.genreIds)
        movieDAO.setValue(genreIdsString, forKey: "genreIds")
        
        movieDAO.setValue(movie.popularity, forKey: "popularity")
        
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
            print("Can't read. \(error), \(error.userInfo)")
        }
        
        return getBookmarks()
    }
    
    private func buildMovieModels(from movieDAOs: [NSManagedObject]) -> [Movie] {
        var movies: [Movie] = []
        
        for movieDAO in movieDAOs {
            let id = movieDAO.value(forKey: "id") as! Int
            
            let title = movieDAO.value(forKey: "title") as! String
            
            let originalTitle = movieDAO.value(forKey: "originalTitle") as? String
            
            let imagePath = movieDAO.value(forKey: "imagePath") as? String
            
            let rating = movieDAO.value(forKey: "rating") as? Double
            
            let voteCount = movieDAO.value(forKey: "voteCount") as? Int
            
            let releaseYear = movieDAO.value(forKey: "releaseYear") as? String
            
            let overview = movieDAO.value(forKey: "overview") as? String
            
            let genreIdsString = movieDAO.value(forKey: "genreIds") as? String
            let genreIds = getGenreIdsFrom(string: genreIdsString)
            
            let popularity = movieDAO.value(forKey: "popularity") as! Double
            
            let movie = Movie(
                id: id,
                title: title,
                originalTitle: originalTitle,
                imagePath: imagePath,
                rating: rating,
                voteCount: voteCount,
                releaseYear: releaseYear,
                overview: overview,
                genreIds: genreIds,
                popularity: popularity
            )
            
            movies.append(movie)
        }
        
        return movies
    }
    
    private func getStringFrom(genreIds: [Int]?) -> String? {
        guard let genreIds = genreIds else {
            return nil
        }
        
        var string = ""
        
        for genreId in genreIds {
            string += String(genreId) + " "
        }
        
        return string
    }
    
    private func getGenreIdsFrom(string: String?) -> [Int]? {
        guard let string = string else {
            return nil
        }
        
        var genreIds: [Int] = []
        
        for item in string.split(separator: " ") {
            let genreId = Int(item)!
            genreIds.append(genreId)
        }
        
        return genreIds
    }
    
}
