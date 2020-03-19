import UIKit

// TODO: Try to inherit StateViewController or remove this TODO
class MovieDetailsViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var movieDetailsTableView: UITableView!
    
    public var movieId: Int!
    
    public var movieTitle: String?
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var movieDetails: MovieDetails!
    
    private var loadingView: LoadingUIView!
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private let numberOfSections: Int = 5
    
    private let movieDetailsSectionNumber: Int = 0
    
    private let movieDetailsTagsSectionNumber: Int = 1
    
    private let movieDetailsOverviewSectionNumber: Int = 2
    
    private let movieDetailsMovieCollectionSectionNumber: Int = 3
    
    private let movieDetailsPeopleSectionNumber: Int = 4
    
    private var isMovieCollectionGoingToBeRequested = false
    
    private var isMovieCollectionBeingRequested = false
    
    private var isMovieCollectionRequestFailed = false
    
    private var isPeopleGoingToBeRequested = false
    
    private var isPeopleBeingRequested = false
    
    private var isPeopleRequestFailed = false
    
    private var savedMovie: SavedMovie?
    
    private var movieCollection: [Movie] = []
    
    private var people: [Person] = []
    
    private var characters: [Character] = []
    
    private var limitedCharacters: [Character] = []
    
    private var crewPeople: [CrewPerson] = []
    
    private var limitedCrewPeople: [CrewPerson] = []
    
    private var charactersLimit: Int = 6
    
    private var crewPeopleLimit: Int = 4
    
    private var movieDetailsService = MovieDetailsService(movieService: MovieService(), personService: PersonService())
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        savedMovie = MovieRepository.shared.get(byId: self.movieId)
        movieDetailsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movieTitle
        
        defineNavigationController()
        defineMoreButton()
        defineLoadingView()
        defineFailedLoadingView()
        defineTableView()
        
        setDefaultColors()
        
        performMovieDetailsRequest()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            UIViewUtilsFactory.shared.getAlertUtils().closeAlert()
        }
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.back, style: .plain, target: nil, action: nil
        )
    }
    
    private func defineMoreButton() {
        actionsBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.more,
            style: .plain,
            target: self,
            action: #selector(MovieDetailsViewController.onPressActionsButton)
        )
        
        actionsBarButtonItem.isEnabled = false
        
        navigationItem.rightBarButtonItem = actionsBarButtonItem
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
        
        let movieCollectionTableViewCellNib = UINib(nibName: "MovieCollectionTableViewCell", bundle: nil)
        movieDetailsTableView.register(movieCollectionTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movieCollection)
    }
    
    private func defineLoadingView() {
        loadingView = UIViewUtils.getLoadingView(for: movieDetailsTableView)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewUtils.getFailedLoadingView(for: movieDetailsTableView, onTouchDown: onReloadGettingMovieDetails)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        topBarView.backgroundColor = CinePickerColors.getTopBarColor()
        movieDetailsTableView.backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    private func onReloadGettingMovieDetails() {
        performMovieDetailsRequest()
    }
    
    private func onReloadGettingMovieCollection() {
        performMovieCollectionRequest(fromReloading: true)
    }
    
    private func onReloadGettingPeople() {
        performPeopleRequest(fromReloading: true)
    }
    
    @objc private func onPressActionsButton() {
        let goToRequestedMoviesAction = {
            self.performSegue(withIdentifier: SegueIdentifiers.showRequestedMovies, sender: nil)
        }
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        UIViewUtilsFactory.shared.getAlertUtils().showAlert(
            traitCollection: traitCollection,
            buttonActions: [
                (title: CinePickerCaptions.goToSimilarMovies, action: goToRequestedMoviesAction),
                (title: CinePickerCaptions.backToSearch, action: backToSearchAction)
            ]
        )
    }
    
    private func onTapWillCheckItOutSystemTag(cell: MovieDetailsTagsTableViewCell) {
        guard let savedMovie = savedMovie else {
            saveMovie(withTag: .willCheckItOut)
            cell.isWillCheckItOutSelected = true
            
            return
        }
        
        if !savedMovie.containsTag(byName: .willCheckItOut) {
            updateSavedMovie(withTag: .willCheckItOut)
            cell.isWillCheckItOutSelected = true
            
            return
        }
        
        cell.isWillCheckItOutSelected = false
        
        if savedMovie.tags.count > 1 {
            updateSavedMovie(withoutTag: .willCheckItOut)
            return
        }
        
        removeSavedMovie()
    }
    
    private func onTapILikeItSystemTag(cell: MovieDetailsTagsTableViewCell) {
        guard let savedMovie = savedMovie else {
            saveMovie(withTag: .iLikeIt)
            cell.isILikeItSelected = true
            
            return
        }
        
        if !savedMovie.containsTag(byName: .iLikeIt) {
            updateSavedMovie(withTag: .iLikeIt)
            cell.isILikeItSelected = true
            
            return
        }
        
        cell.isILikeItSelected = false
        
        if savedMovie.tags.count > 1 {
            updateSavedMovie(withoutTag: .iLikeIt)
            return
        }
        
        removeSavedMovie()
    }
    
    private func performMovieDetailsRequest() {
        movieDetailsTableView.backgroundView = loadingView
        
        movieDetailsService.requestMovieDetails(by: movieId) { (requestedMovieDetails) in
            OperationQueue.main.addOperation {
                guard let requestedMovieDetails = requestedMovieDetails else {
                    self.movieDetailsTableView.backgroundView = self.failedLoadingView
                    self.isMovieCollectionGoingToBeRequested = false
                    self.isPeopleGoingToBeRequested = false
                    
                    return
                }
                
                self.movieDetailsTableView.backgroundView = nil
                
                self.movieDetails = requestedMovieDetails
                
                self.actionsBarButtonItem.isEnabled = true
                
                self.isMovieCollectionGoingToBeRequested = true
                self.isPeopleGoingToBeRequested = true
                self.movieDetailsTableView.reloadData()
                
                if self.movieDetails.collectionId != nil {
                    self.performMovieCollectionRequest(fromReloading: false)
                }
                
                self.performPeopleRequest(fromReloading: false)
            }
        }
    }
    
    private func performMovieCollectionRequest(fromReloading: Bool) {
        guard let collectionId = movieDetails.collectionId else {
            fatalError("Collection ID must not be nil...")
        }
        
        isMovieCollectionGoingToBeRequested = false
        isMovieCollectionBeingRequested = true
        isMovieCollectionRequestFailed = false
        
        if fromReloading {
            let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsMovieCollectionSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
        }
        
        movieDetailsService.requestMovies(byCollectionId: collectionId) { (requestedMovies) in
            OperationQueue.main.addOperation {
                self.isMovieCollectionBeingRequested = false
                
                let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsMovieCollectionSectionNumber)
                
                guard let requestedMovies = requestedMovies else {
                    self.isMovieCollectionRequestFailed = true
                    self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
                    
                    return
                }
                
                if requestedMovies.isEmpty {
                    self.movieDetailsTableView.deleteRows(at: [firstIndexPath], with: .automatic)
                    return
                }
                
                self.movieCollection = requestedMovies
                    .filter { $0.id != self.movieId }
                
                if self.movieCollection.isEmpty {
                    self.movieDetailsTableView.deleteRows(at: [firstIndexPath], with: .automatic)
                    return
                }
                
                self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
            }
        }
    }
    
    private func performPeopleRequest(fromReloading: Bool) {
        isPeopleGoingToBeRequested = false
        isPeopleBeingRequested = true
        isPeopleRequestFailed = false
        
        if fromReloading {
            let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsPeopleSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
        }
        
        movieDetailsService.requestPeople(by: movieDetails.id) { (requestedMoviePeople) in
            OperationQueue.main.addOperation {
                self.isPeopleBeingRequested = false
                
                let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsPeopleSectionNumber)
                
                guard let requestedMoviePeople = requestedMoviePeople else {
                    self.isPeopleRequestFailed = true
                    self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
                    
                    return
                }
                
                self.movieDetailsTableView.deleteRows(at: [firstIndexPath], with: .automatic)
                
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
    
    private func saveMovie(withTag tagName: SystemTagName) {
        let tag = TagRepository.shared.getSystemTag(byName: tagName)
        
        let savedMovie = SavedMovie(
            id: movieDetails.id,
            title: movieDetails.title,
            originalTitle: movieDetails.originalTitle,
            imagePath: movieDetails.imagePath,
            releaseYear: movieDetails.releaseYear,
            tags: [tag]
        )
        
        MovieRepository.shared.save(movie: savedMovie)
        self.savedMovie = MovieRepository.shared.get(byId: movieId)
    }
    
    private func updateSavedMovie(withTag tagName: SystemTagName) {
        guard let savedMovie = savedMovie else {
            fatalError("Movie that's going to be updated doesn't exist...")
        }
        
        let tag = TagRepository.shared.getSystemTag(byName: tagName)
        savedMovie.addTag(tag: tag)
        
        MovieRepository.shared.update(movie: savedMovie)
        self.savedMovie = MovieRepository.shared.get(byId: movieId)
    }
    
    private func updateSavedMovie(withoutTag tagName: SystemTagName) {
        guard let savedMovie = savedMovie else {
            fatalError("Movie that's going to be updated doesn't exist...")
        }
        
        savedMovie.removeTag(byName: tagName)
        
        MovieRepository.shared.update(movie: savedMovie)
        self.savedMovie = MovieRepository.shared.get(byId: movieId)
    }
    
    private func removeSavedMovie() {
        guard let savedMovie = savedMovie else {
            fatalError("Movie that's going to be removed doesn't exist...")
        }
        
        MovieRepository.shared.remove(movie: savedMovie)
        self.savedMovie = nil
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
            case movieDetailsTagsSectionNumber: return 1
            case movieDetailsOverviewSectionNumber: return 1
            case movieDetailsMovieCollectionSectionNumber: return getMovieCollectionSectionNumberOfRows()
            case movieDetailsPeopleSectionNumber: return getMovieDetailsPeopleSectionNumberOfRows()
            default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
            case (movieDetailsSectionNumber, _): return MovieDetailsTableViewCell.standardHeight
            case (movieDetailsTagsSectionNumber, _): return MovieDetailsTagsTableViewCell.standardHeight
            case (movieDetailsOverviewSectionNumber, _): return MovieDetailsOverviewTableViewCell.standardHeight
            case (movieDetailsMovieCollectionSectionNumber, _): return getMovieCollectionSectionRowHeight()
            case (movieDetailsPeopleSectionNumber, _): return getMovieDetailsPeopleSectionRowHeight(at: indexPath)
            default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIViewUtils.getUITableViewCellSelectedBackgroundView()
        
        switch cell {
            case is MovieDetailsTableViewCell: prepare(movieDetailsTableViewCell: (cell as! MovieDetailsTableViewCell))
            case is PersonTableViewCell: prepare(personTableViewCell: (cell as! PersonTableViewCell), forRowAt: indexPath)
            default: break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
            case (movieDetailsSectionNumber, _): return getMovieDetailsTableViewCell(tableView, cellForRowAt: indexPath)
            case (movieDetailsTagsSectionNumber, _): return getMovieDetailsTagsTableViewCell(tableView, cellForRowAt: indexPath)
            case (movieDetailsOverviewSectionNumber, _): return getMovieDetailsOverviewTableViewCell(tableView, cellForRowAt: indexPath)
            case (movieDetailsMovieCollectionSectionNumber, _): return getMovieCollectionTableViewCell(tableView, cellForRowAt: indexPath)
            case (movieDetailsPeopleSectionNumber, _): return getPersonTableViewCell(tableView, cellForRowAt: indexPath)
            default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == movieDetailsSectionNumber || indexPath.section == movieDetailsTagsSectionNumber {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if indexPath.section == movieDetailsMovieCollectionSectionNumber {
            if isMovieCollectionRequestFailed {
                onReloadGettingMovieCollection()
                return
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if isPeopleRequestFailed {
            onReloadGettingPeople()
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
        
        cell.onTapImageView = { (imagePath) in
            UIViewUtilsFactory.shared.getImageUtils().openImage(from: self, by: imagePath)
        }
        
        cell.title = movieDetails.title
        cell.originalTitle = movieDetails.originalTitle
        cell.genres = movieDetails.genres
        cell.releaseYear = movieDetails.releaseYear
        
        if movieDetails.runtime != 0 {
            cell.runtime = movieDetails.runtime
        }
        
        cell.voteCount = movieDetails.voteCount
        cell.rating = movieDetails.rating
        
        return cell
    }
    
    private func getMovieDetailsTagsTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsTags, for: indexPath) as! MovieDetailsTagsTableViewCell
        
        if let savedMovie = savedMovie {
            cell.isWillCheckItOutSelected = savedMovie.containsTag(byName: .willCheckItOut)
            cell.isILikeItSelected = savedMovie.containsTag(byName: .iLikeIt)
        }
        
        cell.onTapWillCheckItOut = onTapWillCheckItOutSystemTag
        cell.onTapILikeIt = onTapILikeItSystemTag
        
        return cell
    }
    
    private func getMovieDetailsOverviewTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsOverview, for: indexPath) as! MovieDetailsOverviewTableViewCell
        
        cell.overview = movieDetails.overview
        
        return cell
    }
    
    private func getMovieCollectionTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isMovieCollectionGoingToBeRequested || isMovieCollectionBeingRequested {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
            return cell
        }
        
        if isMovieCollectionRequestFailed {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.failedLoading) as! FailedLoadingTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieCollection, for: indexPath) as! MovieCollectionTableViewCell
        
        cell.header = CinePickerCaptions.alsoInSeries
        cell.movieCollection = movieCollection
        
        cell.onTouchDown = { (movie) in
            let storyboard = UIStoryboard(name: MainStoryboardIdentifiers.main, bundle: nil)
            let movieDetailsViewController = storyboard.instantiateViewController(withIdentifier: MainStoryboardIdentifiers.movieDetailsViewController) as! MovieDetailsViewController
            
            movieDetailsViewController.movieId = movie.id
            movieDetailsViewController.movieTitle = movie.title
            
            self.navigationController?.pushViewController(movieDetailsViewController, animated: true)
        }
        
        return cell
    }
    
    private func getPersonTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPeopleGoingToBeRequested || isPeopleBeingRequested {
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
                cell.header = CinePickerCaptions.goToFullCast
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
            
            cell.onTapImageView = { (imagePath) in
                UIViewUtilsFactory.shared.getImageUtils().openImage(from: self, by: imagePath)
            }
            
            cell.personName = character.name
            cell.personPosition = character.characterName
            cell.isPersonPositionValid = !character.isUncredited
            
            return cell
        }
        
        if let crewPerson = person as? CrewPerson {
            if indexPath.row == getGoToFullCrewIndex() {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header, for: indexPath) as! HeaderTableViewCell
                cell.header = CinePickerCaptions.goToFullCrew
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell

            cell.onTapImageView = { (imagePath) in
                UIViewUtilsFactory.shared.getImageUtils().openImage(from: self, by: imagePath)
            }
            
            cell.personName = crewPerson.name
            cell.personPosition = crewPerson.jobs.joined(separator: ", ")
            cell.isPersonPositionValid = true
            
            return cell
        }
        
        fatalError("Person has wrong type...")
    }
    
    private func prepare(movieDetailsTableViewCell cell: MovieDetailsTableViewCell) {
        cell.imagePath = movieDetails.imagePath
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
    }
    
    private func prepare(personTableViewCell cell: PersonTableViewCell, forRowAt indexPath: IndexPath) {
        cell.imagePath = people[indexPath.row].imagePath
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
    }
    
    private func getMovieCollectionSectionNumberOfRows() -> Int {
        if movieDetails.collectionId == nil {
            return 0
        }
        
        if isMovieCollectionGoingToBeRequested || isMovieCollectionBeingRequested || isMovieCollectionRequestFailed {
            return 1
        }
        
        if movieCollection.isEmpty {
            return 0
        }
        
        return 1
    }
    
    private func getMovieDetailsPeopleSectionNumberOfRows() -> Int {
        if isPeopleGoingToBeRequested || isPeopleBeingRequested || isPeopleRequestFailed {
            return 1
        }
        
        return people.count
    }
    
    private func getMovieCollectionSectionRowHeight() -> CGFloat {
        if isMovieCollectionGoingToBeRequested || isMovieCollectionBeingRequested {
            return LoadingTableViewCell.standardHeight
        }
        
        if isMovieCollectionRequestFailed {
            return FailedLoadingTableViewCell.standardHeight
        }
        
        return MovieCollectionTableViewCell.standardHeight
    }
    
    private func getMovieDetailsPeopleSectionRowHeight(at indexPath: IndexPath) -> CGFloat {
        if isPeopleGoingToBeRequested || isPeopleBeingRequested {
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
        
        if segueIdentifier == SegueIdentifiers.showRequestedMovies {
            let requestedMoviesController = segue.destination as! RequestedMoviesViewController
            
            requestedMoviesController.title = CinePickerCaptions.moviesSimilar(to: movieDetails.title)
            
            let similarMovieService = SimilarMovieService(movieService: MovieService())
            
            requestedMoviesController.requestMovies = { (requestedPage, callback) in
                let similarMovieRequest = SimilarMovieRequest(movieId: self.movieDetails.id, page: requestedPage)
                
                similarMovieService.requestMovies(request: similarMovieRequest) { (_, requestedMoviesResult) in
                    callback(requestedMoviesResult)
                }
            }
            
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
            
            personListViewController.title = movieTitle
            personListViewController.people = sender.personListType == PersonListType.cast ? characters : crewPeople
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
