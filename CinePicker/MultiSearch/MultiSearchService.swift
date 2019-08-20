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
        callback: @escaping (_: MultiSearchRequest, _: [MultiSearchEntity]?) -> Void
    ) {
        let concurrentSearchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        
        let dispatchGroup = DispatchGroup()
        
        var movies: [Movie]?
        var popularPeople: [PopularPerson]?
        
        let searchQuery = request.searchQuery
        let page = request.page
        
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestMovies(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result) in
                movies = result
            }
        }
        
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestPopularPeople(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result) in
                popularPeople = result
            }
        }
        
        dispatchGroup.notify(queue: concurrentSearchQueue) {
            var requestedSearchEntities: [MultiSearchEntity]?
            
            if let popularPeople = popularPeople, let movies = movies {
                requestedSearchEntities = popularPeople + movies
                requestedSearchEntities = self.getSortedMultiSearchResult(request, requestedSearchEntities!)
            }
            
            callback(request, requestedSearchEntities)
        }
    }
    
    private func requestMovies(
        by searchQuery: String,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_ result: [Movie]?) -> Void
    ) {
        dispatchGroup.enter()
        
        movieService.searchMovies(by: searchQuery, andPage: page) { (result) in
            var requestResult: [Movie]?
            
            defer {
                callback(requestResult)
                dispatchGroup.leave()
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
    
    private func requestPopularPeople(
        by searchQuery: String,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_ result: [PopularPerson]?) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.searchPopularPeople(by: searchQuery, andPage: page) { (result) in
            var requestResult: [PopularPerson]?
            
            defer {
                callback(requestResult)
                dispatchGroup.leave()
            }
            
            do {
                let popularPeople = try result.getValue()
                
                requestResult = popularPeople
                    .filter { !$0.imagePath.isEmpty }

            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func getSortedMultiSearchResult(
        _ request: MultiSearchRequest,
        _ multiSearchEntities: [MultiSearchEntity]
    ) -> [MultiSearchEntity] {
        
        // Some magic number...
        let limitOfIterations = 10
        
        var rawResult: [MultiSearchEntity] = []
        
        let query = request.searchQuery
        let numberOfIterations = query.count > limitOfIterations ? limitOfIterations : query.count
        
        for iteration in 0..<numberOfIterations {
            let endIndex = query.index(query.endIndex, offsetBy: -1 * iteration)
            let subQuery = query.prefix(upTo: endIndex)
            
            var currentIterationResult: [MultiSearchEntity] = []
            
            currentIterationResult += multiSearchEntities.filter {
                $0.primaryValueToSort.lowercased().contains(subQuery.lowercased())
            }
            
            currentIterationResult += multiSearchEntities.filter {
                $0.secondaryValueToSort.lowercased().contains(subQuery.lowercased())
            }
            
            rawResult += currentIterationResult.sorted { $0.popularityValue > $1.popularityValue }
        }
        
        rawResult += multiSearchEntities
        
        var result: [MultiSearchEntity] = []
        
        for multiSearchEntity in rawResult {
            if result.contains(where: { $0.uniqueValue == multiSearchEntity.uniqueValue }) {
                continue
            }
            
            result.append(multiSearchEntity)
        }
        
        return result
    }
    
}
