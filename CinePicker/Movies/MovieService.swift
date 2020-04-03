import Foundation

class MovieService {
    
    private let getMovieDetailsOperationQueue = OperationQueue()
    
    public func getMovieDetails(
        by movieId: Int,
        onComplete callback: @escaping (_: AsyncResult<MovieDetails>) -> Void
    ) {
        getMovieDetailsOperationQueue.cancelAllOperations()
        let operation = createGetMovieDetailsOperation(gotBy: movieId, onComplete: callback)
        getMovieDetailsOperationQueue.addOperation(operation)
    }
    
    private func createGetMovieDetailsOperation(
        gotBy movieId: Int,
        onComplete callback: @escaping (_: AsyncResult<MovieDetails>) -> Void
    ) -> GetMovieDetailsOperation {
        let operation = GetMovieDetailsOperation()
        operation.movieId = movieId
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let getMoviesByPersonOperationQueue = OperationQueue()
    
    public func getMovies(
        byPerson personId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) {
        getMoviesByPersonOperationQueue.cancelAllOperations()
        let operation = createGetMoviesByPersonOperation(gotBy: personId, onComplete: callback)
        getMoviesByPersonOperationQueue.addOperation(operation)
    }
    
    private func createGetMoviesByPersonOperation(
        gotBy personId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) -> GetMoviesOperation {
        let operation = GetMoviesOperation()
        operation.personId = personId
        operation.personType = .actor
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let getMoviesByCrewMemberOperationQueue = OperationQueue()
    
    public func getMovies(
        byCrewMember personId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) {
        getMoviesByCrewMemberOperationQueue.cancelAllOperations()
        let operation = createGetMoviesByCrewMemberOperation(gotBy: personId, onComplete: callback)
        getMoviesByCrewMemberOperationQueue.addOperation(operation)
    }
    
    private func createGetMoviesByCrewMemberOperation(
        gotBy personId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) -> GetMoviesOperation {
        let operation = GetMoviesOperation()
        operation.personId = personId
        operation.personType = .crewMember
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let searchOperationQueue = OperationQueue()
    
    func searchMovies(
        by searchQuery: String,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) {
        searchOperationQueue.cancelAllOperations()
        let operation = createSearchMoviesOperation(searchBy: searchQuery, andPage: page, onComplete: callback)
        searchOperationQueue.addOperation(operation)
    }
    
    private func createSearchMoviesOperation(
        searchBy query: String,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) -> SearchMoviesOperation {
        let operation = SearchMoviesOperation()
        operation.searchQuery = query
        operation.page = page
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let getSimilarMoviesOperationQueue = OperationQueue()
    
    public func getSimilarMovies(
        byMovieId movieId: Int,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) {
        getSimilarMoviesOperationQueue.cancelAllOperations()
        let operation = createGetSimilarMoviesOperation(gotBy: movieId, andPage: page, onComplete: callback)
        getSimilarMoviesOperationQueue.addOperation(operation)
    }
    
    private func createGetSimilarMoviesOperation(
        gotBy movieId: Int,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) -> GetSimilarMoviesOperation {
        let operation = GetSimilarMoviesOperation()
        operation.movieId = movieId
        operation.page = page
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let getMoviesByCollectionIdOperationQueue = OperationQueue()
    
    public func getMovies(
        byCollectionId collectionId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) {
        getMoviesByCollectionIdOperationQueue.cancelAllOperations()
        let operation = createGetMovieByCollectionIdOperation(gotBy: collectionId, onComplete: callback)
        getMoviesByCollectionIdOperationQueue.addOperation(operation)
    }
    
    private func createGetMovieByCollectionIdOperation(
        gotBy collectionId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) -> GetMoviesByCollectionIdOperation {
        let operation = GetMoviesByCollectionIdOperation()
        operation.collectionId = collectionId
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let getDiscoveredMoviesOperationQueue = OperationQueue()
    
    public func getDiscoveredMovies(
        withGenres genreIds: [Int]?,
        andYear year: String?,
        gteRating rating: Double?,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) {
        getDiscoveredMoviesOperationQueue.cancelAllOperations()
        let operation = createGetDiscoveredMoviesOperation(
            withGenres: genreIds,
            andYear: year,
            gteRating: rating,
            andPage: page,
            onComplete: callback
        )
        getDiscoveredMoviesOperationQueue.addOperation(operation)
    }
    
    private func createGetDiscoveredMoviesOperation(
        withGenres genreIds: [Int]?,
        andYear year: String?,
        gteRating rating: Double?,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void
    ) -> GetDiscoveredMoviesOperation {
        let operation = GetDiscoveredMoviesOperation()
        operation.genreIds = genreIds
        operation.year = year
        operation.rating = rating
        operation.page = page
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
}

extension MovieService {
    
    private class GetMovieDetailsOperation: AsyncOperation {
        
        public var result: AsyncResult<MovieDetails>?
        
        public var movieId: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            let session = URLSession.shared
            let getMovieDetailsRequest = buildGetMovieDetailsRequest()
            let task = session.dataTask(with: getMovieDetailsRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let movieDetails = self.getMovieDetails(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(movieDetails)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetMovieDetailsRequest() -> URLRequest {
            let url = buildGetMovieDetailsUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetMovieDetailsUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId!)")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .build()
            return url!
        }
        
        private func getMovieDetails(from responseData: Data) -> MovieDetails? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                let movieDetails = try MovieDetails.buildMovieDetails(fromJson: json)
                return movieDetails
            } catch {
                return nil
            }
        }
    }
}

extension MovieService {
    
    private enum PersonType {
        
        case actor
        
        case crewMember
    }
    
    private class GetMoviesOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var personId: Int!
        
        public var personType: PersonType!
        
        override func main() {
            if isCancelled {
                return
            }
            let session = URLSession.shared
            let getMoviesRequest = buildGetMoviesRequest()
            let task = session.dataTask(with: getMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let movies = self.getMovies(from: data, personType: self.personType) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetMoviesRequest() -> URLRequest {
            let url = buildGetMoviesUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetMoviesUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/person/\(personId!)/movie_credits")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .build()
            return url!
        }
        
        private func getMovies(from responseData: Data, personType: PersonType) -> [Movie]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                let key = personType == .actor ? "cast" : "crew"
                guard let jsonResults = json[key] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var movies: [Movie] = []
                for item in jsonResults {
                    let movie = try Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                let uniqueMovies = getUniqueMovies(from: movies)
                return uniqueMovies
            } catch {
                return nil
            }
        }
        
        private func getUniqueMovies(from movies: [Movie]) -> [Movie] {
            var uniqueMovies: [Movie] = []
            for movie in movies {
                if uniqueMovies.contains(where: { $0.id == movie.id }) {
                    continue
                }
                uniqueMovies.append(movie)
            }
            return uniqueMovies
        }
    }
}

extension MovieService {
    
    private class SearchMoviesOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var searchQuery: String!
        
        public var page: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            let session = URLSession.shared
            let searchMoviesRequest = buildSearchMoviesRequest()
            let task = session.dataTask(with: searchMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let movies = self.getMovies(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildSearchMoviesRequest() -> URLRequest {
            let url = buildSearchMoviesUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildSearchMoviesUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/search/movie")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .append(queryItem: ("query", searchQuery))
                .append(queryItem: ("page", String(page)))
                .build()
            return url!
        }
        
        private func getMovies(from responseData: Data) -> [Movie]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["results"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var movies: [Movie] = []
                for item in jsonResults {
                    let movie = try Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                return movies
            } catch {
                return nil
            }
        }
    }
}

extension MovieService {
    
    private class GetSimilarMoviesOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var movieId: Int!
        
        public var page: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            let session = URLSession.shared
            let getSimilarMoviesRequest = buildGetSimilarMoviesRequest()
            let task = session.dataTask(with: getSimilarMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let movies = self.getSimilarMovies(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetSimilarMoviesRequest() -> URLRequest {
            let url = buildGetSimilarMoviesUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetSimilarMoviesUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId!)/similar")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .append(queryItem: ("page", String(page)))
                .build()
            return url!
        }
        
        private func getSimilarMovies(from responseData: Data) -> [Movie]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["results"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var movies: [Movie] = []
                for item in jsonResults {
                    let movie = try Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                return movies
            } catch {
                return nil
            }
        }
    }
}

extension MovieService {
    
    private class GetMoviesByCollectionIdOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var collectionId: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            let session = URLSession.shared
            let getMoviesByCollectionIdRequest = buildGetMoviesByCollectionIdRequest()
            let task = session.dataTask(with: getMoviesByCollectionIdRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let movies = self.getMovies(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetMoviesByCollectionIdRequest() -> URLRequest {
            let url = buildGetMoviesByCollectionIdUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetMoviesByCollectionIdUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/collection/\(collectionId!)")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .build()
            return url!
        }
        
        private func getMovies(from responseData: Data) -> [Movie]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["parts"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var movies: [Movie] = []
                for part in jsonResults {
                    let movie = try Movie.buildMovie(fromJson: part)
                    movies.append(movie)
                }
                return movies
            } catch {
                return nil
            }
        }
    }
}

extension MovieService {
    
    private class GetDiscoveredMoviesOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var genreIds: [Int]?
        
        public var year: String?
        
        public var rating: Double?
        
        public var page: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            let session = URLSession.shared
            let getDiscoveredMoviesRequest = buildGetDiscoveredMoviesRequest()
            let task = session.dataTask(with: getDiscoveredMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let movies = self.getDiscoveredMovies(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetDiscoveredMoviesRequest() -> URLRequest {
            let url = buildGetDiscoveredMoviesUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetDiscoveredMoviesUrl() -> URL {
            let urlBuilder = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/discover/movie")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .append(queryItem: ("page", String(page)))
            if let genreIds = genreIds {
                var withGernes = ""
                for genreId in genreIds {
                    withGernes.append(contentsOf: "\(genreId),")
                }
                if !withGernes.isEmpty {
                    _ = urlBuilder.append(queryItem: ("with_genres", withGernes))
                }
            }
            if let year = year {
                _ = urlBuilder.append(queryItem: ("primary_release_year", year))
            }
            if let rating = rating {
                _ = urlBuilder.append(queryItem: ("vote_average.gte", String(rating)))
            }
            let url = urlBuilder.build()!
            return url
        }
        
        private func getDiscoveredMovies(from responseData: Data) -> [Movie]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["results"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var movies: [Movie] = []
                for item in jsonResults {
                    let movie = try Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                return movies
            } catch {
                return nil
            }
        }
    }
}
