class Actor: Person {
    
    public let popularity: Double
    
    init(id: Int, name: String, imagePath: String?, popularity: Double) {
        self.popularity = popularity
        super.init(id: id, name: name, imagePath: imagePath)
    }
    
}

extension Actor: Popularity {
    
    var popularityValue: Double {
        return popularity
    }
    
}
