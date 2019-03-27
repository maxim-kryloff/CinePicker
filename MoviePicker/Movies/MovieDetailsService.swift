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
        callback: @escaping (_: (cast: [Character], crew: [CrewPerson]), _ isLoadingDataFailed: Bool) -> Void
    ) {
        let concurrentDispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        
        let dispatchGroup = DispatchGroup()
        
        var cast: [Character] = []
        var isLoadingCastFailed = true
        
        var crew: [CrewPerson] = []
        var isLoadingCrewFailed = true
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestCharacters(by: movieId, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                cast = result
                isLoadingCastFailed = isRequestFailed
            }
        }
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestCrewPeople(by: movieId, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                crew = result
                isLoadingCrewFailed = isRequestFailed
            }
        }
        
        dispatchGroup.notify(queue: concurrentDispatchQueue) {
            let result = (cast: cast, crew: crew)
            let isFailed = isLoadingCastFailed || isLoadingCrewFailed
            
            callback(result, isFailed)
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
        _ callback: @escaping (_: [Character], _ isLoadingDataFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.getCharacters(by: movieId) { (result) in
            var requestResult: [Character] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let characters = try result.getValue()
                requestResult = characters.filter { !$0.imagePath.isEmpty }
                
                isFailed = false
                
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
        _ callback: @escaping (_: [CrewPerson], _ isLoadingDataFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        personService.getCrewPeople(by: movieId) { (result) in
            var requestResult: [CrewPerson] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
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
                
                for compactPerson in compactCrewPeople {
                    compactPerson.jobs = self.getUniqueJobs(from: compactPerson.jobs)
                }
                
                requestResult = compactCrewPeople
                
                isFailed = false
                
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
