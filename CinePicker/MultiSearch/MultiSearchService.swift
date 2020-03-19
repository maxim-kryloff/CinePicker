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
        onComplete callback: @escaping (_: MultiSearchRequest, _: [MultiSearchEntity]?) -> Void
    ) {
        let concurrentSearchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        let dispatchGroup = DispatchGroup()
        let searchQuery = request.searchQuery
        let page = request.page
        
        var movies: [Movie]?
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestMovies(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result) in
                movies = result
            }
        }
        
        var popularPeople: [PopularPerson]?
        concurrentSearchQueue.async(group: dispatchGroup) {
            self.requestPopularPeople(by: searchQuery, andPage: page, dispatchGroup: dispatchGroup) { (result) in
                popularPeople = result
            }
        }
        
        dispatchGroup.notify(queue: concurrentSearchQueue) {
            var requestedSearchEntities: [MultiSearchEntity]?
            if let popularPeople = popularPeople, let movies = movies {
                requestedSearchEntities = popularPeople + movies
                requestedSearchEntities = self.getSortedByRelevance(requestedSearchEntities!, using: request)
            }
            callback(request, requestedSearchEntities)
        }
    }
    
    private func requestMovies(
        by searchQuery: String,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        onComplete callback: @escaping (_ result: [Movie]?) -> Void
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
        onComplete callback: @escaping (_ result: [PopularPerson]?) -> Void
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
    
    private func getSortedByRelevance(
        _ multiSearchEntities: [MultiSearchEntity],
        using request: MultiSearchRequest
    ) -> [MultiSearchEntity] {
        let numberOfIterations = getNumberOfIterations(by: request.searchQuery)
        var sortedEntities: [MultiSearchEntity] = []
        for currentIterationIndex in 0..<numberOfIterations {
            let subQuery = getSubQueryUpToEndIndex(from: currentIterationIndex, ofQuery: request.searchQuery)
            var currentIterationResult: [MultiSearchEntity] = []
            currentIterationResult += multiSearchEntities.filter {
                $0.primaryValueToSort.lowercased().contains(subQuery.lowercased())
            }
            currentIterationResult += multiSearchEntities.filter {
                $0.secondaryValueToSort.lowercased().contains(subQuery.lowercased())
            }
            sortedEntities += currentIterationResult.sorted { $0.popularityValue > $1.popularityValue }
        }
        sortedEntities += multiSearchEntities
        sortedEntities = getUnique(sortedEntities)
        return sortedEntities
    }
    
    private func getNumberOfIterations(by query: String) -> Int {
        // Some magic number...
        let limitOfIterations = 10
        return query.count > limitOfIterations ? limitOfIterations : query.count
    }
    
    private func getSubQueryUpToEndIndex(from index: Int, ofQuery query: String) -> String.SubSequence {
        let endIndex = query.index(query.endIndex, offsetBy: -1 * index)
        let subQueryUpToEndIndex = query.prefix(upTo: endIndex)
        return subQueryUpToEndIndex
    }
    
    private func getUnique(_ multiSearchEntities: [MultiSearchEntity]) -> [MultiSearchEntity] {
        var uniqueEntities: [MultiSearchEntity] = []
        for multiSearchEntity in multiSearchEntities {
            if uniqueEntities.contains(where: { $0.identity == multiSearchEntity.identity }) {
                continue
            }
            uniqueEntities.append(multiSearchEntity)
        }
        return uniqueEntities
    }
}
