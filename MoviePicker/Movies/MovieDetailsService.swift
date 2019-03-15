class MovieDetailsService {

    private let personService: PersonService
    
    init(personService: PersonService) {
        self.personService = personService
    }
    
    public func requestCharacters(by movieId: Int, _ callback: @escaping (_: [Character], _ isLoadingDataFailed: Bool) -> Void) {
        personService.getCharacters(by: movieId) { (result) in
            var requestResult: [Character] = []
            var isFailed = false
            
            defer {
                callback(requestResult, isFailed)
            }
            
            do {
                let characters = try result.getValue()
                requestResult = characters.filter { $0.imagePath != nil }
            } catch ResponseError.dataIsNil {
                isFailed = true
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
