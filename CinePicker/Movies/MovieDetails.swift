class MovieDetails: Movie {
    
    public let genres: [Genre]
    
    public let runtime: Int
    
    public let collectionId: Int?
    
    init(
        id: Int,
        title: String,
        originalTitle: String,
        imagePath: String,
        rating: Double,
        voteCount: Int,
        releaseYear: String,
        overview: String,
        popularity: Double,
        genres: [Genre],
        runtime: Int,
        collectionId: Int?
    ) {
        self.genres = genres
        self.runtime = runtime
        self.collectionId = collectionId
        
        super.init(
            id: id,
            title: title,
            originalTitle: originalTitle,
            imagePath: imagePath,
            rating: rating,
            voteCount: voteCount,
            releaseYear: releaseYear,
            overview: overview,
            popularity: popularity
        )
    }
    
    public static func buildMovieDetails(fromJson json: [String: Any]) throws -> MovieDetails {
        let movie = try buildMovie(fromJson: json)
        
        var genres: [Genre] = []
        
        let genresJson = json["genres"] as? [[String: Any]] ?? []
        
        for item in genresJson {
            let genre = try Genre.buildGenre(fromJson: item)
            genres.append(genre)
        }
        
        let runtime = json["runtime"] as? Int ?? 0
        
        let belongs_to_collection = json["belongs_to_collection"] as? [String: Any]
        
        var collectionId: Int?
        
        if let belongs_to_collection = belongs_to_collection {
            collectionId = belongs_to_collection["id"] as? Int
        }
        
        let movieDetails = MovieDetails(
            id: movie.id,
            title: movie.title,
            originalTitle: movie.originalTitle,
            imagePath: movie.imagePath,
            rating: movie.rating,
            voteCount: movie.voteCount,
            releaseYear: movie.releaseYear,
            overview: movie.overview,
            popularity: movie.popularity,
            genres: genres,
            runtime: runtime,
            collectionId: collectionId
        )
        
        return movieDetails
    }
    
}
