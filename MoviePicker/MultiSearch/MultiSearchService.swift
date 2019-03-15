import Foundation

class MultiSearchService {
    
    private let movieService: MovieService
    
    private let personService: PersonService
    
    init(movieService: MovieService, personService: PersonService) {
        self.movieService = movieService
        self.personService = personService
    }
    
    public func requestEntities(
        request: MultiSearchRequest,
        callback: @escaping (_: MultiSearchRequest, _: [Popularity], _ isLoadingDataFailed: Bool) -> Void
    ) {
        let concurrentSearchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        
        let dispatchGroup = DispatchGroup()
        
        var movies: [Movie] = []
        var isLoadingMoviesFailed = false
        
        var actors: [Actor] = []
        var isLoadingActorsFailed = false
        
        let searchQuery = request.searchQuery
        let page = request.page
        
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestMovies(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                movies = result
                isLoadingMoviesFailed = isRequestFailed
            }
        }
        
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestActors(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                actors = result
                isLoadingActorsFailed = isRequestFailed
            }
        }
        
        dispatchGroup.notify(queue: concurrentSearchQueue) {
            let requestedSearchEntities = (actors as [Popularity] + movies as [Popularity])
                .sorted { $0.popularityValue > $1.popularityValue }
            
            callback(request, requestedSearchEntities, isLoadingMoviesFailed && isLoadingActorsFailed)
        }
    }
    
    private func requestMovies(
        by searchQuery: String,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_ result: [Movie], _ isRequestFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        movieService.searchMovies(by: searchQuery, andPage: page) { (result) in
            var requestResult: [Movie] = []
            var isFailed = false
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { $0.imagePath != nil }
                    .filter { $0.overview != nil && $0.overview != "" }
                    .sorted { $0.popularity > $1.popularity }
                
            } catch ResponseError.dataIsNil {
                isFailed = true
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func requestActors(
        by searchQuery: String,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_ result: [Actor], _ isRequestFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.searchActors(by: searchQuery, andPage: page) { (result) in
            var requestResult: [Actor] = []
            var isFailed = false
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let actors = try result.getValue()
                
                requestResult = actors
                    .filter { $0.imagePath != nil }
                    .sorted { $0.popularity > $1.popularity }

            } catch ResponseError.dataIsNil {
                isFailed = true
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
