import Foundation

class SimilarMovieService {
    
    private let movieService: MovieService
    
    init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public func requestMovies(
        byMovieId movieId: Int,
        callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        let concurrentDispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility, attributes: [.concurrent])
        let serialDispatchQueue = DispatchQueue(label: UUID().uuidString, qos: .utility)
        
        let dispatchGroup = DispatchGroup()
        
        var similarMovies: [Movie] = []
        
        var isRequestFailedAt: [Int: Bool] = [:]
        
        for page in 1...3 {
            concurrentDispatchQueue.async(group: dispatchGroup) {
                self.requestMovies(byMovieId: movieId, andPage: page, dispatchGroup: dispatchGroup) { (result, isRequestFailed) in
                    defer {
                        isRequestFailedAt[page] = isRequestFailed
                    }
                    
                    if isRequestFailed {
                        return
                    }
                    
                    serialDispatchQueue.async {
                        similarMovies += result
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: concurrentDispatchQueue) {
            var isRequestFailed = false
            
            for page in 1...3 {
                isRequestFailed = isRequestFailed || isRequestFailedAt[page] ?? true
            }

            callback(similarMovies, isRequestFailed)
        }
    }
    
    private func requestMovies(
        byMovieId movieId: Int,
        andPage page: Int,
        dispatchGroup: DispatchGroup,
        callback: @escaping (_: [Movie], _ isLoadingDataFailed: Bool) -> Void
    ) {
        dispatchGroup.enter()
        
        movieService.getSimilarMovies(byMovieId: movieId, andPage: page) { (result) in
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
