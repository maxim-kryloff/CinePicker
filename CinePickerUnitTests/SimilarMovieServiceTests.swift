import XCTest
@testable import CinePicker

class SimilarMovieServiceTests: XCTestCase {
    
    private var mockMovieService: MockMovieService!
    
    private var similarMovieService: SimilarMovieService!
    
    private var fakeMovieId: Int!
    
    private var expectationPromise: XCTestExpectation!

    override func setUp() {
        super.setUp()
        mockMovieService = MockMovieService()
        similarMovieService = SimilarMovieService(movieService: mockMovieService)
        fakeMovieId = 0
        expectationPromise = expectation(description: "")
    }

    override func tearDown() {
        mockMovieService = nil
        similarMovieService = nil
        fakeMovieId = nil
        expectationPromise = nil
        super.tearDown()
    }

    func testShouldReturnSimilarMovies() {
        let similarMovieRequest = SimilarMovieRequest(movieId: fakeMovieId, page: 1)
        similarMovieService.requestMovies(request: similarMovieRequest) { (request, result) in
            XCTAssertEqual(similarMovieRequest.movieId, request.movieId)
            XCTAssertEqual(similarMovieRequest.page, request.page)
            XCTAssertEqual(result!.count, 10)
            self.expectationPromise.fulfill()
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingSimilarMoviesIsFailed() {
        mockMovieService.similarMoviesRequestIsFailed = true
        let similarMovieRequest = SimilarMovieRequest(movieId: fakeMovieId, page: 1)
        similarMovieService.requestMovies(request: similarMovieRequest) { (request, result) in
            XCTAssertEqual(similarMovieRequest.movieId, request.movieId)
            XCTAssertEqual(similarMovieRequest.page, request.page)
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}

extension SimilarMovieServiceTests {
    
    private class MockMovieService: MovieService {
        
        public var similarMoviesRequestIsFailed = false
        
        private let seeder = Seeder()
        
        override func getSimilarMovies(byMovieId movieId: Int, andPage page: Int, onComplete callback: @escaping (AsyncResult<[Movie]>) -> Void) {
            DispatchQueue.main.async {
                let movies = self.seeder.getMovies(count: 10)
                let result = self.similarMoviesRequestIsFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                callback(result)
            }
        }
    }
}
