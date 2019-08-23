import Foundation

class DiscoverSettingsService {
    
    private let genreService: GenreService
    
    private let movieService: MovieService
    
    init(genreService: GenreService, movieService: MovieService) {
        self.genreService = genreService
        self.movieService = movieService
    }
    
    public func requestGenres(callback: @escaping (_: [Genre]?) -> Void) {
        genreService.getGenres { (result) in
            var requestResult: [Genre]?
            
            defer {
                callback(requestResult)
            }
            
            do {
                let genres = try result.getValue()
                
                requestResult = genres
                    .sorted { $0.name < $1.name }
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    public func requestDiscoveredMovies(
        request: DiscoveredMovieRequest,
        callback: @escaping (_: DiscoveredMovieRequest, _: [Movie]?) -> Void
    ) {
        
        movieService.getDiscoveredMovies(withGenres: request.genreIds, andYear: request.year, gteRating: request.rating, andPage: request.page) { (result) in
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
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
