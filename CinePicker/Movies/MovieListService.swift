import Foundation

class MovieListService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(
        by personId: Int,
        callback: @escaping (_: (cast: [Movie], crew: [Movie]), _ isLoadingDataFailed: Bool) -> Void
    ) {
        let concurrentDispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        
        let dispatchGroup = DispatchGroup()
        
        var castMovies: [Movie] = []
        var isLoadingCastMoviesFailed = true
        
        var crewMovies: [Movie] = []
        var isLoadingCrewMoviesFailed = true
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestMovies(byPerson: personId, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                castMovies = result
                isLoadingCastMoviesFailed = isRequestFailed
            }
        }
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestMovies(byCrewMember: personId, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                crewMovies = result
                isLoadingCrewMoviesFailed = isRequestFailed
            }
        }
        
        dispatchGroup.notify(queue: concurrentDispatchQueue) {
            let result = (cast: castMovies, crew: crewMovies)
            let isFailed = isLoadingCastMoviesFailed || isLoadingCrewMoviesFailed
            
            callback(result, isFailed)
        }
    }
    
    private func requestMovies(
        byPerson personId: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        movieService.getMovies(byPerson: personId) { (result) in
            var requestResult: [Movie] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
                
                isFailed = false
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
    private func requestMovies(
        byCrewMember personId: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        movieService.getMovies(byCrewMember: personId) { (result) in
            var requestResult: [Movie] = []
            var isFailed = true
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { !$0.imagePath.isEmpty }
                    .filter { !$0.overview.isEmpty }
                
                isFailed = false
                
            } catch ResponseError.dataIsNil {
                return
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
