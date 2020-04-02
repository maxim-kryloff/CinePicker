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
    
    public func getAll() -> [SavedMovie] {
        let movieEntities = getMovieEntities()
        let savedMovies = createMovies(from: movieEntities)
        return savedMovies
    }
    
    private func getMovieEntities() -> [MovieEntity] {
        let viewContext = DatabaseManager.shared.viewContext
        do {
            let request: NSFetchRequest = MovieEntity.fetchRequest()
            let movieEntities = try viewContext.fetch(request)
            return movieEntities
        } catch let error as NSError {
            fatalError("Couldn't get movie entities. \(error), \(error.userInfo)")
        }
    }
    
    private func createMovies(from movieEntities: [MovieEntity]) -> [SavedMovie] {
        let savedMovies: [SavedMovie] = movieEntities.map { (movieEntity) in
            let tags = createTags(from: movieEntity.tags!)
            let savedMovie = SavedMovie(
                id: Int(movieEntity.id),
                title: movieEntity.title!,
                originalTitle: movieEntity.originalTitle ?? "",
                imagePath: movieEntity.imagePath ?? "",
                releaseYear: movieEntity.releaseYear ?? "",
                tags: tags
            )
            return savedMovie
        }
        return savedMovies
    }
    
    private func createTags(from tagEntities: NSSet) -> [Tag] {
        let tags: [Tag] = tagEntities.map { (tagEntity) in
            let tagEntity = tagEntity as! TagEntity
            let tag = Tag(name: tagEntity.name!, russianName: tagEntity.russianName!)
            return tag
        }
        return tags
    }
    
    public func get(byId id: Int) -> SavedMovie? {
        let savedMovies = getAll()
        let savedMovie = savedMovies.first { $0.id == id }
        return savedMovie
    }
    
    public func save(movie: SavedMovie) {
        let viewContext = DatabaseManager.shared.viewContext
        let entityDescription = DatabaseManager.shared.getEntityDescription(forEntity: .movie)
        let movieEntity = MovieEntity(entity: entityDescription, insertInto: viewContext)
        setMovieEntityProperties(from: movie, movieEntity: movieEntity)
        DatabaseManager.shared.saveContext()
    }
    
    public func update(movie: SavedMovie) {
        let movieEntity = getMovieEntity(for: movie)!
        setMovieEntityProperties(from: movie, movieEntity: movieEntity)
        DatabaseManager.shared.saveContext()
    }
    
    private func getMovieEntity(for movie: SavedMovie) -> MovieEntity? {
        let movieEntities = getMovieEntities()
        let movieEntity = movieEntities.first { $0.id == movie.id }
        return movieEntity
    }
    
    public func delete(movie: SavedMovie) {
        let viewContext = DatabaseManager.shared.viewContext
        let movieEntity = getMovieEntity(for: movie)!
        viewContext.delete(movieEntity)
        DatabaseManager.shared.saveContext()
    }
    
    public func deleteAll() {
        let viewContext = DatabaseManager.shared.viewContext
        let movieEntities = getMovieEntities()
        for movieEntity in movieEntities {
            viewContext.delete(movieEntity)
        }
        DatabaseManager.shared.saveContext()
    }
    
    private func setMovieEntityProperties(from movie: SavedMovie, movieEntity: MovieEntity) {
        movieEntity.id = Int64(movie.id)
        movieEntity.title = movie.title
        movieEntity.originalTitle = movie.originalTitle
        movieEntity.imagePath = movie.imagePath
        movieEntity.releaseYear = movie.releaseYear
        var tagEntities = RepositoryUtils.shared.getTagEntities()
        tagEntities = tagEntities.filter { (tagEntity) in
            return movie.tags.contains { $0.name == tagEntity.name }
        }
        movieEntity.tags = NSSet(array: tagEntities)
    }
}
