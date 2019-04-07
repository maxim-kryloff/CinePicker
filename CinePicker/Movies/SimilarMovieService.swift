import Foundation

class SimilarMovieService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(
        byMovieId movieId: Int,
        andPage page: Int,
        callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        movieService.getSimilarMovies(byMovieId: movieId, andPage: page) { (result) in
            var requestResult: [Movie] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
                
                isFailed = false
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
