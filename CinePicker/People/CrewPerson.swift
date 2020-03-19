class CrewPerson: Person {
    
    public var jobs: [String]
    
    init(id: Int, name: String, imagePath: String, job: String) {
        self.jobs = [job]
        super.init(id: id, name: name, imagePath: imagePath)
    }
    
    public static func buildCrewPerson(fromJson json: [String: Any]) throws -> CrewPerson {
        let person = try buildPerson(fromJson: json)
        let job = json["job"] as? String ?? ""
        let crewPerson = CrewPerson(
            id: person.id,
            name: person.name,
            imagePath: person.imagePath,
            job: job
        )
        return crewPerson
    }
}
