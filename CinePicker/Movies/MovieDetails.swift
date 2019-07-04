class MovieDetails: Movie {
    
    public let genres: [Genre]
    
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
        genres: [Genre]
    ) {
        self.genres = genres
        
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
            genres: genres
        )
        
        return movieDetails
    }
    
}
