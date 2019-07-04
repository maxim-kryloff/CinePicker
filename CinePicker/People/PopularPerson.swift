class PopularPerson: Person {
    
    public let popularity: Double
    
    init(id: Int, name: String, imagePath: String, popularity: Double) {
        self.popularity = popularity
        super.init(id: id, name: name, imagePath: imagePath)
    }
    
    public static func buildPopularPerson(fromJson json: [String: Any]) -> PopularPerson {
        let person = buildPerson(fromJson: json)
        
        let popularity = json["popularity"] as? Double ?? 0.0
        
        let popularPerson = PopularPerson(
            id: person.id,
            name: person.name,
            imagePath: person.imagePath,
            popularity: popularity
        )
        
        return popularPerson
    }
    
}

extension PopularPerson: Popularity {
    
    var popularityValue: Double {
        return popularity
    }
    
}
