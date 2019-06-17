import UIKit

class MultiSearchViewController: StatesViewController {
    
    @IBOutlet weak var entityTableView: UITableView!
    
    override var tableViewDefinition: UITableView! {
        return entityTableView
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentSearchQuery = ""
    
    private var requestedPage = 1
    
    private let searchDebounceDelayMilliseconds: Int = 500
    
    private let bookmarkHeaderHeight: CGFloat = 40
    
    private var entities: [Popularity] = []
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let multiSearchService = MultiSearchService(movieService: MovieService(), personService: PersonService())
    
    private let imageService = ImageService()
    
    private let debounceActionService = DebounceActionService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineMoreButton()
        defineLangButton()
        defineSearchController()
        defineTableView()
        
        setBookmarks()
        
        if !UserDefaults.standard.bool(forKey: "didAgreeToUseDataSource") {
            showDataSourceAgreementAlert()
        }
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentSearchQuery.isEmpty {
            setBookmarks()
        }
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
        navigationItem.rightBarButtonItems = []
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func defineMoreButton() {
        let item = UIBarButtonItem(
            title: "More",
            style: .plain,
            target: self,
            action: #selector(MultiSearchViewController.onPressActionsButton)
        )
        
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    private func defineLangButton() {
        let item = UIBarButtonItem(
            title: "Lang",
            style: .plain,
            target: self,
            action: #selector(MultiSearchViewController.onChangeLanguage)
        )
        
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    private func defineSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type movie or actor..."
        searchController.searchBar.keyboardAppearance = .dark
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        OperationQueue.main.addOperation {
            let isBookmarksEmpty = self.checkIfBookmarksEmpty()
            let didAgreeToUseSource = UserDefaults.standard.bool(forKey: "didAgreeToUseDataSource")
            
            if isBookmarksEmpty && didAgreeToUseSource {
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
    
    private func setBookmarks() {
        let bookmarks = BookmarkRepository.shared.getBookmarks()
        let reversedBookmarks = Array(bookmarks.reversed())
        
        updateTable(withData: reversedBookmarks)
    }
    
    private func removeBookmark(at indexPath: IndexPath) {
        let movie = entities[indexPath.row] as! Movie
        
        let bookmarks = BookmarkRepository.shared.removeBookmark(movie: movie)
        let reversedBookmarks = Array(bookmarks.reversed())
        
        entities = reversedBookmarks
        entityTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func checkIfBookmarksEmpty() -> Bool {
        let bookmarks = BookmarkRepository.shared.getBookmarks()
        return bookmarks.isEmpty
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
                    self.setMessageState(withMessage: "There is no data found...")
                    return
                }
                
                if shouldScrollToFirstRow {
                    let firstIndexPath = IndexPath(row: 0, section: 0);
                    self.entityTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    @objc private func onPressActionsButton() {
        let eraseBookmarks = {
            self.entities = BookmarkRepository.shared.eraseBookmarks()
            self.entityTableView.reloadData()
        }
        
        UIViewHelper.showAlert(
            [
                (title: "Erase Bookmarks", action: eraseBookmarks)
            ]
        )
    }
    
    @objc private func onChangeLanguage() {
        UIViewHelper.showAlert(
            [
                (title: "English", action: { UserDefaults.standard.set("en-US", forKey: "Language") }),
                (title: "Russian", action: { UserDefaults.standard.set("ru-RU", forKey: "Language") })
            ],
            "lang_image"
        )
    }
    
    private func showDataSourceAgreementAlert() {
        let action = {
            UserDefaults.standard.set(true, forKey: "didAgreeToUseDataSource")
            self.searchController.searchBar.becomeFirstResponder()
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
            return UIViewHelper.getHeaderView(for: entityTableView, withText: "Bookmarks")
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentSearchQuery.isEmpty {
            let isBookmarksEmpty = checkIfBookmarksEmpty()
            return !isBookmarksEmpty ? bookmarkHeaderHeight : 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return currentSearchQuery.isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeBookmark(at: indexPath)
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
            movieDetailsViewController.movieOriginalTitle = movie.originalTitle
            
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
            setBookmarks()
            
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
