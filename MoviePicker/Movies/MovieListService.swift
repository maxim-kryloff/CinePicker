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
        var isLoadingCastMoviesFailed = false
        
        var crewMovies: [Movie] = []
        var isLoadingCrewMoviesFailed = false
        
        concurrentDispatchQueue.async(group: dispatchGroup) {
            self.requestMovies(byActor: personId, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
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
            let isFailed = isLoadingCastMoviesFailed && isLoadingCrewMoviesFailed
            
            callback(result, isFailed)
        }
    }
    
    private func requestMovies(
        byActor personId: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        movieService.getMovies(byActor: personId) { (result) in
            var requestResult: [Movie] = []
            var isFailed = false
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { $0.imagePath != nil }
                    .filter { $0.overview != nil && $0.overview != "" }
                
            } catch ResponseError.dataIsNil {
                isFailed = true
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
            var isFailed = false
            
            defer {
                callback(requestResult, isFailed)
                dispatchGroup.leave()
            }
            
            do {
                let movies = try result.getValue()
                
                requestResult = movies
                    .filter { $0.imagePath != nil }
                    .filter { $0.overview != nil && $0.overview != "" }
                
            } catch ResponseError.dataIsNil {
                isFailed = true
            } catch {
                fatalError("Unexpected async result...")
            }
        }
    }
    
}
