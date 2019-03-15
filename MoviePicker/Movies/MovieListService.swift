class MovieListService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(by personId: Int, callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void) {
        movieService.getMovies(by: personId) { (result) in
            var requestResult: [Movie] = []
            var isFailed = false
            
            defer {
                callback(requestResult, isFailed)
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { $0.imagePath != nil }
                    .filter { $0.overview != nil && $0.overview != "" }
                
            } catch ResponseError.dataIsNil {
                isFailed = true
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
