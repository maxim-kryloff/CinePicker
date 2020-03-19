import XCTest
@testable import CinePicker

class MovieDetailsServiceTests: XCTestCase {
    
    private var mockMovieService: MockMovieService!
    
    private var mockPersonService: MockPersonService!
    
    private var movieDetailsService: MovieDetailsService!
    
    private var fakeMovieId: Int!
    
    private var fakeCollectionId: Int!
    
    private var expectationPromise: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        mockMovieService = MockMovieService()
        mockPersonService = MockPersonService()
        movieDetailsService = MovieDetailsService(movieService: mockMovieService, personService: mockPersonService)
        
        fakeMovieId = 0
        fakeCollectionId = 0
        expectationPromise = expectation(description: "")
    }

    override func tearDown() {
        mockMovieService = nil
        mockPersonService = nil
        movieDetailsService = nil
        
        fakeMovieId = nil
        fakeCollectionId = nil
        expectationPromise = nil
        
        super.tearDown()
    }
    
    func testShouldReturnMovieDetails() {
        movieDetailsService.requestMovieDetails(by: fakeMovieId) { (result) in
            XCTAssertNotNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingMovieDetailsIsFailed() {
        mockMovieService.isMovieDetailsRequestFaield = true
        
        movieDetailsService.requestMovieDetails(by: fakeMovieId) { (result) in
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnMoviesByCollectionId() {
        movieDetailsService.requestMovies(byCollectionId: fakeCollectionId) { (result) in
            XCTAssertEqual(result!.count, 10)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingMoviesByCollectionIdIsFailed() {
        mockMovieService.isMoviesByCollectionIdRequestFailed = true
        
        movieDetailsService.requestMovies(byCollectionId: fakeCollectionId) { (result) in
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnCastAndCrew() {
        movieDetailsService.requestPeople(by: fakeMovieId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnCastAndCrewWhenRequestingCharactersIsSlower() {
        mockPersonService.getCharactersDelayMilliseconds = 10
        mockPersonService.getCrewPeopleDelayMilliseconds = 5
        
        movieDetailsService.requestPeople(by: fakeMovieId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnCastAndCrewWhenRequestingCrewPeopleIsSlower() {
        mockPersonService.getCharactersDelayMilliseconds = 5
        mockPersonService.getCrewPeopleDelayMilliseconds = 10
        
        movieDetailsService.requestPeople(by: fakeMovieId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnCompactCrewPeopleWhenDuplicatedCrewPeople() {
        mockPersonService.isDuplicatedCrewPeople = true
        
        movieDetailsService.requestPeople(by: fakeMovieId) { (result) in
            XCTAssertEqual(result!.cast.count, 10)
            XCTAssertEqual(result!.crew.count, 10)
            
            for index in 0..<result!.crew.count {
                XCTAssertEqual(result!.crew[index].jobs, ["Job \(index)"])
            }
            
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingCharactersIsFailed() {
        mockPersonService.isCharactersRequestFailed = true
        
        movieDetailsService.requestPeople(by: fakeMovieId) { (result) in
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testShouldReturnNilWhenRequestingCrewPeopleIsFailed() {
        mockPersonService.isCrewPeopleRequestFailed = true
        
        movieDetailsService.requestPeople(by: fakeMovieId) { (result) in
            XCTAssertNil(result)
            self.expectationPromise.fulfill()
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

extension MovieDetailsServiceTests {
    
    private class MockPersonService: PersonService {
        
        public var getCharactersDelayMilliseconds: Int = 0
        
        public var getCrewPeopleDelayMilliseconds: Int = 0
        
        public var isCharactersRequestFailed = false
        
        public var isCrewPeopleRequestFailed = false
        
        public var isDuplicatedCrewPeople = false
        
        private let seeder = Seeder()
        
        override func getCharacters(by movieId: Int, onComplete callback: @escaping (_: AsyncResult<[Character]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(getCharactersDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                let characters = self.seeder.getCharacters(count: 10)
                
                let result = self.isCharactersRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(characters)
                
                callback(result)
            }
        }
        
        override func getCrewPeople(by movieId: Int, onComplete callback: @escaping (AsyncResult<[CrewPerson]>) -> Void) {
            let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(getCrewPeopleDelayMilliseconds)
            
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                var crewPeople = self.seeder.getCrewPeople(count: 10)
                
                if self.isDuplicatedCrewPeople {
                    crewPeople += self.seeder.getCrewPeople(count: 10)
                }
                
                let result = self.isCrewPeopleRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(crewPeople)
                
                callback(result)
            }
        }
        
    }
    
    private class MockMovieService: MovieService {
        
        public var isMovieDetailsRequestFaield = false
        
        public var isMoviesByCollectionIdRequestFailed = false
        
        private let seeder = Seeder()
        
        override func getMovieDetails(by movieId: Int, onComplete callback: @escaping (AsyncResult<MovieDetails>) -> Void) {
            DispatchQueue.main.async {
                let movieDetails = self.seeder.getMovieDetails()
                
                let result = self.isMovieDetailsRequestFaield
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movieDetails)
                
                callback(result)
            }
        }
        
        override func getMovies(byCollectionId collectionId: Int, onComplete callback: @escaping (_: AsyncResult<[Movie]>) -> Void) {
            DispatchQueue.main.async {
                let movies = self.seeder.getMovies(count: 10)
                
                let result = self.isMoviesByCollectionIdRequestFailed
                    ? AsyncResult.failure(ResponseError.dataIsNil)
                    : AsyncResult.success(movies)
                
                callback(result)
            }
        }
        
    }
    
}
