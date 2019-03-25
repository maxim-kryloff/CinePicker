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
        var isLoadingMoviesFailed = true
        
        var popularPeople: [PopularPerson] = []
        var isLoadingPopularPeopleFailed = true
        
        let searchQuery = request.searchQuery
        let page = request.page
        
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestMovies(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                movies = result
                isLoadingMoviesFailed = isRequestFailed
            }
        }
        
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestPopularPeople(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                popularPeople = result
                isLoadingPopularPeopleFailed = isRequestFailed
            }
        }
        
        dispatchGroup.notify(queue: concurrentSearchQueue) {
            let requestedSearchEntities = (popularPeople as [Popularity] + movies as [Popularity])
                .sorted { $0.popularityValue > $1.popularityValue }
            
            callback(request, requestedSearchEntities, isLoadingMoviesFailed && isLoadingPopularPeopleFailed)
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
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
                    .sorted { $0.popularity > $1.popularity }
                
                isFailed = false
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func requestPopularPeople(
        by searchQuery: String,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_ result: [PopularPerson], _ isRequestFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.searchPopularPeople(by: searchQuery, andPage: page) { (result) in
            var requestResult: [PopularPerson] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let popularPeople = try result.getValue()
                
                requestResult = popularPeople
                    .filter { !$0.imagePath.isEmpty }
                    .sorted { $0.popularity > $1.popularity }
                
                isFailed = false

            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
