import Foundation

class MovieService {
    
    private let getMoviesOperationQueue = OperationQueue()
    
    public func getMovies(by personId: Int, callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
        getMoviesOperationQueue.cancelAllOperations()
        
        let operation = GetMoviesOperation()
        
        operation.personId = personId
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getMoviesOperationQueue.addOperation(operation)
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
    
}

extension MovieService {
    
    private class GetMoviesOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var personId: Int = 0
        
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
                
                let movies = self.getMovies(from: data)
                
                self.result = AsyncResult.success(movies)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetMoviesRequest(withPersonId personId: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: MoviePickerConfig.apiPath)
                .append(pathComponent: "/person/\(personId)/movie_credits")
                .append(queryItem: ("api_key", MoviePickerConfig.apiToken))
                .append(queryItem: ("language", MoviePickerConfig.language))
                .build()

            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getMovies(from responseData: Data) -> [Movie] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let cast = json["cast"] as! [[String: Any]]
                
                var movies: [Movie] = []
                
                for item in cast {
                    let id = item["id"] as! Int
                    
                    let title = item["title"] as! String
                    
                    let originalTitle = item["original_title"] as? String
                    
                    let poster_path = item["poster_path"] as? String
                    
                    let vote_average = item["vote_average"] as? Double
                    
                    let vote_count = item["vote_count"] as? Int
                    
                    let release_date = item["release_date"] as? String
                    var releaseDateSubstring: Substring? = nil
                    
                    if let release_date = release_date, release_date.count >= 4 {
                        let index = release_date.index(release_date.startIndex, offsetBy: 3)
                        releaseDateSubstring = release_date[...index]
                    }
                    
                    var releaseYear: String? = nil
                    
                    if let releaseDateSubstring = releaseDateSubstring {
                        releaseYear = String(releaseDateSubstring)
                    }
                    
                    let overview = item["overview"] as? String
                    
                    let genre_ids = item["genre_ids"] as? [Int]
                    
                    let popularity = item["popularity"] as! Double
                    
                    let movie = Movie(
                        id: id,
                        title: title,
                        originalTitle: originalTitle,
                        imagePath: poster_path,
                        rating: vote_average,
                        voteCount: vote_count,
                        releaseYear: releaseYear,
                        overview: overview,
                        genreIds: genre_ids,
                        popularity: popularity
                    )
                    
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
    
    private class SearchMoviesOperation: AsyncOperation {
        
        public var result: AsyncResult<[Movie]>?
        
        public var searchQuery = ""
        
        public var page: Int = 0
        
        override func main() {
            if isCancelled {
                return
            }
            
            let session = URLSession.shared
            let searchMoviesRequest = buildSearchMoviesRequest(withSearchQuery: searchQuery)
            
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
        
        private func buildSearchMoviesRequest(withSearchQuery query: String) -> URLRequest {
            let url: URL! = URLBuilder(string: MoviePickerConfig.apiPath)
                .append(pathComponent: "/search/movie")
                .append(queryItem: ("api_key", MoviePickerConfig.apiToken))
                .append(queryItem: ("language", MoviePickerConfig.language))
                .append(queryItem: ("query", query))
                .append(queryItem: ("page", String(page)))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getMovies(from responseData: Data) -> [Movie] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let cast = json["results"] as! [[String: Any]]
                
                var movies: [Movie] = []
                
                for item in cast {
                    let id = item["id"] as! Int
                    
                    let title = item["title"] as! String
                    
                    let originalTitle = item["original_title"] as? String
                    
                    let poster_path = item["poster_path"] as? String
                    
                    let vote_average = item["vote_average"] as? Double
                    
                    let vote_count = item["vote_count"] as? Int
                    
                    let release_date = item["release_date"] as? String
                    var releaseDateSubstring: Substring? = nil
                    
                    if let release_date = release_date, release_date.count >= 4 {
                        let index = release_date.index(release_date.startIndex, offsetBy: 3)
                        releaseDateSubstring = release_date[...index]
                    }
                    
                    var releaseYear: String? = nil
                    
                    if let releaseDateSubstring = releaseDateSubstring {
                        releaseYear = String(releaseDateSubstring)
                    }
                    
                    let overview = item["overview"] as? String
                    
                    let genre_ids = item["genre_ids"] as? [Int]
                    
                    let popularity = item["popularity"] as! Double
                    
                    let movie = Movie(
                        id: id,
                        title: title,
                        originalTitle: originalTitle,
                        imagePath: poster_path,
                        rating: vote_average,
                        voteCount: vote_count,
                        releaseYear: releaseYear,
                        overview: overview,
                        genreIds: genre_ids,
                        popularity: popularity
                    )
                    
                    movies.append(movie)
                }
                
                return movies
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}
