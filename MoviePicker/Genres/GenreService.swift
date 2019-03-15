import Foundation

class GenreService {
    
    private let getGenresOperationQueue = OperationQueue()
    
    func getGenres(callback: @escaping (_: AsyncResult<[Genre]>) -> Void) {
        let operation = GetGenresOperation()

        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getGenresOperationQueue.addOperation(operation)
    }
    
}

extension GenreService {
    
    private class GetGenresOperation: AsyncOperation {
        
        public var result: AsyncResult<[Genre]>?
        
        override func main() {
            if isCancelled {
                return
            }
            
            let session = URLSession.shared
            let getGenresRequest = buildGetGenresRequest()
            
            let task = session.dataTask(with: getGenresRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let genres = self.getGenres(from: data)
                
                self.result = AsyncResult.success(genres)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetGenresRequest() -> URLRequest {
            let url: URL! = URLBuilder(string: MoviePickerConfig.apiPath)
                .append(pathComponent: "/genre/movie/list")
                .append(queryItem: ("api_key", MoviePickerConfig.apiToken))
                .append(queryItem: ("language", MoviePickerConfig.language))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getGenres(from responseData: Data) -> [Genre] {
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
                    fatalError("Json isn't a dictionary...")
                }
                
                guard let jsonGenres = json["genres"] as? [[String: Any]] else {
                    fatalError("'genres' property isn't an array of dictionaries...")
                }
                
                var genres: [Genre] = []
                
                for jsonGenre in jsonGenres {
                    guard let id = jsonGenre["id"] as? Int else {
                        fatalError("jsonGenre['id'] isn't a number...")
                    }
                    
                    guard let name = jsonGenre["name"] as? String else {
                        fatalError("jsonGenre['name'] isn't a string...")
                    }
                    
                    let genre = Genre(id: id, name: name)
                    
                    genres.append(genre)
                }
                
                return genres
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
    }
    
}
