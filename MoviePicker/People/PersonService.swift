import Foundation

class PersonService {
    
    private let searchActorsOperationQueue = OperationQueue()
    
    func searchActors(by searchQuery: String, andPage page: Int, callback: @escaping (_: AsyncResult<[Actor]>) -> Void) {
        searchActorsOperationQueue.cancelAllOperations()
        
        let operation = SearchActorsOperation()
        
        operation.searchQuery = searchQuery
        operation.page = page
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        searchActorsOperationQueue.addOperation(operation)
    }
    
    private let getCharactersOperationQueue = OperationQueue()
    
    public func getCharacters(by movieId: Int, callback: @escaping (_: AsyncResult<[Character]>) -> Void) {
        getCharactersOperationQueue.cancelAllOperations()
        
        let operation = GetCharactersOperation()
        
        operation.movieId = movieId
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getCharactersOperationQueue.addOperation(operation)
    }
    
}

extension PersonService {
    
    private class SearchActorsOperation: AsyncOperation {
        
        public var result: AsyncResult<[Actor]>?
        
        public var searchQuery = ""
        
        public var page: Int = 0
        
        override func main() {
            if isCancelled {
                return
            }
            
            let session = URLSession.shared
            let searchActorsRequest = buildSearchActorsRequest(withSearchQuery: searchQuery)
            
            let task = session.dataTask(with: searchActorsRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let actors = self.getActors(from: data)
                
                self.result = AsyncResult.success(actors)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildSearchActorsRequest(withSearchQuery query: String) -> URLRequest {
            let url: URL! = URLBuilder(string: MoviePickerConfig.apiPath)
                .append(pathComponent: "/search/person")
                .append(queryItem: ("api_key", MoviePickerConfig.apiToken))
                .append(queryItem: ("language", MoviePickerConfig.language))
                .append(queryItem: ("query", query))
                .append(queryItem: ("page", String(page)))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getActors(from responseData: Data) -> [Actor] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["results"] as! [[String: Any]]
                
                var people: [Actor] = []
                
                for result in jsonResults {
                    let id = result["id"] as! Int
                    
                    let name = result["name"] as! String
                    
                    let profilePath = result["profile_path"] as? String
                    
                    let popularity = result["popularity"] as! Double
                    
                    let person = Actor(id: id, name: name, imagePath: profilePath, popularity: popularity)
                    
                    people.append(person)
                }
                
                return people
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}

extension PersonService {
    
    private class GetCharactersOperation: AsyncOperation {
        
        public var result: AsyncResult<[Character]>?
        
        public var movieId: Int = 0
        
        override func main() {
            if isCancelled {
                return
            }
            
            let session = URLSession.shared
            let getCharactersRequest = buildGetCharactersRequest(withMovieId: movieId)
            
            let task = session.dataTask(with: getCharactersRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let characters = self.getCharacters(from: data)
                
                self.result = AsyncResult.success(characters)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetCharactersRequest(withMovieId movieId: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: MoviePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId)/credits")
                .append(queryItem: ("api_key", MoviePickerConfig.apiToken))
                .append(queryItem: ("language", MoviePickerConfig.language))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getCharacters(from responseData: Data) -> [Character] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["cast"] as! [[String: Any]]
                
                var characters: [Character] = []
                
                for item in jsonResults {
                    let id = item["id"] as! Int
                    
                    let name = item["name"] as! String
                    
                    let profilePath = item["profile_path"] as? String
                    
                    let characterName = item["character"] as! String
                    
                    let character = Character(id: id, name: name, imagePath: profilePath, characterName: characterName)
                    
                    characters.append(character)
                }
                
                return characters
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}
