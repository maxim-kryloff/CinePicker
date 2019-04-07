import Foundation

class SimilarMovieService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(
        request: SimilarMovieRequest,
        callback: @escaping (_: SimilarMovieRequest, _: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        movieService.getSimilarMovies(byMovieId: request.movieId, andPage: request.page) { (result) in
            var requestResult: [Movie] = []
            var isFailed = true
            
            defer {
                callback(request, requestResult, isFailed)
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
