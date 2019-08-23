import XCTest
@testable import CinePicker

class DiscoverSettingsServiceTests: XCTestCase {

    private var mockGenreService: MockGenreService!
    
    private var mockMovieService: MockMovieService!
    
    private var discoverSettingsService: DiscoverSettingsService!
    
    private var expectationPromise: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        mockGenreService = MockGenreService()
        mockMovieService = MockMovieService()
        
        discoverSettingsService = DiscoverSettingsService(genreService: mockGenreService, movieService: mockMovieService)
        
        expectationPromise = expectation(description: "")
    }
    
    override func tearDown() {
        mockGenreService = nil
        discoverSettingsService = nil
        
        super.tearDown()
    }
    
    func testShouldReturnGenres() {
        discoverSettingsService.requestGenres { result in
            XCTAssertEqual(result!.count, 10)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingGenresIsFailed() {
        mockGenreService.isGenreRequestFailed = true
        
        discoverSettingsService.requestGenres { result in
            XCTAssertNil(result)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnDiscoveredMovies() {
        let discoveredMovieRequest = DiscoveredMovieRequest(genreIds: [], year: nil, rating: nil, page: 1)
        
        discoverSettingsService.requestDiscoveredMovies(request: discoveredMovieRequest) { (request, result) in
            XCTAssertEqual(discoveredMovieRequest.genreIds, request.genreIds)
            XCTAssertEqual(discoveredMovieRequest.page, request.page)
            XCTAssertEqual(discoveredMovieRequest.rating, request.rating)
            XCTAssertEqual(discoveredMovieRequest.year, request.year)
            
            XCTAssertEqual(result!.count, 10)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingDiscoveredMoviesIsFailed() {
        mockMovieService.isDiscoveredMoviesRequestFailed = true
        
        let discoveredMovieRequest = DiscoveredMovieRequest(genreIds: [], year: nil, rating: nil, page: 1)
        
        discoverSettingsService.requestDiscoveredMovies(request: discoveredMovieRequest) { (request, result) in
            XCTAssertEqual(discoveredMovieRequest.genreIds, request.genreIds)
            XCTAssertEqual(discoveredMovieRequest.page, request.page)
            XCTAssertEqual(discoveredMovieRequest.rating, request.rating)
            XCTAssertEqual(discoveredMovieRequest.year, request.year)
            
            XCTAssertNil(result)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
}

extension DiscoverSettingsServiceTests {
    
    private class MockGenreService: GenreService {
        
        public var isGenreRequestFailed = false
        
        private let seeder = Seeder()
        
        override func getGenres(callback: @escaping (AsyncResult<[Genre]>) -> Void) {
            DispatchQueue.main.async {
                let genres = self.seeder.getGenres(count: 10)
                
                let result = self.isGenreRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(genres)
                
                callback(result)
            }
        }
        
    }
    
}

extension DiscoverSettingsServiceTests {
    
    private class MockMovieService: MovieService {
        
        public var isDiscoveredMoviesRequestFailed = false
        
        private let seeder = Seeder()
        
        override func getDiscoveredMovies(
            withGenres genreIds: [Int]?,
            andYear year: String?,
            gteRating rating: Double?,
            andPage page: Int,
            callback: @escaping (AsyncResult<[Movie]>) -> Void
        ) {
            
            DispatchQueue.main.async {
                let movies = self.seeder.getMovies(count: 10)
                
                let result = self.isDiscoveredMoviesRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                
                callback(result)
            }
        }
        
    }
    
}
