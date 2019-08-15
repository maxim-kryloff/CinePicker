class Genre {
    
    public let id: Int
    
    public let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public static func buildGenre(fromJson json: [String: Any]) -> Genre {
        let id = json["id"] as! Int
        
        let name = json["name"] as! String
        
        let genre = Genre(id: id, name: name)
        
        return genre
    }
    
}
