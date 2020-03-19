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
    
    func testShouldReturnMoviesAndPeopleSortedByPrimaryValueUsingKeyInsensetiveComparison() {
        mockMovieService.customSeedFunc = {
            return [
                Movie(
                    id: 0,
                    title: "Мальчишник в Европе",
                    originalTitle: "Budapest",
                    imagePath: "1.jpg",
                    rating: 5.7,
                    voteCount: 180,
                    releaseYear: "2018",
                    overview: "Описание",
                    popularity: 4.3
                ),
                Movie(
                    id: 1,
                    title: "Мир Юрского Периода",
                    originalTitle: "Jurassic World",
                    imagePath: "2.jpg",
                    rating: 6.6,
                    voteCount: 14360,
                    releaseYear: "2015",
                    overview: "Описание",
                    popularity: 5.6
                ),
                Movie(
                    id: 2,
                    title: "Это случилось в милиции",
                    originalTitle: "Eto Sluchilos v Militsii",
                    imagePath: "3.jpg",
                    rating: 6,
                    voteCount: 1,
                    releaseYear: "1963",
                    overview: "Описание",
                    popularity: 8.4
                ),
                Movie(
                    id: 3,
                    title: "Мир Юрского Периода 2",
                    originalTitle: "Jurassic World 2",
                    imagePath: "4.jpg",
                    rating: 6.9,
                    voteCount: 10234,
                    releaseYear: "2017",
                    overview: "Описание",
                    popularity: 8.9
                )
            ]
        }
        
        mockPersonService.customSeedFunc = {
            return [
                PopularPerson(
                    id: 0,
                    name: "Михаил Иванов",
                    imagePath: "5.jpg",
                    popularity: 3.4
                ),
                PopularPerson(
                    id: 1,
                    name: "Мир Юрьев",
                    imagePath: "6.jpg",
                    popularity: 4.5
                )
            ]
        }
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: "миР юР", page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertEqual(result!.map { $0.primaryValueToSort }, [
                "Мир Юрского Периода 2",
                "Мир Юрского Периода",
                "Мир Юрьев",
                "Это случилось в милиции",
                "Михаил Иванов",
                "Мальчишник в Европе",
            ])
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnMoviesAndPeopleSortedBySecondaryValueUsingKeyInsensetiveComparison() {
        mockMovieService.customSeedFunc = {
            return [
                Movie(
                    id: 0,
                    title: "Budapest",
                    originalTitle: "Мальчишник в Европе",
                    imagePath: "1.jpg",
                    rating: 5.7,
                    voteCount: 180,
                    releaseYear: "2018",
                    overview: "Описание",
                    popularity: 4.3
                ),
                Movie(
                    id: 1,
                    title: "Jurassic World",
                    originalTitle: "Мир Юрского Периода",
                    imagePath: "2.jpg",
                    rating: 6.6,
                    voteCount: 14360,
                    releaseYear: "2015",
                    overview: "Описание",
                    popularity: 5.6
                ),
                Movie(
                    id: 2,
                    title: "Eto Sluchilos v Militsii",
                    originalTitle: "Это случилось в милиции",
                    imagePath: "3.jpg",
                    rating: 6,
                    voteCount: 1,
                    releaseYear: "1963",
                    overview: "Описание",
                    popularity: 8.4
                ),
                Movie(
                    id: 3,
                    title: "Jurassic World 2",
                    originalTitle: "Мир Юрского Периода 2",
                    imagePath: "4.jpg",
                    rating: 6.9,
                    voteCount: 10234,
                    releaseYear: "2017",
                    overview: "Описание",
                    popularity: 8.9
                )
            ]
        }
        
        mockPersonService.customSeedFunc = {
            return [
                PopularPerson(
                    id: 0,
                    name: "Михаил Иванов",
                    imagePath: "5.jpg",
                    popularity: 3.4
                ),
                PopularPerson(
                    id: 1,
                    name: "Мир Юрьев",
                    imagePath: "6.jpg",
                    popularity: 4.5
                )
            ]
        }
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: "миР юР", page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertEqual(result!.map { $0.primaryValueToSort }, [
                "Jurassic World 2",
                "Jurassic World",
                "Мир Юрьев",
                "Eto Sluchilos v Militsii",
                "Михаил Иванов",
                "Budapest",
            ])
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnMoviesAndPeopleSortedByFirstPrimaryAndSecondSecondaryValueUsingKeyInsensetiveComparison() {
        mockMovieService.customSeedFunc = {
            return [
                Movie(
                    id: 0,
                    title: "Value BB Movie 1",
                    originalTitle: "Value AA Movie 1",
                    imagePath: "imagePath",
                    rating: 0,
                    voteCount: 0,
                    releaseYear: "",
                    overview: "Description",
                    popularity: 0
                ),
                Movie(
                    id: 1,
                    title: "Value AA Movie 2",
                    originalTitle: "Value BB Movie 2",
                    imagePath: "imagePath",
                    rating: 0,
                    voteCount: 0,
                    releaseYear: "",
                    overview: "Description",
                    popularity: 0
                )
            ]
        }
        
        mockPersonService.customSeedFunc = {
            return [
                PopularPerson(
                    id: 0,
                    name: "Value AA Person 1",
                    imagePath: "imagePath",
                    popularity: 0
                )
            ]
        }
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: "vAlUe Aa", page: 1)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, result) in
            XCTAssertEqual(multiSearchRequest.searchQuery, request.searchQuery)
            XCTAssertEqual(multiSearchRequest.page, request.page)
            
            XCTAssertEqual(result!.map { $0.primaryValueToSort }, [
                "Value AA Person 1",
                "Value AA Movie 2",
                "Value BB Movie 1"
            ])
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
}

extension MultiSearchServiceTests {
    
    private class MockPersonService: PersonService {
        
        public var searchPopularPeopleDelayMilliseconds: Int = 0
        
        public var isSearchPopularPeopleRequestFailed = false
        
        public var customSeedFunc: (() -> [PopularPerson])?
        
        private let seeder = Seeder()
        
        override func searchPopularPeople(by searchQuery: String, andPage page: Int, onComplete callback: @escaping (AsyncResult<[PopularPerson]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(searchPopularPeopleDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let popularPeople = self.customSeedFunc != nil
                    ? self.customSeedFunc!()
                    : self.seeder.getPopularPeople(count: 10)
                
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
        
        public var customSeedFunc: (() -> [Movie])?
        
        private let seeder = Seeder()
        
        override func searchMovies(by searchQuery: String, andPage page: Int, onComplete callback: @escaping (AsyncResult<[Movie]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(searchMoviesDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let movies = self.customSeedFunc != nil
                    ? self.customSeedFunc!()
                    : self.seeder.getMovies(count: 10)
                
                let result = self.isSearchMoviesRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                
                callback(result)
            }
        }
        
    }
    
}
