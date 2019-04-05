import Foundation

class PersonService {
    
    private let searchPopularPeopleOperationQueue = OperationQueue()
    
    func searchPopularPeople(by searchQuery: String, andPage page: Int, callback: @escaping (_: AsyncResult<[PopularPerson]>) -> Void) {
        searchPopularPeopleOperationQueue.cancelAllOperations()
        
        let operation = SearchPopularPeopleOperation()
        
        operation.searchQuery = searchQuery
        operation.page = page
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        searchPopularPeopleOperationQueue.addOperation(operation)
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
    
    private let getCrewPeopleOperationQueue = OperationQueue()
    
    public func getCrewPeople(by movieId: Int, callback: @escaping (_: AsyncResult<[CrewPerson]>) -> Void) {
        getCrewPeopleOperationQueue.cancelAllOperations()
        
        let operation = GetCrewPeopleOperation()
        
        operation.movieId = movieId
        operation.qualityOfService = .utility
        
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        
        getCrewPeopleOperationQueue.addOperation(operation)
    }
    
}

extension PersonService {
    
    private class SearchPopularPeopleOperation: AsyncOperation {
        
        public var result: AsyncResult<[PopularPerson]>?
        
        public var searchQuery: String!
        
        public var page: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            
            let session = URLSession.shared
            let searchPopularPeopleRequest = buildSearchPopularPeopleRequest(withSearchQuery: searchQuery)
            
            let task = session.dataTask(with: searchPopularPeopleRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let popularPeople = self.getPopularPeople(from: data)
                
                self.result = AsyncResult.success(popularPeople)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildSearchPopularPeopleRequest(withSearchQuery query: String) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/search/person")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .append(queryItem: ("query", query))
                .append(queryItem: ("page", String(page)))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getPopularPeople(from responseData: Data) -> [PopularPerson] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["results"] as! [[String: Any]]
                
                var popularPeople: [PopularPerson] = []
                
                for item in jsonResults {
                    let person = PopularPerson.buildPopularPerson(fromJson: item)
                    popularPeople.append(person)
                }
                
                return popularPeople
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}

extension PersonService {
    
    private class GetCharactersOperation: AsyncOperation {
        
        public var result: AsyncResult<[Character]>?
        
        public var movieId: Int!
        
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
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId)/credits")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getCharacters(from responseData: Data) -> [Character] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["cast"] as! [[String: Any]]
                
                var characters: [Character] = []
                
                for item in jsonResults {
                    let character = Character.buildCharacter(fromJson: item)
                    characters.append(character)
                }
                
                return characters
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}

extension PersonService {
    
    private class GetCrewPeopleOperation: AsyncOperation {
        
        public var result: AsyncResult<[CrewPerson]>?
        
        public var movieId: Int!
        
        override func main() {
            if isCancelled {
                return
            }
            
            let session = URLSession.shared
            let getCrewPeopleRequest = buildGetCrewPeopleRequest(withMovieId: movieId)
            
            let task = session.dataTask(with: getCrewPeopleRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    
                    return
                }
                
                let crewPeople = self.getCrewPeople(from: data)
                
                self.result = AsyncResult.success(crewPeople)
                self.state = .isFinished
            }
            
            task.resume()
        }
        
        private func buildGetCrewPeopleRequest(withMovieId movieId: Int) -> URLRequest {
            let url: URL! = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId)/credits")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguage()))
                .build()
            
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func getCrewPeople(from responseData: Data) -> [CrewPerson] {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                
                let jsonResults = json["crew"] as! [[String: Any]]
                
                var crewPeople: [CrewPerson] = []
                
                for item in jsonResults {
                    let crewPerson = CrewPerson.buildCrewPerson(fromJson: item)
                    crewPeople.append(crewPerson)
                }
                
                return crewPeople
                
            } catch {
                fatalError("Recieved json wasn't serialized...")
            }
        }
        
    }
    
}
