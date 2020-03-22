import Foundation

class SimilarMovieService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(
        request: SimilarMovieRequest,
        onComplete callback: @escaping (_: SimilarMovieRequest, _: [Movie]?) -> Void
    ) {
        movieService.getSimilarMovies(byMovieId: request.movieId, andPage: request.page) { (result) in
            var requestResult: [Movie]?
            defer {
                callback(request, requestResult)
            }
            do {
                let movies = try result.getValue()
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result.")
            }
        }
    }
}
