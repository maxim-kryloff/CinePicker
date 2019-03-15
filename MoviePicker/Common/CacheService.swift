import Foundation

class CacheService {
    
    private static var instance: CacheService?
    
    public static var shared: CacheService {
        if instance == nil {
            instance = CacheService()
        }
        
        return instance!
    }
    
    private let concurrentCacheOperationQueue: OperationQueue
    
    private let serialCacheOperationQueue: OperationQueue
    
    private var genres: [Genre] = []
    
    private let genreService: GenreService
    
    private init() {
        concurrentCacheOperationQueue = OperationQueue()
        
        serialCacheOperationQueue = OperationQueue()
        serialCacheOperationQueue.maxConcurrentOperationCount = 1
        
        genreService = GenreService()
    }
    
    public func getGenres(callback: @escaping (_: [Genre]) -> Void) {
        if !genres.isEmpty {
            concurrentCacheOperationQueue.addOperation {
                callback(self.genres)
            }
            
            return
        }
        
        genreService.getGenres { (result) in
            // Because of concurrency it can override self.genres but in serial mode, so self.genres is thread safe itself
            self.serialCacheOperationQueue.addOperation {
                do {
                    self.genres = try result.getValue()
                } catch ResponseError.dataIsNil {
                    self.genres = []
                } catch {
                    fatalError("Unexpected async result...")
                }
                
                callback(self.genres)
            }
        }
    }
    
}
