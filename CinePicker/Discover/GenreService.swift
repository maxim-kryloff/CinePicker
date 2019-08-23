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
                
                guard let genres = self.getGenres(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                self.result = AsyncResult.success(genres)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetGenresRequest() -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/genre/movie/list")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getGenres(from responseData: Data) -> [Genre]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                guard let jsonResults = json["genres"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                
                var genres: [Genre] = []
                
                for jsonGenre in jsonResults {
                    let genre = try Genre.buildGenre(fromJson: jsonGenre)
                    genres.append(genre)
                }
                
                return genres
            } catch {
                return nil
            }
        }
        
    }
    
}
