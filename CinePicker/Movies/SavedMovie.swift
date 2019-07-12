class SavedMovie: Movie {
    
    public let tag: Tag
    
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
        tag: Tag
    ) {
        self.tag = tag
        
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
    
    convenience init(
        id: Int,
        title: String,
        originalTitle: String,
        imagePath: String,
        releaseYear: String,
        tag: Tag
    ) {
        self.init(
            id: id,
            title: title,
            originalTitle: originalTitle,
            imagePath: imagePath,
            rating: 0.0,
            voteCount: 0,
            releaseYear: releaseYear,
            overview: "",
            popularity: 0.0,
            tag: tag
        )
    }
    
}
