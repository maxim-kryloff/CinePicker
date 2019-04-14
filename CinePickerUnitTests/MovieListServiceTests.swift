import XCTest
@testable import CinePicker

class MovieListServiceTests: XCTestCase {
    
    private var mockMovieService: MockMovieService!
    
    private var movieListService: MovieListService!
    
    private var fakePersonId: Int!
    
    private var expectationPromise: XCTestExpectation!

    override func setUp() {
        super.setUp()
        
        mockMovieService = MockMovieService()
        movieListService = MovieListService(movieService: mockMovieService)
        
        fakePersonId = 0
        expectationPromise = expectation(description: "")
    }

    override func tearDown() {
        mockMovieService = nil
        movieListService = nil
        
        fakePersonId = nil
        expectationPromise = nil
        
        super.tearDown()
    }

    func testShouldReturnCastAndCrew() {
        movieListService.requestMovies(by: fakePersonId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnCastAndCrewWhenRequestingPersonMoviesIsSlower() {
        mockMovieService.getPersonMoviesDelayMilliseconds = 10
        mockMovieService.getCrewPersonMoviesDelayMilliseconds = 5
        
        movieListService.requestMovies(by: fakePersonId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            XCTAssertEqual(self.mockMovieService.callstack, ["getCrewPersonMovies", "getPersonMovies"])
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnCastAndCrewWhenRequestingCrewPersonMoviesIsSlower() {
        mockMovieService.getPersonMoviesDelayMilliseconds = 5
        mockMovieService.getCrewPersonMoviesDelayMilliseconds = 10
        
        movieListService.requestMovies(by: fakePersonId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            XCTAssertEqual(self.mockMovieService.callstack, ["getPersonMovies", "getCrewPersonMovies"])
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingPersonMoviesIsFailed() {
        mockMovieService.isPersonMoviesRequestFailed = true
        
        movieListService.requestMovies(by: fakePersonId) { (result) in
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingCrewPersonMoviesIsFailed() {
        mockMovieService.isCrewMemberMoviesRequestFailed = true
        
        movieListService.requestMovies(by: fakePersonId) { (result) in
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

extension MovieListServiceTests {
    
    private class MockMovieService: MovieService {
        
        public var getPersonMoviesDelayMilliseconds: Int = 0
        
        public var getCrewPersonMoviesDelayMilliseconds: Int = 0
        
        public var isPersonMoviesRequestFailed = false
        
        public var isCrewMemberMoviesRequestFailed = false
        
        public var callstack: [String] = []
        
        private let seeder = Seeder()
        
        override func getMovies(byPerson personId: Int, callback: @escaping (AsyncResult<[Movie]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(getPersonMoviesDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let movies = self.seeder.getMovies(count: 10)
                
                let result = self.isPersonMoviesRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                
                self.callstack.append("getPersonMovies")
                
                callback(result)
            }
        }
        
        override func getMovies(byCrewMember personId: Int, callback: @escaping (AsyncResult<[Movie]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(getCrewPersonMoviesDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let movies = self.seeder.getMovies(count: 10)
                
                let result = self.isCrewMemberMoviesRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                
                self.callstack.append("getCrewPersonMovies")
                
                callback(result)
            }
        }
        
    }
    
}
