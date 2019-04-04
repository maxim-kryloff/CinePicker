import UIKit

class MultiSearchViewController: StatesViewController {
    
    @IBOutlet weak var entityTableView: UITableView!
    
    @IBOutlet weak var topBarView: UIView!
    
    override var tableViewDefinition: UITableView! {
        return entityTableView
    }
    
    private var languageBarButtonItem: UIBarButtonItem!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentSearchQuery = ""
    
    private var requestedPage = 1
    
    private let searchDebounceDelayMilliseconds: Int = 500
    
    private let bookmarkHeaderHeight: CGFloat = 40
    
    private var entities: [Popularity] = []
    
    private let multiSearchService = MultiSearchService(movieService: MovieService(), personService: PersonService())
    
    private let imageService = ImageService()
    
    private let debounceActionService = DebounceActionService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineLanguageButton()
        defineSearchController()
        defineTableView()
        
        setBookmarks()
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentSearchQuery.isEmpty {
            setBookmarks()
            
            if entities.isEmpty {
                showTopBarView()
            }
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
        navigationController?.navigationBar.shadowImage = UIImage()
        showTopBarView()
    }
    
    private func defineLanguageButton() {
        languageBarButtonItem = UIBarButtonItem(
            title: MoviePickerConfig.getLanguageShortcut(),
            style: .plain,
            target: self,
            action: #selector(MultiSearchViewController.onChangeLanguage)
        )
        
        self.navigationItem.leftBarButtonItem = languageBarButtonItem
    }
    
    private func defineSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search..."
        
        let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchField?.backgroundColor = MoviePickerColors.lightGray
        
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false

        OperationQueue.main.addOperation {
            let isBookmarksEmpty = self.checkIfBookmarksEmpty()
            
            if isBookmarksEmpty {
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
    
    private func showTopBarView() {
        topBarView.isHidden = false
    }
    
    private func hideTopBarView() {
        topBarView.isHidden = true
    }
    
    private func setBookmarks() {
        let bookmarks = BookmarkRepository.shared.getBookmarks()
        let reversedBookmarks = Array(bookmarks.reversed())
        
        if !bookmarks.isEmpty {
            hideTopBarView()
        }
        
        updateTable(withData: reversedBookmarks)
    }
    
    private func removeBookmark(at indexPath: IndexPath) {
        let movie = entities[indexPath.row] as! Movie
        
        let bookmarks = BookmarkRepository.shared.removeBookmark(movie: movie)
        let reversedBookmarks = Array(bookmarks.reversed())
        
        if bookmarks.isEmpty {
            showTopBarView()
        }
        
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
        
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, requestedSearchEntities, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                if self.currentSearchQuery != request.searchQuery {
                    return
                }
                
                self.unsetLoadingState()
                
                if isLoadingDataFailed {
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
    
    @objc private func onChangeLanguage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let setEnglish = UIAlertAction(title: "English", style: .default) { (action) in
            UserDefaults.standard.set("en-US", forKey: "Language")
            self.languageBarButtonItem.title = MoviePickerConfig.getLanguageShortcut()
        }
        
        let setRussian = UIAlertAction(title: "Russian", style: .default) { (action) in
            UserDefaults.standard.set("ru-RU", forKey: "Language")
            self.languageBarButtonItem.title = MoviePickerConfig.getLanguageShortcut()
        }
        
        let setFrench = UIAlertAction(title: "French", style: .default) { (action) in
            UserDefaults.standard.set("fr-FR", forKey: "Language")
            self.languageBarButtonItem.title = MoviePickerConfig.getLanguageShortcut()
        }
        
        let setGerman = UIAlertAction(title: "German", style: .default) { (action) in
            UserDefaults.standard.set("de-DE", forKey: "Language")
            self.languageBarButtonItem.title = MoviePickerConfig.getLanguageShortcut()
        }
        
        let setItalian = UIAlertAction(title: "Italian", style: .default) { (action) in
            UserDefaults.standard.set("it-IT", forKey: "Language")
            self.languageBarButtonItem.title = MoviePickerConfig.getLanguageShortcut()
        }

        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(setEnglish)
        alert.addAction(setRussian)
        alert.addAction(setFrench)
        alert.addAction(setGerman)
        alert.addAction(setItalian)
        
        alert.addAction(cancel)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
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
        var imagePath: String? = nil
        
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
        
        if imagePath != nil {
            var cell = cell as! ImageFromInternet
            UIViewHelper.setImageFromInternet(by: imagePath!, at: &cell, using: imageService)
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
        
        guard let imageUrl = cell.imageUrl else {
            return
        }
        
        imageService.cancelDownloading(for: imageUrl)
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
        
        cell.title = movie.title
        cell.originalTitle = movie.originalTitle
        cell.releaseYear = movie.releaseYear
        cell.voteCount = movie.voteCount
        cell.rating = movie.rating
        
        return cell
    }
    
    private func getPersonTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, person: PopularPerson) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
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
                self.showTopBarView()
                self.unsetAllStates()
                
                self.performRequest(shouldScrollToFirstRow: true)
            }
        }
    }
    
}
