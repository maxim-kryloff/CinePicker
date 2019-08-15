class Genre {
    
    public let id: Int
    
    public let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public static func buildGenre(fromJson json: [String: Any]) throws -> Genre {
        guard let id = json["id"] as? Int else {
            throw ResponseError.jsonDoesNotHaveProperty
        }
        
        guard let name = json["name"] as? String else {
            throw ResponseError.jsonDoesNotHaveProperty
        }
        
        let genre = Genre(id: id, name: name)
        
        return genre
    }
    
}
