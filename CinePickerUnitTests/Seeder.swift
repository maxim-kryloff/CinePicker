@testable import CinePicker

class Seeder {
    
    public func getMovieDetails() -> MovieDetails {
        let genres = [
            Genre(id: 0, name: "Genre 0"),
            Genre(id: 1, name: "Genre 1")
        ]
        
        let movieDetails = MovieDetails(
            id: 0,
            title: "Movie",
            originalTitle: "Movie",
            imagePath: "Image Path",
            rating: 0.0,
            voteCount: 0,
            releaseYear: "2000",
            overview: "Overview",
            popularity: 10,
            genres: genres,
            collectionId: 0
        )
        
        return movieDetails
    }
    
    public func getCharacters(count: Int) -> [Character] {
        var characters: [Character] = []
        
        for index in 0..<count {
            let character = Character(
                id: index,
                name: "Name \(index)",
                imagePath: "Image Path \(index)",
                characterName: "Character Name \(index)"
            )
            
            characters.append(character)
        }
        
        return characters
    }
    
    public func getCrewPeople(count: Int) -> [CrewPerson] {
        var crewPeople: [CrewPerson] = []
        
        for index in 0..<count {
            let crewPerson = CrewPerson(
                id: index,
                name: "Name \(index)",
                imagePath: "Image Path \(index)",
                job: "Job \(index)"
            )
            
            crewPeople.append(crewPerson)
        }
        
        return crewPeople
    }
    
    public func getMovies(count: Int) -> [Movie] {
        var movies: [Movie] = []
        
        for index in 0..<count {
            let movie = Movie(
                id: index,
                title: "Movie \(index)",
                originalTitle: "Movie \(index)",
                imagePath: "Image Path \(index)",
                rating: 0.0,
                voteCount: 0,
                releaseYear: "2000",
                overview: "Overview \(index)",
                popularity: 10
            )
            
            movies.append(movie)
        }
        
        return movies
    }
    
    public func getPopularPeople(count: Int) -> [PopularPerson] {
        var people: [PopularPerson] = []
        
        for index in 0..<count {
            let person = PopularPerson(
                id: index,
                name: "Name \(index)",
                imagePath: "Image Path \(index)",
                popularity: Double(index)
            )
            
            people.append(person)
        }
        
        return people
    }
    
}
