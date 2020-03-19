class Person {
    
    public let id: Int
    
    public let name: String
    
    public let imagePath: String
    
    init(id: Int, name: String, imagePath: String) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
    }
    
    public static func buildPerson(fromJson json: [String: Any]) throws -> Person {
        guard let id = json["id"] as? Int else {
            throw ResponseError.jsonDoesNotHaveProperty
        }
        guard let name = json["name"] as? String else {
            throw ResponseError.jsonDoesNotHaveProperty
        }
        let profilePath = json["profile_path"] as? String ?? ""
        let person = Person(
            id: id,
            name: name,
            imagePath: profilePath
        )
        return person
    }
}
