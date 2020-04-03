import Foundation

class PersonService {
    
    private let searchPopularPeopleOperationQueue = OperationQueue()
    
    func searchPopularPeople(
        by searchQuery: String,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[PopularPerson]>) -> Void
    ) {
        searchPopularPeopleOperationQueue.cancelAllOperations()
        let operation = createSearchPopularPeopleOperation(searchBy: searchQuery, andPage: page, onComplete: callback)
        searchPopularPeopleOperationQueue.addOperation(operation)
    }
    
    private func createSearchPopularPeopleOperation(
        searchBy query: String,
        andPage page: Int,
        onComplete callback: @escaping (_: AsyncResult<[PopularPerson]>) -> Void
    ) -> SearchPopularPeopleOperation {
        let operation = SearchPopularPeopleOperation()
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
    
    private let getCharactersOperationQueue = OperationQueue()
    
    public func getCharacters(
        by movieId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Character]>) -> Void
    ) {
        getCharactersOperationQueue.cancelAllOperations()
        let operation = createGetCharactersOperation(gotBy: movieId, onComplete: callback)
        getCharactersOperationQueue.addOperation(operation)
    }
    
    private func createGetCharactersOperation(
        gotBy movieId: Int,
        onComplete callback: @escaping (_: AsyncResult<[Character]>) -> Void
    ) -> GetCharactersOperation {
        let operation = GetCharactersOperation()
        operation.movieId = movieId
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
    }
    
    private let getCrewPeopleOperationQueue = OperationQueue()
    
    public func getCrewPeople(
        by movieId: Int,
        onComplete callback: @escaping (_: AsyncResult<[CrewPerson]>) -> Void
    ) {
        getCrewPeopleOperationQueue.cancelAllOperations()
        let operation = createGetCrewPeopleOperation(gotBy: movieId, onComplete: callback)
        getCrewPeopleOperationQueue.addOperation(operation)
    }
    
    private func createGetCrewPeopleOperation(
        gotBy movieId: Int,
        onComplete callback: @escaping (_: AsyncResult<[CrewPerson]>) -> Void
    ) -> GetCrewPeopleOperation {
        let operation = GetCrewPeopleOperation()
        operation.movieId = movieId
        operation.qualityOfService = .utility
        operation.completionBlock = {
            if let result = operation.result {
                callback(result)
            }
        }
        return operation
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
            let searchPopularPeopleRequest = buildSearchPopularPeopleRequest()
            let task = session.dataTask(with: searchPopularPeopleRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let popularPeople = self.getPopularPeople(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(popularPeople)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildSearchPopularPeopleRequest() -> URLRequest {
            let url = buildSearchPopularPeopleUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildSearchPopularPeopleUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/search/person")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .append(queryItem: ("query", searchQuery))
                .append(queryItem: ("page", String(page)))
                .build()
            return url!
        }
        
        private func getPopularPeople(from responseData: Data) -> [PopularPerson]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["results"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var popularPeople: [PopularPerson] = []
                for item in jsonResults {
                    let person = try PopularPerson.buildPopularPerson(fromJson: item)
                    popularPeople.append(person)
                }
                return popularPeople
            } catch {
                return nil
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
            let getCharactersRequest = buildGetCharactersRequest()
            let task = session.dataTask(with: getCharactersRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let characters = self.getCharacters(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(characters)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetCharactersRequest() -> URLRequest {
            let url = buildGetCharactersUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetCharactersUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId!)/credits")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .build()
            return url!
        }
        
        private func getCharacters(from responseData: Data) -> [Character]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["cast"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var characters: [Character] = []
                for item in jsonResults {
                    let character = try Character.buildCharacter(fromJson: item)
                    characters.append(character)
                }
                return characters
            } catch {
                return nil
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
            let getCrewPeopleRequest = buildGetCrewPeopleRequest()
            let task = session.dataTask(with: getCrewPeopleRequest) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                guard let crewPeople = self.getCrewPeople(from: data) else {
                    self.result = AsyncResult.failure(ResponseError.dataIsNil)
                    self.state = .isFinished
                    return
                }
                self.result = AsyncResult.success(crewPeople)
                self.state = .isFinished
            }
            task.resume()
        }
        
        private func buildGetCrewPeopleRequest() -> URLRequest {
            let url = buildGetCrewPeopleUrl()
            return URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        }
        
        private func buildGetCrewPeopleUrl() -> URL {
            let url = URLBuilder(string: CinePickerConfig.apiPath)
                .append(pathComponent: "/movie/\(movieId!)/credits")
                .append(queryItem: ("api_key", CinePickerConfig.apiToken))
                .append(queryItem: ("language", CinePickerConfig.getLanguageCode()))
                .build()
            return url!
        }
        
        private func getCrewPeople(from responseData: Data) -> [CrewPerson]? {
            do {
                let json = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                guard let jsonResults = json["crew"] as? [[String: Any]] else {
                    throw ResponseError.jsonDoesNotHaveProperty
                }
                var crewPeople: [CrewPerson] = []
                for item in jsonResults {
                    let crewPerson = try CrewPerson.buildCrewPerson(fromJson: item)
                    crewPeople.append(crewPerson)
                }
                return crewPeople
            } catch {
                return nil
            }
        }
    }
}
