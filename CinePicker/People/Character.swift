class Character: Person {
    
    public let characterName: String
    
    public let isUncredited: Bool
    
    init(id: Int, name: String, imagePath: String, characterName: String) {
        self.characterName = characterName
        isUncredited = characterName.contains("(uncredited)")
        
        super.init(id: id, name: name, imagePath: imagePath)
    }
    
    public static func buildCharacter(fromJson json: [String: Any]) throws -> Character {
        let person = try buildPerson(fromJson: json)
        
        let characterName = json["character"] as? String ?? ""
        
        let character = Character(
            id: person.id,
            name: person.name,
            imagePath: person.imagePath,
            characterName: characterName
        )
        
        return character
    }
    
}
