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
    
    private let viewContext = CoreDataProxy.shared.viewContext
    
    public func getAll() -> [SavedMovie] {
        let fetchRequest: NSFetchRequest = MovieEntity.fetchRequest()
        let movieEntities = fetchMovieEntities(fetchRequest)
        let savedMovies = createSavedMovies(from: movieEntities)
        return savedMovies
    }
    
    private func fetchMovieEntities(_ fetchRequest: NSFetchRequest<MovieEntity>) -> [MovieEntity] {
        do {
            let movieEntities = try viewContext.fetch(fetchRequest)
            return movieEntities
        } catch let error as NSError {
            fatalError("Couldn't fetch movie entities. \(error), \(error.userInfo)")
        }
    }
    
    private func createSavedMovies(from movieEntities: [MovieEntity]) -> [SavedMovie] {
        let savedMovies: [SavedMovie] = movieEntities.map { (movieEntity) in
            let savedMovie = createSavedMovie(from: movieEntity)
            return savedMovie
        }
        return savedMovies
    }
    
    private func createSavedMovie(from movieEntity: MovieEntity) -> SavedMovie {
        let tags: [Tag] = createTags(from: movieEntity.tags!)
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
    
    private func createTags(from tagEntities: NSSet) -> [Tag] {
        let tags: [Tag] = tagEntities.map { (tagEntity) in
            let tagEntity = tagEntity as! TagEntity
            let tag = RepositoryUtils.shared.createTag(from: tagEntity)
            return tag
        }
        return tags
    }
    
    public func get(byId id: Int) -> SavedMovie? {
        guard let movieEntity = getMovieEntity(byId: id) else {
            return nil
        }
        let savedMovie = createSavedMovie(from: movieEntity)
        return savedMovie
    }
    
    private func getMovieEntity(byId id: Int) -> MovieEntity? {
        let fetchRequest: NSFetchRequest = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        let movieEntities = fetchMovieEntities(fetchRequest)
        let movieEntity = movieEntities.first
        return movieEntity
    }
    
    public func save(movie: SavedMovie) {
        let entityDescription = CoreDataProxy.shared.createEntityDescription(forEntity: .movie)
        let movieEntity = MovieEntity(entity: entityDescription, insertInto: viewContext)
        setMovieEntityProperties(from: movie, movieEntity: movieEntity)
        CoreDataProxy.shared.saveContext()
    }
    
    public func update(movie: SavedMovie) {
        let movieEntity = getMovieEntity(byId: movie.id)!
        setMovieEntityProperties(from: movie, movieEntity: movieEntity)
        CoreDataProxy.shared.saveContext()
    }
    
    public func delete(movie: SavedMovie) {
        let movieEntity = getMovieEntity(byId: movie.id)!
        viewContext.delete(movieEntity)
        CoreDataProxy.shared.saveContext()
    }
    
    public func deleteAll() {
        let fetchRequest: NSFetchRequest = MovieEntity.fetchRequest()
        let movieEntities = fetchMovieEntities(fetchRequest)
        for movieEntity in movieEntities {
            viewContext.delete(movieEntity)
        }
        CoreDataProxy.shared.saveContext()
    }
    
    private func setMovieEntityProperties(from movie: SavedMovie, movieEntity: MovieEntity) {
        movieEntity.id = Int64(movie.id)
        movieEntity.title = movie.title
        movieEntity.originalTitle = movie.originalTitle
        movieEntity.imagePath = movie.imagePath
        movieEntity.releaseYear = movie.releaseYear
        let fetchRequest: NSFetchRequest = TagEntity.fetchRequest()
        var tagEntities = RepositoryUtils.shared.fetchTagEntities(fetchRequest)
        tagEntities = tagEntities.filter { (tagEntity) in
            return movie.tags.contains { $0.name == tagEntity.name }
        }
        movieEntity.tags = NSSet(array: tagEntities)
    }
}
