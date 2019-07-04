import CoreData

class Movie {
    
    public let id: Int
    
    public let title: String
    
    public let originalTitle: String
    
    public let imagePath: String
    
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
        self.imagePath = imagePath
        self.rating = rating
        self.voteCount = voteCount
        self.releaseYear = releaseYear
        self.overview = overview
        self.popularity = popularity
    }
    
    public static func buildMovie(fromJson json: [String: Any]) -> Movie {
        let id = json["id"] as! Int
        
        let title = json["title"] as? String
        
        let originalTitle = json["original_title"] as? String
        
        let poster_path = json["poster_path"] as? String
        
        let vote_average = json["vote_average"] as? Double
        
        let vote_count = json["vote_count"] as? Int
        
        let release_date = json["release_date"] as? String
        var releaseDateSubstring: Substring?
        
        if let release_date = release_date, release_date.count >= 4 {
            let index = release_date.index(release_date.startIndex, offsetBy: 3)
            releaseDateSubstring = release_date[...index]
        }
        
        var releaseYear: String?
        
        if let releaseDateSubstring = releaseDateSubstring {
            releaseYear = String(releaseDateSubstring)
        }
        
        let overview = json["overview"] as? String
        
        let popularity = json["popularity"] as? Double
        
        let movie = Movie(
            id: id,
            title: title ?? "",
            originalTitle: originalTitle ?? "",
            imagePath: poster_path ?? "",
            rating: vote_average ?? 0,
            voteCount: vote_count ?? 0,
            releaseYear: releaseYear ?? "",
            overview: overview ?? "",
            popularity: popularity ?? 0
        )
        
        return movie
    }
    
    public static func buildMovie(fromDAO movieDAO: NSManagedObject) -> Movie {
        let id = movieDAO.value(forKey: "id") as! Int
        
        let title = movieDAO.value(forKey: "title") as! String
        
        let originalTitle = movieDAO.value(forKey: "originalTitle") as! String
        
        let imagePath = movieDAO.value(forKey: "imagePath") as! String
        
        let releaseYear = movieDAO.value(forKey: "releaseYear") as! String
        
        let movie = Movie(
            id: id,
            title: title,
            originalTitle: originalTitle,
            imagePath: imagePath,
            rating: 0,
            voteCount: 0,
            releaseYear: releaseYear,
            overview: "",
            popularity: 0
        )
        
        return movie
    }

}

extension Movie: Popularity {
    
    var popularityValue: Double {
        return popularity
    }
    
}
