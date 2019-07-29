import UIKit

class MultiSearchViewController: StatesViewController {
    
    @IBOutlet weak var entityTableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var tableViewDefinition: UITableView! {
        return entityTableView
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentSearchQuery = ""
    
    private var requestedPage = 1
    
    private let searchDebounceDelayMilliseconds: Int = 500
    
    private let savedMovieHeight: CGFloat = 40
    
    private var entities: [Popularity] = []
    
    private var loadedImages: [String: UIImage] = [:]
    
    private var savedMovies: [SavedMovie] = [] {
        didSet {
            savedMovieMap = [:]
            
            for movie in savedMovies {
                savedMovieMap[movie.id] = movie
            }
        }
    }
    
    private var savedMovieMap: [Int: SavedMovie] = [:]
    
    private let multiSearchService = MultiSearchService(movieService: MovieService(), personService: PersonService())
    
    private let imageService = ImageService()
    
    private let debounceActionService = DebounceActionService()
    
    override func viewWillAppear(_ animated: Bool) {
        savedMovies = MovieRepository.shared.getAll()
        
        if currentSearchQuery.isEmpty {
            setSavedMovieState()
            return
        }
        
        tableViewDefinition.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad()
    }
    
    override func onReloadData() {
        super.onReloadData()
        
        unsetAllStates()
        performRequest(shouldScrollToFirstRow: false)
    }
    
    override func updateTable<DataType>(withData data: [DataType]) {
        super.updateTable(withData: data)
        
        entities = data as! [Popularity]
        entityTableView.reloadData()
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.back, style: .plain, target: nil, action: nil
        )
        navigationItem.rightBarButtonItems = []
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func defineMoreButton() {
        let item = UIBarButtonItem(
            title: CinePickerCaptions.more,
            style: .plain,
            target: self,
            action: #selector(MultiSearchViewController.onPressActionsButton)
        )
        
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    private func defineLangButton() {
        let item = UIBarButtonItem(
            title: CinePickerCaptions.lang,
            style: .plain,
            target: self,
            action: #selector(MultiSearchViewController.onChangeLanguage)
        )
        
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    private func defineSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = CinePickerCaptions.typeMovieOrActor
        searchController.searchBar.setValue(CinePickerCaptions.cancel, forKey: "cancelButtonText")
        searchController.searchBar.keyboardAppearance = .dark
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        OperationQueue.main.addOperation {
            let isSavedMoviesEmpty = self.savedMovies.isEmpty
            let didAgreeToUseSource = UserDefaults.standard.bool(forKey: "didAgreeToUseDataSource")
            
            if isSavedMoviesEmpty && didAgreeToUseSource {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    private func defineTableView() {
        entityTableView.rowHeight = PersonTableViewCell.standardHeight
        entityTableView.tableFooterView = UIView(frame: .zero)

        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        entityTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
        
        let personTableViewCellNib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        entityTableView.register(personTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.person)
    }
    
    private func setSavedMovieState() {
        let reversedSavedMovies = Array(savedMovies.reversed())
        updateTable(withData: reversedSavedMovies)
    }
    
    private func removeSavedMovie(at indexPath: IndexPath) {
        let movie = entities[indexPath.row] as! SavedMovie
        
        MovieRepository.shared.remove(movie: movie)
        
        savedMovies = MovieRepository.shared.getAll()
        let reversedSavedMovies = Array(savedMovies.reversed())
        
        entities = reversedSavedMovies
        entityTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func performRequest(shouldScrollToFirstRow: Bool) {
        setLoadingState()
        
        let multiSearchRequest = MultiSearchRequest(searchQuery: currentSearchQuery, page: requestedPage)
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, requestedSearchEntities) in
            OperationQueue.main.addOperation {
                if self.currentSearchQuery != request.searchQuery {
                    return
                }
                
                self.unsetLoadingState()
                
                guard let requestedSearchEntities = requestedSearchEntities else {
                    self.setFailedLoadingState()
                    self.updateTable(withData: [])
                    
                    return
                }
                
                self.updateTable(withData: requestedSearchEntities)
                
                if self.entities.isEmpty {
                    self.setMessageState(withMessage: CinePickerCaptions.thereIsNoDataFound)
                    return
                }
                
                if shouldScrollToFirstRow {
                    let firstIndexPath = IndexPath(row: 0, section: 0);
                    self.entityTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    private func onViewDidLoad() {
        defineNavigationController()
        defineMoreButton()
        defineLangButton()
        defineSearchController()
        defineTableView()
        
        if !UserDefaults.standard.bool(forKey: "didAgreeToUseDataSource") {
            showDataSourceAgreementAlert()
            
            let willCheckItOut = Tag(name: SystemTagName.willCheckItOut.rawValue, russianName: "Буду смотреть")
            TagRepository.shared.save(tag: willCheckItOut)
            
            let iLikeIt = Tag(name: SystemTagName.iLikeIt.rawValue, russianName: "Нравится!")
            TagRepository.shared.save(tag: iLikeIt)
        }
        
        definesPresentationContext = true
    }
    
    @objc private func onPressActionsButton() {
        let eraseSavedMovies = {
            MovieRepository.shared.removeAll()
            
            self.savedMovies = MovieRepository.shared.getAll()
            self.setSavedMovieState()
        }
        
        UIViewHelper.showAlert(
            [
                (title: CinePickerCaptions.eraseSavedMovies, action: eraseSavedMovies)
            ]
        )
    }
    
    @objc private func onChangeLanguage() {
        UIViewHelper.showAlert(
            [
                (
                    title: CinePickerCaptions.english,
                    action: {
                        CinePickerConfig.setLanguage(language: .en)
                        self.onViewDidLoad()
                    }
                ),
                (
                    title: CinePickerCaptions.russian,
                    action: {
                        CinePickerConfig.setLanguage(language: .ru)
                        self.onViewDidLoad()
                    }
                )
            ],
            "lang_image"
        )
    }
    
    private func showDataSourceAgreementAlert() {
        let action = {
            UserDefaults.standard.set(true, forKey: "didAgreeToUseDataSource")
            self.onChangeLanguage()
        }
        
        UIViewHelper.showAlert(
            [
                (title: "OK", action: action)
            ],
            "data_source_logo",
            "Data Source",
            "This product uses the TMDb API but is not endorsed or certified by TMDb.",
            false
        )
    }

}

extension MultiSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entities.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentSearchQuery.isEmpty {
            return UIViewHelper.getHeaderView(for: entityTableView, withText: CinePickerCaptions.savedMovies)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !currentSearchQuery.isEmpty {
            return 0
        }
        
        if savedMovies.isEmpty {
            return 0
        }
        
        return savedMovieHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return currentSearchQuery.isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeSavedMovie(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView()
        
        var imagePath: String
        
        switch cell {
        case is MovieTableViewCell:
            let movie = entities[indexPath.row] as! Movie
            imagePath = movie.imagePath
        case is PersonTableViewCell:
            let popularPerson = entities[indexPath.row] as! PopularPerson
            imagePath = popularPerson.imagePath
        default:
            fatalError("Unexpected type of table view cell...")
        }
        
        if imagePath.isEmpty {
            return
        }
        
        if loadedImages[imagePath] != nil {
            return
        }
        
        var cell = cell as! ImageFromInternet
        
        UIViewHelper.setImageFromInternet(by: imagePath, at: &cell, using: imageService) { (image) in
            self.loadedImages[imagePath] = image
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = entities[indexPath.row]
        
        switch (entity) {
        case is Movie: return getMovieTableViewCell(tableView, cellForRowAt: indexPath, movie: entity as! Movie)
        case is PopularPerson: return getPersonTableViewCell(tableView, cellForRowAt: indexPath, person: entity as! PopularPerson)
        default: fatalError("Entity has unexpeted type...")
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! ImageFromInternet
        
        if let imageUrl = cell.imageUrl {
            imageService.cancelDownloading(for: imageUrl)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = entities[indexPath.row]
        
        if entity is Movie {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath)
            let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
            
            performSegue(withIdentifier: SegueIdentifiers.showMovieDetails, sender: sender)
            
            return
        }
        
        if entity is PopularPerson {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath)
            let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
            
            performSegue(withIdentifier: SegueIdentifiers.showPersonMovies, sender: sender)
            
            return
        }
        
        fatalError("Unexpeted type of selected entity...")
    }

    private func getMovieTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, movie: Movie) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        
        if let image = loadedImages[movie.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = movie.imagePath
        }
        
        cell.onTapImageViewHandler = { (imagePath) in
            UIViewHelper.openImage(from: self, by: imagePath, using: self.imageService)
        }
        
        cell.title = movie.title
        cell.originalTitle = movie.originalTitle
        cell.releaseYear = movie.releaseYear
        
        if let savedMovie = movie as? SavedMovie {
            cell.isWillCheckItOutHidden = !savedMovie.containsTag(byName: .willCheckItOut)
            cell.isILikeItHidden = !savedMovie.containsTag(byName: .iLikeIt)
            
            cell.isVoteResultsHidden = true
            
            return cell
        }
        
        if let savedMovie = savedMovieMap[movie.id] {
            cell.isWillCheckItOutHidden = !savedMovie.containsTag(byName: .willCheckItOut)
            cell.isILikeItHidden = !savedMovie.containsTag(byName: .iLikeIt)
        }
        
        cell.voteCount = movie.voteCount
        cell.rating = movie.rating
        
        return cell
    }
    
    private func getPersonTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, person: PopularPerson) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
        if let image = loadedImages[person.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = person.imagePath
        }
        
        cell.onTapImageViewHandler = { (imagePath) in
            UIViewHelper.openImage(from: self, by: imagePath, using: self.imageService)
        }
        
        cell.personName = person.name
        
        return cell
    }
    
}

extension MultiSearchViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        loadedImages = [:]
        
        let sender = sender as! TableViewCellSender
        let indexPath = sender.indexPath
        
        let entity = entities[indexPath.row]
        
        if segueIdentifier == SegueIdentifiers.showMovieDetails {
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            let movie = entity as! Movie
            
            movieDetailsViewController.movieId = movie.id
            movieDetailsViewController.movieTitle = movie.title
            
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showPersonMovies {
            let movieListViewController = segue.destination as! MovieListViewController
            let popularPerson = entity as! PopularPerson
            
            movieListViewController.person = popularPerson
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}

extension MultiSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        if currentSearchQuery == text {
            return
        }
        
        currentSearchQuery = text
        loadedImages = [:]

        if currentSearchQuery.isEmpty {
            unsetAllStates()
            setSavedMovieState()
            
            return
        }
        
        debounceActionService.async(delay: DispatchTimeInterval.milliseconds(searchDebounceDelayMilliseconds)) {
            if self.currentSearchQuery.isEmpty {
                return
            }
            
            OperationQueue.main.addOperation {
                self.unsetAllStates()
                self.performRequest(shouldScrollToFirstRow: true)
            }
        }
    }
    
}
