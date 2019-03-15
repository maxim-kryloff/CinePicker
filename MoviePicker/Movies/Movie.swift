class Movie {
    
    public let id: Int
    
    public let title: String
    
    public let originalTitle: String?
    
    public let imagePath: String?
    
    public let rating: Double?
    
    public let voteCount: Int?
    
    public let releaseYear: String?
    
    public let overview: String?
    
    public let genreIds: [Int]?
    
    public let popularity: Double
    
    init(
        id: Int,
        title: String,
        originalTitle: String?,
        imagePath: String?,
        rating: Double?,
        voteCount: Int?,
        releaseYear: String?,
        overview: String?,
        genreIds: [Int]?,
        popularity: Double
        ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.imagePath = imagePath
        self.rating = rating
        self.voteCount = voteCount
        self.releaseYear = releaseYear
        self.overview = overview
        self.genreIds = genreIds
        self.popularity = popularity
    }
    
}

extension Movie: Popularity {
    
    var popularityValue: Double {
        return popularity
    }
    
}
