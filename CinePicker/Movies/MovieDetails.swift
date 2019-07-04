class MovieDetails: Movie {
    
    public let genres: [Genre]
    
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
        collectionId: Int?
    ) {
        self.genres = genres
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
    
    public static func buildMovieDetails(fromJson json: [String: Any]) -> MovieDetails {
        let movie = buildMovie(fromJson: json)
        
        var genres: [Genre] = []
        
        let genresJson = json["genres"] as? [[String: Any]] ?? []
        
        for item in genresJson {
            let genre = Genre.buildGenre(fromJson: item)
            genres.append(genre)
        }
        
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
            collectionId: collectionId
        )
        
        return movieDetails
    }
    
}
