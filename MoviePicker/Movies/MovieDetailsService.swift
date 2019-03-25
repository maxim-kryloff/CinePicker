class MovieDetailsService {

    private let movieService: MovieService
    
    private let personService: PersonService
    
    init(movieService: MovieService, personService: PersonService) {
        self.movieService = movieService
        self.personService = personService
    }
    
    public func requestCharacters(by movieId: Int, _ callback: @escaping (_: [Character], _ isLoadingDataFailed: Bool) -> Void) {
        personService.getCharacters(by: movieId) { (result) in
            var requestResult: [Character] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
            }
            
            do {
                let characters = try result.getValue()
                requestResult = characters.filter { !$0.imagePath.isEmpty }
                
                isFailed = false
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    public func requestMovieDetails(by movieId: Int, _ callback: @escaping (_: MovieDetails?) -> Void) {
        movieService.getMovieDetails(by: movieId) { (result) in
            var requestResult: MovieDetails?
            
            defer {
                callback(requestResult)
            }
            
            do {
                requestResult = try result.getValue()
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
