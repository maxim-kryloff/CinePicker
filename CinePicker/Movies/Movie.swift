import CoreData

class Movie {
    
    public let id: Int
    
    public let title: String
    
    public let originalTitle: String
    
    public var imagePath: String {
        return _imagePath
    }
    
    private var _imagePath: String
    
    public let rating: Double
    
    public let voteCount: Int
    
    public let releaseYear: String
    
    public let overview: String
    
    public let popularity: Double
    
    init(
        id: Int,
        title: String,
        originalTitle: String,
        imagePath: String,
        rating: Double,
        voteCount: Int,
        releaseYear: String,
        overview: String,
        popularity: Double
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self._imagePath = imagePath
        self.rating = rating
        self.voteCount = voteCount
        self.releaseYear = releaseYear
        self.overview = overview
        self.popularity = popularity
    }
    
    public func update(imagePath: String) {
        _imagePath = imagePath
    }
    
    public static func buildMovie(fromJson json: [String: Any]) throws -> Movie {
        guard let id = json["id"] as? Int else {
            throw ResponseError.jsonDoesNotHaveProperty
        }
        guard let title = json["title"] as? String else {
            throw ResponseError.jsonDoesNotHaveProperty
        }
        let originalTitle = json["original_title"] as? String ?? ""
        let poster_path = json["poster_path"] as? String ?? ""
        let vote_average = json["vote_average"] as? Double ?? 0.0
        let vote_count = json["vote_count"] as? Int ?? 0
        let release_date = json["release_date"] as? String
        var releaseDateSubstring: Substring?
        if let release_date = release_date, release_date.count >= 4 {
            let index = release_date.index(release_date.startIndex, offsetBy: 3)
            releaseDateSubstring = release_date[...index]
        }
        var releaseYear = ""
        if let releaseDateSubstring = releaseDateSubstring {
            releaseYear = String(releaseDateSubstring)
        }
        let overview = json["overview"] as? String ?? ""
        let popularity = json["popularity"] as? Double ?? 0.0
        let movie = Movie(
            id: id,
            title: title,
            originalTitle: originalTitle,
            imagePath: poster_path,
            rating: vote_average,
            voteCount: vote_count,
            releaseYear: releaseYear,
            overview: overview,
            popularity: popularity
        )
        return movie
    }
}

extension Movie: MultiSearchEntity {
    
    var identity: String {
        return "movie#\(id)"
    }
    
    var primaryValueToSort: String {
        return title
    }
    
    var secondaryValueToSort: String {
        return originalTitle
    }
    
    var popularityValue: Double {
        return popularity
    }
}
