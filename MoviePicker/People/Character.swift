class Character: Person {
    
    public let characterName: String
    
    public let isUncredited: Bool
    
    init(id: Int, name: String, imagePath: String?, characterName: String) {
        self.characterName = characterName
        isUncredited = characterName.contains("(uncredited)")
        
        super.init(id: id, name: name, imagePath: imagePath)
    }
    
}
