class SavedMovie: Movie {
    
    public var tags: [Tag]
    
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
        tags: [Tag]
    ) {
        self.tags = tags
        
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
        tags: [Tag]
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
            tags: tags
        )
    }
    
    public func containsTag(byName tagName: SystemTagName) -> Bool {
        return tags.contains { $0.name == tagName.rawValue }
    }
    
    public func addTag(tag: Tag) {
        tags.append(tag)
    }
    
    public func removeTag(byName tagName: SystemTagName) {
        tags.removeAll { $0.name == tagName.rawValue }
    }
    
}
