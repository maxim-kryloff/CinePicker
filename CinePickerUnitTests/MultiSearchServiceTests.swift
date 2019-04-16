import XCTest
@testable import CinePicker

class MultiSearchServiceTests: XCTestCase {
    
    private var mockMovieService: MockMovieService!
    
    private var mockPersonService: MockPersonService!
    
    private var multiSearchService: MultiSearchService!
    
    private var fakeSearchQuery: String!
    
    private var expectationPromise: XCTestExpectation!

    override func setUp() {
        super.setUp()
        
        mockMovieService = MockMovieService()
        mockPersonService = MockPersonService()
        multiSearchService = MultiSearchService(movieService: mockMovieService, personService: mockPersonService)
        
        fakeSearchQuery = "something"
        expectationPromise = expectation(description: "")
    }

    override func tearDown() {
        mockMovieService = nil
        mockPersonService = nil
        multiSearchService = nil
        
        fakeSearchQuery = nil
        expectationPromise = nil
        
        super.tearDown()
    }
    
    func testShouldReturnMoviesAndPeople() {
        let multiSearchRequest = MultiSearchRequest(searchQuery: fakeSearchQuery, page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertEqual(result!.count, 20)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnMoviesAndPeopleWhenRequestingMoviesIsSlower() {
        mockMovieService.searchMoviesDelayMilliseconds = 10
        mockPersonService.searchPopularPeopleDelayMilliseconds = 5
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: fakeSearchQuery, page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertEqual(result!.count, 20)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnMoviesAndPeopleWhenRequestingPeopleIsSlower() {
        mockMovieService.searchMoviesDelayMilliseconds = 5
        mockPersonService.searchPopularPeopleDelayMilliseconds = 10
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: fakeSearchQuery, page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertEqual(result!.count, 20)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingMoviesIsFailed() {
        mockMovieService.isSearchMoviesRequestFailed = true
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: fakeSearchQuery, page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertNil(result)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingPeopleIsFailed() {
        mockPersonService.isSearchPopularPeopleRequestFailed = true
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: fakeSearchQuery, page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertNil(result)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

extension MultiSearchServiceTests {
    
    private class MockPersonService: PersonService {
        
        public var searchPopularPeopleDelayMilliseconds: Int = 0
        
        public var isSearchPopularPeopleRequestFailed = false
        
        private let seeder = Seeder()
        
        override func searchPopularPeople(by searchQuery: String, andPage page: Int, callback: @escaping (AsyncResult<[PopularPerson]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(searchPopularPeopleDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let popularPeople = self.seeder.getPopularPeople(count: 10)
                
                let result = self.isSearchPopularPeopleRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(popularPeople)
                
                callback(result)
            }
        }
        
    }
    
    private class MockMovieService: MovieService {
        
        public var searchMoviesDelayMilliseconds: Int = 0
        
        public var isSearchMoviesRequestFailed = false
        
        private let seeder = Seeder()
        
        override func searchMovies(by searchQuery: String, andPage page: Int, callback: @escaping (AsyncResult<[Movie]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(searchMoviesDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let movies = self.seeder.getMovies(count: 10)
                
                let result = self.isSearchMoviesRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                
                callback(result)
            }
        }
        
    }
    
}
