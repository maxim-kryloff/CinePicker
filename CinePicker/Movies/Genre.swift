class Genre {
    
    public let id: Int
    
    public let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public static func buildGenre(fromJson json: [String: Any]) -> Genre {
        guard let id = json["id"] as? Int else {
            fatalError("Genre must have an id...")
        }
        
        guard let name = json["name"] as? String else {
            fatalError("Genre must have a name...")
        }
        
        let genre = Genre(id: id, name: name)
        
        return genre
    }
    
}
