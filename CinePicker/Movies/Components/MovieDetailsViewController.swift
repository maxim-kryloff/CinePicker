import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
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
    
    private var movieCollectionIsGoingToBeRequested = false
    
    private var movieCollectionIsBeingRequested = false
    
    private var movieCollectionRequestIsFailed = false
    
    private var peopleAreGoingToBeRequested = false
    
    private var peopleAreBeingRequested = false
    
    private var peopleRequestIsFailed = false
    
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
    
    private var movieDetailsSectionUtilsFactory: SectionUtilsAbstractFactory!
    
    private var movieDetailsTagsSectionUtilsFactory: SectionUtilsAbstractFactory!
    
    private var movieDetailsOverviewSectionUtilsFactory: SectionUtilsAbstractFactory!
    
    private var movieDetailsMovieCollectionSectionUtilsFactory: SectionUtilsAbstractFactory!
    
    private var movieDetailsPeopleSectionUtilsFactory: SectionUtilsAbstractFactory!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedMovie = MovieRepository.shared.get(byId: self.movieId)
        movieDetailsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineTitle()
        defineNavigationController()
        defineMoreButton()
        defineLoadingView()
        defineFailedLoadingView()
        defineTableView()
        registerPersonTableViewCell()
        registerLoadingTableViewCell()
        registerFailedLoadingTableViewCell()
        registerHeaderTableViewCell()
        registerMovieCollectionTableViewCell()
        setDefaultColors()
        defineSectionUtilsFactories()
        performMovieDetailsRequest()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            UIViewUtilsFactory.shared.getAlertUtils().closeAlert()
        }
    }
    
    private func defineTitle() {
        navigationItem.title = movieTitle
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
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
    }
    
    private func registerPersonTableViewCell() {
        let personTableViewCellNib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        movieDetailsTableView.register(personTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.person)
    }
    
    private func registerLoadingTableViewCell() {
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        movieDetailsTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loading)
    }
    
    private func registerFailedLoadingTableViewCell() {
        let failedLoadingTableViewCellNib = UINib(nibName: "FailedLoadingTableViewCell", bundle: nil)
        movieDetailsTableView.register(failedLoadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.failedLoading)
    }
    
    private func registerHeaderTableViewCell() {
        let headerTableViewCellNib = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        movieDetailsTableView.register(headerTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.header)
    }
    
    private func registerMovieCollectionTableViewCell() {
        let movieCollectionTableViewCellNib = UINib(nibName: "MovieCollectionTableViewCell", bundle: nil)
        movieDetailsTableView.register(movieCollectionTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movieCollection)
    }
    
    private func defineLoadingView() {
        loadingView = UIViewUtilsFactory.shared.getViewUtils().getLoadingView(for: movieDetailsTableView)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewUtilsFactory.shared.getViewUtils().getFailedLoadingView(for: movieDetailsTableView, onTouchDown: onReloadGettingMovieDetails)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        movieDetailsTableView.backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    private func defineSectionUtilsFactories() {
        movieDetailsSectionUtilsFactory = MovieDetailsSectionUtilsFactory(movieDetailsViewController: self)
        movieDetailsTagsSectionUtilsFactory = MovieDetailsTagsSectionUtilsFactory(movieDetailsViewController: self)
        movieDetailsOverviewSectionUtilsFactory = MovieDetailsOverviewSectionUtilsFactory(movieDetailsViewController: self)
        movieDetailsMovieCollectionSectionUtilsFactory = MovieDetailsMovieCollectionSectionUtilsFactory(movieDetailsViewController: self)
        movieDetailsPeopleSectionUtilsFactory = MovieDetailsPeopleSectionUtilsFactory(movieDetailsViewController: self)
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
            cell.willCheckOutIsSelected = true
            return
        }
        if !savedMovie.containsTag(byName: .willCheckItOut) {
            updateSavedMovie(withTag: .willCheckItOut)
            cell.willCheckOutIsSelected = true
            return
        }
        cell.willCheckOutIsSelected = false
        if savedMovie.tags.count > 1 {
            updateSavedMovie(withoutTag: .willCheckItOut)
            return
        }
        removeSavedMovie()
    }
    
    private func onTapILikeItSystemTag(cell: MovieDetailsTagsTableViewCell) {
        guard let savedMovie = savedMovie else {
            saveMovie(withTag: .iLikeIt)
            cell.iLikeItIsSelected = true
            return
        }
        if !savedMovie.containsTag(byName: .iLikeIt) {
            updateSavedMovie(withTag: .iLikeIt)
            cell.iLikeItIsSelected = true
            return
        }
        cell.iLikeItIsSelected = false
        if savedMovie.tags.count > 1 {
            updateSavedMovie(withoutTag: .iLikeIt)
            return
        }
        removeSavedMovie()
    }
    
    private func performMovieDetailsRequest() {
        setLoadingState()
        movieDetailsService.requestMovieDetails(by: movieId) { (requestedMovieDetails) in
            OperationQueue.main.addOperation {
                guard let requestedMovieDetails = requestedMovieDetails else {
                    self.setFailedLoadingState()
                    self.movieCollectionIsGoingToBeRequested = false
                    self.peopleAreGoingToBeRequested = false
                    return
                }
                self.unsetAnyState()
                self.movieDetails = requestedMovieDetails
                self.actionsBarButtonItem.isEnabled = true
                self.movieCollectionIsGoingToBeRequested = true
                self.peopleAreGoingToBeRequested = true
                self.movieDetailsTableView.reloadData()
                if self.movieDetails.collectionId != nil {
                    self.performMovieCollectionRequest(fromReloading: false)
                }
                self.performPeopleRequest(fromReloading: false)
            }
        }
    }
    
    private func setLoadingState() {
        movieDetailsTableView.backgroundView = loadingView
    }
    
    private func setFailedLoadingState() {
        self.movieDetailsTableView.backgroundView = self.failedLoadingView
    }
    
    private func unsetAnyState() {
        self.movieDetailsTableView.backgroundView = nil
    }
    
    private func performMovieCollectionRequest(fromReloading: Bool) {
        guard let collectionId = movieDetails.collectionId else {
            fatalError("Collection ID must not be nil.")
        }
        movieCollectionIsGoingToBeRequested = false
        movieCollectionIsBeingRequested = true
        movieCollectionRequestIsFailed = false
        if fromReloading {
            let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsMovieCollectionSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
        }
        movieDetailsService.requestMovies(byCollectionId: collectionId) { (requestedMovies) in
            OperationQueue.main.addOperation {
                self.movieCollectionIsBeingRequested = false
                let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsMovieCollectionSectionNumber)
                guard let requestedMovies = requestedMovies else {
                    self.movieCollectionRequestIsFailed = true
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
        peopleAreGoingToBeRequested = false
        peopleAreBeingRequested = true
        peopleRequestIsFailed = false
        if fromReloading {
            let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsPeopleSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstIndexPath], with: .automatic)
        }
        movieDetailsService.requestPeople(by: movieDetails.id) { (requestedMoviePeople) in
            OperationQueue.main.addOperation {
                self.peopleAreBeingRequested = false
                let firstIndexPath = IndexPath(row: 0, section: self.movieDetailsPeopleSectionNumber)
                guard let requestedMoviePeople = requestedMoviePeople else {
                    self.peopleRequestIsFailed = true
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
        let savedMovie = SavedMovie(
            id: movieDetails.id,
            title: movieDetails.title,
            originalTitle: movieDetails.originalTitle,
            imagePath: movieDetails.imagePath,
            releaseYear: movieDetails.releaseYear,
            tags: [TagRepository.shared.getSystemTag(byName: tagName)]
        )
        MovieRepository.shared.save(movie: savedMovie)
        self.savedMovie = MovieRepository.shared.get(byId: movieId)
    }
    
    private func updateSavedMovie(withTag tagName: SystemTagName) {
        guard let savedMovie = savedMovie else {
            fatalError("Movie that's going to be updated doesn't exist.")
        }
        savedMovie.addTag(tag: TagRepository.shared.getSystemTag(byName: tagName))
        MovieRepository.shared.update(movie: savedMovie)
        self.savedMovie = MovieRepository.shared.get(byId: movieId)
    }
    
    private func updateSavedMovie(withoutTag tagName: SystemTagName) {
        guard let savedMovie = savedMovie else {
            fatalError("Movie that's going to be updated doesn't exist.")
        }
        savedMovie.removeTag(byName: tagName)
        MovieRepository.shared.update(movie: savedMovie)
        self.savedMovie = MovieRepository.shared.get(byId: movieId)
    }
    
    private func removeSavedMovie() {
        guard let savedMovie = savedMovie else {
            fatalError("Movie that's going to be removed doesn't exist.")
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
        return getSectionUtilsFactory(by: section).numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getSectionUtilsFactory(by: indexPath.section).getHeightForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
            case is MovieDetailsTableViewCell: prepare(movieDetailsTableViewCell: (cell as! MovieDetailsTableViewCell))
            case is PersonTableViewCell: prepare(personTableViewCell: (cell as! PersonTableViewCell), forRowAt: indexPath)
            default: break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getSectionUtilsFactory(by: indexPath.section).getTableViewCell(from: tableView, at: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == movieDetailsSectionNumber || indexPath.section == movieDetailsTagsSectionNumber {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if indexPath.section == movieDetailsMovieCollectionSectionNumber {
            if movieCollectionRequestIsFailed {
                onReloadGettingMovieCollection()
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if peopleRequestIsFailed {
            onReloadGettingPeople()
            return
        }
        let person = people[indexPath.row]
        if person is Character && indexPath.row == getGoToFullCastIndex() {
            performSegueForCharacterListTableViewCell(from: tableView, at: indexPath)
            return
        }
        if person is CrewPerson && indexPath.row == getGoToFullCrewIndex() {
            performSegueForCrewListTableViewCell(from: tableView, at: indexPath)
            return
        }
        performSegueForPersonTableViewCell(from: tableView, at: indexPath)
    }
    
    private func performSegueForCharacterListTableViewCell(from tableView: UITableView, at indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header)!
        let sender = GoToPersonListTableViewCellSender(cell: cell, indexPath: indexPath, personListType: .cast)
        movieDetailsTableView.reloadRows(at: [indexPath], with: .automatic)
        performSegue(withIdentifier: SegueIdentifiers.showPersonList, sender: sender)
    }
    
    private func performSegueForCrewListTableViewCell(from tableView: UITableView, at indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header)!
        let sender = GoToPersonListTableViewCellSender(cell: cell, indexPath: indexPath, personListType: .crew)
        movieDetailsTableView.reloadRows(at: [indexPath], with: .automatic)
        performSegue(withIdentifier: SegueIdentifiers.showPersonList, sender: sender)
    }
    
    private func performSegueForPersonTableViewCell(from tableView: UITableView, at indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person)!
        let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
        performSegue(withIdentifier: SegueIdentifiers.showPersonMovies, sender: sender)
    }
    
    private func prepare(movieDetailsTableViewCell cell: MovieDetailsTableViewCell) {
        cell.imagePath = movieDetails.imagePath
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
    }
    
    private func prepare(personTableViewCell cell: PersonTableViewCell, forRowAt indexPath: IndexPath) {
        cell.imagePath = people[indexPath.row].imagePath
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
    }
}

extension MovieDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let segueIdentifier = segue.identifier else {
            return
        }
        if segueIdentifier == SegueIdentifiers.showRequestedMovies {
            setRequestedMoviesViewControllerProperties(for: segue)
            return
        }
        if segueIdentifier == SegueIdentifiers.showPersonMovies {
            setMovieListViewControllerProperties(for: segue, sender: sender)
            return
        }
        if segueIdentifier == SegueIdentifiers.showPersonList {
            setPersonListViewControllerProperties(for: segue, sender: sender)
            return
        }
        fatalError("Unexpected segue identifier: \(segueIdentifier)")
    }
    
    private func setRequestedMoviesViewControllerProperties(for segue: UIStoryboardSegue) {
        let requestedMoviesController = segue.destination as! RequestedMoviesViewController
        requestedMoviesController.title = CinePickerCaptions.moviesSimilar(to: movieDetails.title)
        let similarMovieService = SimilarMovieService(movieService: MovieService())
        requestedMoviesController.requestMovies = { (requestedPage, callback) in
            let similarMovieRequest = SimilarMovieRequest(movieId: self.movieDetails.id, page: requestedPage)
            similarMovieService.requestMovies(request: similarMovieRequest) { (_, requestedMoviesResult) in
                callback(requestedMoviesResult)
            }
        }
    }
    
    private func setMovieListViewControllerProperties(for segue: UIStoryboardSegue, sender: Any?) {
        let movieListViewController = segue.destination as! MovieListViewController
        let sender = sender as! TableViewCellSender
        movieListViewController.person = people[sender.indexPath.row]
    }
    
    private func setPersonListViewControllerProperties(for segue: UIStoryboardSegue, sender: Any?) {
        let personListViewController = segue.destination as! PersonListViewController
        personListViewController.title = movieTitle
        let sender = sender as! GoToPersonListTableViewCellSender
        personListViewController.people = sender.personListType == PersonListType.cast ? characters : crewPeople
    }
}

extension MovieDetailsViewController {
    
    private func getSectionUtilsFactory(by sectionNumber: Int) -> SectionUtilsAbstractFactory {
        switch sectionNumber {
            case movieDetailsSectionNumber: return movieDetailsSectionUtilsFactory
            case movieDetailsTagsSectionNumber: return movieDetailsTagsSectionUtilsFactory
            case movieDetailsOverviewSectionNumber: return movieDetailsOverviewSectionUtilsFactory
            case movieDetailsMovieCollectionSectionNumber: return movieDetailsMovieCollectionSectionUtilsFactory
            case movieDetailsPeopleSectionNumber: return movieDetailsPeopleSectionUtilsFactory
            default: fatalError("Section number is out of range.")
        }
    }
    
    private class SectionUtilsAbstractFactory {
        
        public let movieDetailsViewController: MovieDetailsViewController
        
        init(movieDetailsViewController: MovieDetailsViewController) {
            self.movieDetailsViewController = movieDetailsViewController
        }
        
        public var numberOfRowsInSection: Int {
            fatalError("numberOfRowsInSection must be overridden.")
        }
        
        public func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
            fatalError("getHeightForRow(..) must be overridden.")
        }
        
        public func getTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            fatalError("getTableViewCell(..) must be overridden.")
        }
    }
    
    private class MovieDetailsSectionUtilsFactory: SectionUtilsAbstractFactory {
        
        override var numberOfRowsInSection: Int {
            return 1
        }
        
        override func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
            return MovieDetailsTableViewCell.standardHeight
        }
        
        override func getTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            return getMovieDetailsTableViewCell(from: tableView, at: indexPath)
        }
        
        private func getMovieDetailsTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetails, for: indexPath) as! MovieDetailsTableViewCell
            cell.movieDetails = movieDetailsViewController.movieDetails
            cell.originController = movieDetailsViewController
            return cell
        }
    }
    
    private class MovieDetailsTagsSectionUtilsFactory: SectionUtilsAbstractFactory {
        
        override var numberOfRowsInSection: Int {
            return 1
        }
        
        override func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
            return MovieDetailsTagsTableViewCell.standardHeight
        }
        
        override func getTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            return getMovieDetailsTagsTableViewCell(from: tableView, at: indexPath)
        }
        
        private func getMovieDetailsTagsTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsTags, for: indexPath) as! MovieDetailsTagsTableViewCell
            if let savedMovie = movieDetailsViewController.savedMovie {
                cell.willCheckOutIsSelected = savedMovie.containsTag(byName: .willCheckItOut)
                cell.iLikeItIsSelected = savedMovie.containsTag(byName: .iLikeIt)
            }
            cell.onTapWillCheckItOut = movieDetailsViewController.onTapWillCheckItOutSystemTag
            cell.onTapILikeIt = movieDetailsViewController.onTapILikeItSystemTag
            return cell
        }
    }
    
    private class MovieDetailsOverviewSectionUtilsFactory: SectionUtilsAbstractFactory {
        
        override var numberOfRowsInSection: Int {
            return 1
        }
        
        override func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
            return MovieDetailsOverviewTableViewCell.standardHeight
        }
        
        override func getTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            return getMovieDetailsOverviewTableViewCell(from: tableView, at: indexPath)
        }
        
        private func getMovieDetailsOverviewTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsOverview, for: indexPath) as! MovieDetailsOverviewTableViewCell
            cell.overview = movieDetailsViewController.movieDetails.overview
            return cell
        }
    }
    
    private class MovieDetailsMovieCollectionSectionUtilsFactory: SectionUtilsAbstractFactory {
        
        override var numberOfRowsInSection: Int {
            return getMovieCollectionSectionNumberOfRows()
        }
        
        private func getMovieCollectionSectionNumberOfRows() -> Int {
            if movieDetailsViewController.movieDetails.collectionId == nil {
                return 0
            }
            let movieCollectionIsInRequestState = movieDetailsViewController.movieCollectionIsGoingToBeRequested
                || movieDetailsViewController.movieCollectionIsBeingRequested
                || movieDetailsViewController.movieCollectionRequestIsFailed
            if movieCollectionIsInRequestState {
                return 1
            }
            if movieDetailsViewController.movieCollection.isEmpty {
                return 0
            }
            return 1
        }
        
        override func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
            return getMovieCollectionSectionRowHeight()
        }
        
        private func getMovieCollectionSectionRowHeight() -> CGFloat {
            if movieDetailsViewController.movieCollectionIsGoingToBeRequested || movieDetailsViewController.movieCollectionIsBeingRequested {
                return LoadingTableViewCell.standardHeight
            }
            if movieDetailsViewController.movieCollectionRequestIsFailed {
                return FailedLoadingTableViewCell.standardHeight
            }
            return MovieCollectionTableViewCell.standardHeight
        }
        
        override func getTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            return getMovieCollectionTableViewCell(from: tableView, at: indexPath)
        }
        
        private func getMovieCollectionTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            if movieDetailsViewController.movieCollectionIsGoingToBeRequested || movieDetailsViewController.movieCollectionIsBeingRequested {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
                return cell
            }
            if movieDetailsViewController.movieCollectionRequestIsFailed {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.failedLoading) as! FailedLoadingTableViewCell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieCollection, for: indexPath) as! MovieCollectionTableViewCell
            setMovieCollectionTableViewCellProperties(cell: cell)
            return cell
        }
        
        private func setMovieCollectionTableViewCellProperties(cell: MovieCollectionTableViewCell) {
            cell.header = CinePickerCaptions.alsoInSeries
            cell.movieCollection = self.movieDetailsViewController.movieCollection
            cell.onTouchDown = { (movie) in
                let storyboard = UIStoryboard(name: MainStoryboardIdentifiers.main, bundle: nil)
                let movieDetailsViewController = storyboard.instantiateViewController(withIdentifier: MainStoryboardIdentifiers.movieDetailsViewController) as! MovieDetailsViewController
                movieDetailsViewController.movieId = movie.id
                movieDetailsViewController.movieTitle = movie.title
                self.movieDetailsViewController.navigationController?.pushViewController(movieDetailsViewController, animated: true)
            }
        }
    }
    
    private class MovieDetailsPeopleSectionUtilsFactory: SectionUtilsAbstractFactory {
        
        override var numberOfRowsInSection: Int {
            return getMovieDetailsPeopleSectionNumberOfRows()
        }
        
        private func getMovieDetailsPeopleSectionNumberOfRows() -> Int {
            let peopleAreInRequestState = movieDetailsViewController.peopleAreGoingToBeRequested
                || movieDetailsViewController.peopleAreBeingRequested
                || movieDetailsViewController.peopleRequestIsFailed
            if peopleAreInRequestState {
                return 1
            }
            return movieDetailsViewController.people.count
        }
        
        override func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
            return getMovieDetailsPeopleSectionRowHeight(at: indexPath)
        }
        
        private func getMovieDetailsPeopleSectionRowHeight(at indexPath: IndexPath) -> CGFloat {
            if movieDetailsViewController.peopleAreGoingToBeRequested || movieDetailsViewController.peopleAreBeingRequested {
                return LoadingTableViewCell.standardHeight
            }
            if movieDetailsViewController.peopleRequestIsFailed {
                return FailedLoadingTableViewCell.standardHeight
            }
            let person = movieDetailsViewController.people[indexPath.row]
            if person is Character {
                return indexPath.row == movieDetailsViewController.getGoToFullCastIndex()
                    ? HeaderTableViewCell.standardHeight
                    : PersonTableViewCell.standardHeight
            }
            if person is CrewPerson {
                return indexPath.row == movieDetailsViewController.getGoToFullCrewIndex()
                    ? HeaderTableViewCell.standardHeight
                    : PersonTableViewCell.standardHeight
            }
            fatalError("Person has wrong type.")
        }
        
        override func getTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            return getPersonTableViewCell(from: tableView, at: indexPath)
        }
        
        private func getPersonTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            if movieDetailsViewController.peopleAreGoingToBeRequested || movieDetailsViewController.peopleAreBeingRequested {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
                return cell
            }
            if movieDetailsViewController.peopleRequestIsFailed {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.failedLoading) as! FailedLoadingTableViewCell
                return cell
            }
            let person = movieDetailsViewController.people[indexPath.row]
            if person is Character {
                return getCharacterTableViewCell(from: tableView, at: indexPath)
            }
            if person is CrewPerson {
                return getCrewPersonTableViewCell(from: tableView, at: indexPath)
            }
            fatalError("Person has wrong type.")
        }
        
        private func getCharacterTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            if indexPath.row == movieDetailsViewController.getGoToFullCastIndex() {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header, for: indexPath) as! HeaderTableViewCell
                cell.header = CinePickerCaptions.goToFullCast
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
            cell.originController = movieDetailsViewController
            let character = movieDetailsViewController.people[indexPath.row] as! Character
            cell.personName = character.name
            cell.personPosition = character.characterName
            cell.personPositionIsValid = !character.isUncredited
            return cell
        }
        
        private func getCrewPersonTableViewCell(from tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            if indexPath.row == movieDetailsViewController.getGoToFullCrewIndex() {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.header, for: indexPath) as! HeaderTableViewCell
                cell.header = CinePickerCaptions.goToFullCrew
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
            cell.originController = movieDetailsViewController
            let crewPerson = movieDetailsViewController.people[indexPath.row] as! CrewPerson
            cell.personName = crewPerson.name
            cell.personPosition = crewPerson.jobs.joined(separator: ", ")
            cell.personPositionIsValid = true
            return cell
        }
    }
}
