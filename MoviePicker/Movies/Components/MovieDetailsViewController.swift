import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var movieDetailsTableView: UITableView!
    
    public var movieId: Int!
    
    public var movieOriginalTitle: String?
    
    private var movieDetails: MovieDetails!
    
    private var loadingView: UIView!
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private let numberOfSections: Int = 4
    
    private let movieDetailsSectionNumber: Int = 0
    
    private let movieDetailsBookmarkActionSectionNumber: Int = 1
    
    private let movieDetailsOverviewSectionNumber: Int = 2
    
    private let movieDetailsPeopleSectionNumber: Int = 3
    
    private var isPeopleGoingToBeRequested = false
    
    private var isPeopleBeingRequested = false
    
    private var isPeopleRequestFailed = false
    
    private var people: [Person] = []
    
    private var characters: [Character] = []
    
    private var limitedCharacters: [Character] = []
    
    private var crewPeople: [CrewPerson] = []
    
    private var limitedCrewPeople: [CrewPerson] = []
    
    private var charactersLimit: Int = 6
    
    private var crewPeopleLimit: Int = 4
    
    private let imageService = ImageService()
    
    private var movieDetailsService: MovieDetailsService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movieOriginalTitle
        
        movieDetailsService = MovieDetailsService(movieService: MovieService(), personService: PersonService())
        
        defineLoadingView()
        defineFailedLoadingView()
        defineTableView()
        
        performMovieDetailsRequest()
    }
    
    private func defineTableView() {
        movieDetailsTableView.rowHeight = UITableView.automaticDimension
        movieDetailsTableView.estimatedRowHeight = 80
        movieDetailsTableView.tableFooterView = UIView(frame: .zero)
        
        let personTableViewCellNib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        movieDetailsTableView.register(personTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.person)
        
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        movieDetailsTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loading)
        
        let failedLoadingTableViewCellNib = UINib(nibName: "FailedLoadingTableViewCell", bundle: nil)
        movieDetailsTableView.register(failedLoadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.failedLoading)
        
        let headerTableViewCellNib = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        movieDetailsTableView.register(headerTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.header)
    }
    
    private func defineLoadingView() {
        loadingView = UIViewHelper.getLoadingView(for: movieDetailsTableView)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewHelper.getFailedLoadingView(for: movieDetailsTableView, onTouchDownHandler: onReloadGettingMovieDetails)
    }
    
    private func onReloadGettingMovieDetails() {
        performMovieDetailsRequest()
    }
    
    private func onSelectFailedLoadingCell() {
        performPeopleRequest(fromReloading: true)
    }
    
    private func onSelectBookmarkActionCell() {
        defer {
            let bookmarkActionIndexPath = IndexPath(row: 0, section: movieDetailsBookmarkActionSectionNumber)
            movieDetailsTableView.reloadRows(at: [bookmarkActionIndexPath], with: .automatic)
        }
        
        let isSavedInBookmarks = checkIfSavedInBookmarks()
        
        if isSavedInBookmarks {
            _ = BookmarkRepository.shared.removeBookmark(movie: movieDetails)
        } else {
            _ = BookmarkRepository.shared.saveBookmark(movie: movieDetails)
        }
    }
    
    private func performMovieDetailsRequest() {
        movieDetailsTableView.backgroundView = loadingView
        
        movieDetailsService.requestMovieDetails(by: movieId) { (requestedMovieDetails) in
            OperationQueue.main.addOperation {
                guard let requestedMovieDetails = requestedMovieDetails else {
                    self.movieDetailsTableView.backgroundView = self.failedLoadingView
                    self.isPeopleGoingToBeRequested = false
                    
                    return
                }
                
                self.movieDetailsTableView.backgroundView = nil
                
                self.movieDetails = requestedMovieDetails
                
                self.isPeopleGoingToBeRequested = true
                self.movieDetailsTableView.reloadData()
                
                self.performPeopleRequest(fromReloading: false)
            }
        }
    }
    
    private func performPeopleRequest(fromReloading: Bool) {
        isPeopleGoingToBeRequested = false
        isPeopleBeingRequested = true
        isPeopleRequestFailed = false
        
        if fromReloading {
            let firstPeopleIndexPath = IndexPath(row: 0, section: self.movieDetailsPeopleSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstPeopleIndexPath], with: .automatic)
        }
        
        movieDetailsService.requestPeople(by: movieDetails.id) { (requestedMoviePeople, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                self.isPeopleBeingRequested = false
                self.isPeopleRequestFailed = isLoadingDataFailed
                
                let firstPeopleIndexPath = IndexPath(row: 0, section: self.movieDetailsPeopleSectionNumber)
                
                if self.isPeopleRequestFailed {
                    self.movieDetailsTableView.reloadRows(at: [firstPeopleIndexPath], with: .automatic)
                    return
                }
                
                self.movieDetailsTableView.deleteRows(at: [firstPeopleIndexPath], with: .automatic)
                
                self.characters = requestedMoviePeople.cast
                self.crewPeople = requestedMoviePeople.crew
                
                self.limitedCharacters = self.getLimitedPeople(from: self.characters, limit: self.charactersLimit)
                self.limitedCrewPeople = self.getLimitedPeople(from: self.crewPeople, limit: self.crewPeopleLimit)
                
                self.people = self.limitedCharacters + self.limitedCrewPeople
                
                var indexPaths: [IndexPath] = []
                
                for index in 0..<self.people.count {
                    let indexPath = IndexPath(row: index, section: self.movieDetailsPeopleSectionNumber)
                    indexPaths.append(indexPath)
                }
                
                self.movieDetailsTableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func checkIfSavedInBookmarks() -> Bool {
        let bookmarks = BookmarkRepository.shared.getBookmarks()
        return bookmarks.contains { $0.id == movieDetails.id }
    }
    
    private func getGoToFullCastIndex() -> Int {
        return charactersLimit - 1
    }
    
    private func getGoToFullCrewIndex() -> Int {
        return limitedCharacters.count + crewPeopleLimit - 1
    }
    
    private func getLimitedPeople<PersonType>(from people: [PersonType], limit: Int) -> [PersonType] {
        if people.count <= limit {
            return people
        }
        
        return Array(people[0..<limit])
    }
    
}

extension MovieDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if movieDetails == nil {
            return 0
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movieDetails == nil {
            return 0
        }
        
        switch section {
        case movieDetailsSectionNumber: return 1
        case movieDetailsBookmarkActionSectionNumber: return 1
        case movieDetailsOverviewSectionNumber: return 1
        case movieDetailsPeopleSectionNumber: return getMovieDetailsPeopleSectionNumberOfRows()
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (movieDetailsSectionNumber, _): return MovieDetailsTableViewCell.standardHeight
        case (movieDetailsBookmarkActionSectionNumber, _): return MovieDetailsBookmarkActionTableViewCell.standardHeight
        case (movieDetailsOverviewSectionNumber, _): return MovieDetailsOverviewTableViewCell.standardHeight
        case (movieDetailsPeopleSectionNumber, _): return getMovieDetailsPeopleSectionRowHeight(at: indexPath)
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case is MovieDetailsTableViewCell: prepare(movieDetailsTableViewCell: (cell as! MovieDetailsTableViewCell))
        case is PersonTableViewCell: prepare(personTableViewCell: (cell as! PersonTableViewCell), forRowAt: indexPath)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (movieDetailsSectionNumber, _): return getMovieDetailsTableViewCell(tableView, cellForRowAt: indexPath)
        case (movieDetailsBookmarkActionSectionNumber, _): return getMovieDetailsBookmarkActionTableViewCell(tableView, cellForRowAt: indexPath)
        case (movieDetailsOverviewSectionNumber, _): return getMovieDetailsOverviewTableViewCell(tableView, cellForRowAt: indexPath)
        case (movieDetailsPeopleSectionNumber, _): return getPersonTableViewCell(tableView, cellForRowAt: indexPath)
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var imageUrl: URL? = nil
        
        switch cell {
        case is MovieDetailsTableViewCell: imageUrl = (cell as! MovieDetailsTableViewCell).imageUrl
        case is PersonTableViewCell: imageUrl = (cell as! PersonTableViewCell).imageUrl
        default: return
        }
        
        if imageUrl == nil {
            return
        }
        
        imageService.cancelDownloading(for: imageUrl!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == movieDetailsBookmarkActionSectionNumber {
            onSelectBookmarkActionCell()
            return
        }
        
        if isPeopleRequestFailed {
            onSelectFailedLoadingCell()
            return
        }
        
        let person = people[indexPath.row]
        
        if person is Character && indexPath.row == getGoToFullCastIndex() {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header)!
            let sender = GoToPersonListTableViewCellSender(cell: cell, indexPath: indexPath, personListType: .cast)
            
            movieDetailsTableView.reloadRows(at: [indexPath], with: .automatic)
            performSegue(withIdentifier: SegueIdentifiers.showPersonList, sender: sender)
            
            return
        }
        
        if person is CrewPerson && indexPath.row == getGoToFullCrewIndex() {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header)!
            let sender = GoToPersonListTableViewCellSender(cell: cell, indexPath: indexPath, personListType: .crew)
            
            movieDetailsTableView.reloadRows(at: [indexPath], with: .automatic)
            performSegue(withIdentifier: SegueIdentifiers.showPersonList, sender: sender)
            
            return
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person)!
        
        let sender = TableViewCellSender(cell: cell, indexPath: indexPath)

        performSegue(withIdentifier: SegueIdentifiers.showPersonMovies, sender: sender)
    }
    
    private func getMovieDetailsTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetails, for: indexPath) as! MovieDetailsTableViewCell

        cell.title = movieDetails.title
        cell.originalTitle = movieDetails.originalTitle
        cell.genres = movieDetails.genres
        cell.releaseYear = movieDetails.releaseYear
        cell.voteCount = movieDetails.voteCount
        cell.rating = movieDetails.rating
        
        return cell
    }
    
    private func getMovieDetailsBookmarkActionTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsBookmarkAction, for: indexPath) as! MovieDetailsBookmarkActionTableViewCell

        cell.isRemoveAction = checkIfSavedInBookmarks()
        
        return cell
    }
    
    private func getMovieDetailsOverviewTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsOverview, for: indexPath) as! MovieDetailsOverviewTableViewCell

        cell.overview = movieDetails.overview
        
        return cell
    }
    
    private func getPersonTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPeopleBeingRequested {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
            return cell
        }
        
        if isPeopleRequestFailed {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.failedLoading) as! FailedLoadingTableViewCell
            return cell
        }
        
        let person = people[indexPath.row]
        
        if let character = person as? Character {
            if indexPath.row == getGoToFullCastIndex() {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header, for: indexPath) as! HeaderTableViewCell
                cell.header = "Go to Full Cast"
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
            
            cell.personName = character.name
            cell.personPosition = character.characterName
            cell.isPersonPositionValid = !character.isUncredited
            
            return cell
        }
        
        if let crewPerson = person as? CrewPerson {
            if indexPath.row == getGoToFullCrewIndex() {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header, for: indexPath) as! HeaderTableViewCell
                cell.header = "Go to Full Crew"
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
            
            cell.personName = crewPerson.name
            cell.personPosition = crewPerson.jobs.joined(separator: ", ")
            cell.isPersonPositionValid = true
            
            return cell
        }
        
        fatalError("Person has wrong type...")
    }
    
    private func prepare(movieDetailsTableViewCell cell: MovieDetailsTableViewCell) {
        if !movieDetails.imagePath.isEmpty {
            var cell = cell as ImageFromInternet
            UIViewHelper.setImageFromInternet(by: movieDetails.imagePath, at: &cell, using: imageService)
        }
    }
    
    private func prepare(personTableViewCell cell: PersonTableViewCell, forRowAt indexPath: IndexPath) {
        let person = people[indexPath.row]

        if !person.imagePath.isEmpty {
            var cell = cell as ImageFromInternet
            UIViewHelper.setImageFromInternet(by: person.imagePath, at: &cell, using: imageService)
        }
    }
    
    private func getMovieDetailsPeopleSectionNumberOfRows() -> Int {
        if isPeopleGoingToBeRequested || isPeopleBeingRequested || isPeopleRequestFailed {
            return 1
        }
        
        return people.count
    }
    
    private func getMovieDetailsPeopleSectionRowHeight(at indexPath: IndexPath) -> CGFloat {
        if isPeopleBeingRequested {
            return LoadingTableViewCell.standardHeight
        }
        
        if isPeopleRequestFailed {
            return FailedLoadingTableViewCell.standardHeight
        }
        
        let person = people[indexPath.row]
        
        if person is Character {
            return indexPath.row == getGoToFullCastIndex()
                ? HeaderTableViewCell.standardHeight
                : PersonTableViewCell.standardHeight
        }
        
        if person is CrewPerson {
            return indexPath.row == getGoToFullCrewIndex()
                ? HeaderTableViewCell.standardHeight
                : PersonTableViewCell.standardHeight
        }
        
        fatalError("Person has wrong type...")
    }
    
}

extension MovieDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showPersonMovies {
            let movieListViewController = segue.destination as! MovieListViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            let person = people[indexPath.row]
            
            movieListViewController.person = person
            
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showPersonList {
            let personListViewController = segue.destination as! PersonListViewController
            let sender = sender as! GoToPersonListTableViewCellSender

            personListViewController.title = movieOriginalTitle
            personListViewController.people = sender.personListType == PersonListType.cast ? characters : crewPeople
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
