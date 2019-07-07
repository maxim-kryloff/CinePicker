import Foundation

class MovieService {
    
    private let getMovieDetailsOperationQueue = OperationQueue()
    
    public func getMovieDetails(by movieId: Int, callback: @escaping (_: AsyncResult<MovieDetails>) -> Void) {
        getMovieDetailsOperationQueue.cancelAllOperations()
        
        let operation = GetMovieDetailsOperation()
        
        operation.movieId = movieId
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getMovieDetailsOperationQueue.addOperation(operation)
    }
    
    private let getMoviesByPersonOperationQueue = OperationQueue()
    
    public func getMovies(byPerson personId: Int, callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
        getMoviesByPersonOperationQueue.cancelAllOperations()
        
        let operation = GetMoviesOperation()
        
        operation.personId = personId
        operation.personType = .actor
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getMoviesByPersonOperationQueue.addOperation(operation)
    }
    
    private let getMoviesByCrewMemberOperationQueue = OperationQueue()
    
    public func getMovies(byCrewMember personId: Int, callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
        getMoviesByCrewMemberOperationQueue.cancelAllOperations()
        
        let operation = GetMoviesOperation()
        
        operation.personId = personId
        operation.personType = .crewMember
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getMoviesByCrewMemberOperationQueue.addOperation(operation)
    }
    
    private let searchOperationQueue = OperationQueue()
    
    func searchMovies(by searchQuery: String, andPage page: Int, callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
        searchOperationQueue.cancelAllOperations()
        
        let operation = SearchMoviesOperation()
        
        operation.searchQuery = searchQuery
        operation.page = page
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        searchOperationQueue.addOperation(operation)
    }
    
    private let getSimilarMoviesOperationQueue = OperationQueue()
    
    public func getSimilarMovies(byMovieId movieId: Int, andPage page: Int, callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
        getSimilarMoviesOperationQueue.cancelAllOperations()
        
        let operation = GetSimilarMoviesOperation()
        
        operation.movieId = movieId
        operation.page = page
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getSimilarMoviesOperationQueue.addOperation(operation)
    }
    
    private let getMoviesByCollectionIdOperationQueue = OperationQueue()
    
    public func getMovies(byCollectionId collectionId: Int, callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
        getMoviesByCollectionIdOperationQueue.cancelAllOperations()
        
        let operation = GetMoviesByCollectionIdOperation()
        
        operation.collectionId = collectionId
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getMoviesByCollectionIdOperationQueue.addOperation(operation)
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
            let getMovieDetailsRequest = buildGetMovieDetailsRequest(withMovieId: movieId)
            
            let task = session.dataTask(with: getMovieDetailsRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let movieDetails = self.getMovieDetails(from: data)
                
                self.result = AsyncResult.success(movieDetails)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetMovieDetailsRequest(withMovieId movieId: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId)")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getMovieDetails(from responseData: Data) -> MovieDetails {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                let movieDetails = MovieDetails.buildMovieDetails(fromJson: json)
                
                return movieDetails
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
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
            let getMoviesRequest = buildGetMoviesRequest(withPersonId: personId)
            
            let task = session.dataTask(with: getMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }

                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let movies = self.getMovies(from: data, personType: self.personType)
                
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetMoviesRequest(withPersonId personId: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/person/\(personId)/movie_credits")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .build()

            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getMovies(from responseData: Data, personType: PersonType) -> [Movie] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let key = personType == .actor ? "cast" : "crew"
                
                let jsonResults = json[key] as! [[String: Any]]
                
                var movies: [Movie] = []
                
                for item in jsonResults {
                    let movie = Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                
                let uniqueMovies = getUniqueMovies(from: movies)
                
                return uniqueMovies
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
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
            let searchMoviesRequest = buildSearchMoviesRequest(withSearchQuery: searchQuery, andPage: page)
            
            let task = session.dataTask(with: searchMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let movies = self.getMovies(from: data)
                
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildSearchMoviesRequest(withSearchQuery query: String, andPage page: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/search/movie")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .append(queryItem: ("query", query))
                .append(queryItem: ("page", String(page)))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getMovies(from responseData: Data) -> [Movie] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["results"] as! [[String: Any]]
                
                var movies: [Movie] = []
                
                for item in jsonResults {
                    let movie = Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                
                return movies
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
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
            let getSimilarMoviesRequest = buildGetSimilarMoviesRequest(withMovieId: movieId, andPage: page)
            
            let task = session.dataTask(with: getSimilarMoviesRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let movies = self.getSimilarMovies(from: data)
                
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetSimilarMoviesRequest(withMovieId movieId: Int, andPage page: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId)/similar")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .append(queryItem: ("page", String(page)))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getSimilarMovies(from responseData: Data) -> [Movie] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["results"] as! [[String: Any]]
                
                var movies: [Movie] = []
                
                for item in jsonResults {
                    let movie = Movie.buildMovie(fromJson: item)
                    movies.append(movie)
                }
                
                return movies
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
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
            let getMoviesByCollectionIdRequest = buildGetMoviesByCollectionIdRequest(withCollectionId: collectionId)
            
            let task = session.dataTask(with: getMoviesByCollectionIdRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let movies = self.getMovies(from: data)
                
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetMoviesByCollectionIdRequest(withCollectionId collectionId: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/collection/\(collectionId)")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getMovies(from responseData: Data) -> [Movie] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["parts"] as! [[String: Any]]
                
                var movies: [Movie] = []
                
                for part in jsonResults {
                    let movie = Movie.buildMovie(fromJson: part)
                    movies.append(movie)
                }
                
                return movies
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}
