import Foundation

class MovieListService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(
        by personId: Int,
        onComplete callback: @escaping (_: (cast: [Movie], crew: [Movie])?) -> Void
    ) {
        let requestMoviesDispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        let dispatchGroup = DispatchGroup()
        
        var castMovies: [Movie]?
        requestMoviesDispatchQueue.async(group: dispatchGroup) {
            self.requestMovies(byPerson: personId, dispatchGroup: dispatchGroup) { (result) in
                castMovies = result
            }
        }
        
        var crewMovies: [Movie]?
        requestMoviesDispatchQueue.async(group: dispatchGroup) {
            self.requestMovies(byCrewMember: personId, dispatchGroup: dispatchGroup) { (result) in
                crewMovies = result
            }
        }
        
        dispatchGroup.notify(queue: requestMoviesDispatchQueue) {
            var result: (cast: [Movie], crew: [Movie])?
            if let cast = castMovies, let crew = crewMovies {
                result = (cast: cast, crew: crew)
            }
            callback(result)
        }
    }
    
    private func requestMovies(
        byPerson personId: Int,
        dispatchGroup: DispatchGroup,
        onComplete callback: @escaping (_: [Movie]?) -> Void
    ) {
        dispatchGroup.enter()
        movieService.getMovies(byPerson: personId) { (result) in
            var requestResult: [Movie]?
            defer {
                callback(requestResult)
                dispatchGroup.leave()
            }
            do {
                let movies = try result.getValue()
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result.")
            }
        }
    }
    
    private func requestMovies(
        byCrewMember personId: Int,
        dispatchGroup: DispatchGroup,
        onComplete callback: @escaping (_: [Movie]?) -> Void
    ) {
        dispatchGroup.enter()
        movieService.getMovies(byCrewMember: personId) { (result) in
            var requestResult: [Movie]?
            defer {
                callback(requestResult)
                dispatchGroup.leave()
            }
            do {
                let movies = try result.getValue()
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result.")
            }
        }
    }
}
