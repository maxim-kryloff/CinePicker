import Foundation

class MovieDetailsService {

    private let movieService: MovieService
    
    private let personService: PersonService
    
    init(movieService: MovieService, personService: PersonService) {
        self.movieService = movieService
        self.personService = personService
    }
    
    public func requestPeople(
        by movieId: Int,
        callback: @escaping (_: (cast: [Character], crew: [CrewPerson])?) -> Void
    ) {
        let concurrentDispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        
        let dispatchGroup = DispatchGroup()
        
        var cast: [Character]?
        var crew: [CrewPerson]?
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestCharacters(by: movieId, dispatchGroup: dispatchGroup) { (result) in
                cast = result
            }
        }
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestCrewPeople(by: movieId, dispatchGroup: dispatchGroup) { (result) in
                crew = result
            }
        }
        
        dispatchGroup.notify(queue: concurrentDispatchQueue) {
            var result: (cast: [Character], crew: [CrewPerson])?
            
            if let cast = cast, let crew = crew {
                result = (cast: cast, crew: crew)
            }
            
            callback(result)
        }
    }
    
    public func requestMovieDetails(by movieId: Int, _ callback: @escaping (_: MovieDetails?) -> Void) {
        movieService.getMovieDetails(by: movieId) { (result) in
            var requestResult: MovieDetails?
            
            defer {
                callback(requestResult)
            }
            
            do {
                requestResult = try result.getValue()
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func requestCharacters(
        by movieId: Int,
        dispatchGroup: DispatchGroup,
        _ callback: @escaping (_: [Character]?) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.getCharacters(by: movieId) { (result) in
            var requestResult: [Character]?
            
            defer {
                callback(requestResult)
                dispatchGroup.leave()
            }
            
            do {
                let characters = try result.getValue()
                requestResult = characters.filter { !$0.imagePath.isEmpty }
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func requestCrewPeople(
        by movieId: Int,
        dispatchGroup: DispatchGroup,
        _ callback: @escaping (_: [CrewPerson]?) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.getCrewPeople(by: movieId) { (result) in
            var requestResult: [CrewPerson]?
            
            defer {
                callback(requestResult)
                dispatchGroup.leave()
            }
            
            do {
                var crewPeople = try result.getValue()
                crewPeople = crewPeople.filter { !$0.imagePath.isEmpty }
                
                var compactCrewPeople: [CrewPerson] = []
                
                for person in crewPeople {
                    if let index = compactCrewPeople.firstIndex(where: { $0.id == person.id }) {
                        compactCrewPeople[index].jobs += person.jobs
                        continue
                    }
                    
                    compactCrewPeople.append(person)
                }
                
                for person in compactCrewPeople {
                    person.jobs = self.getUniqueJobs(from: person.jobs)
                }
                
                requestResult = compactCrewPeople
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func getUniqueJobs(from jobs: [String]) -> [String] {
        var uniqueJobs: [String] = []
        
        for job in jobs {
            if uniqueJobs.contains(job) {
                continue
            }
            
            uniqueJobs.append(job)
        }
        
        return uniqueJobs
    }
    
}
