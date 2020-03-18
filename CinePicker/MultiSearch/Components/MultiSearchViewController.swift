import UIKit

class MultiSearchViewController: StateViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var entityTableView: UITableView!
    
    override var tableViewDefinition: UITableView! {
        return entityTableView
    }
    
    private var currentSearchQuery = ""
    
    private var requestedPage = 1
    
    private let searchDebounceDelayMilliseconds: Int = 500
    
    private var entities: [MultiSearchEntity] = []
    
    private var downloadedImages: [String: UIImage] = [:]
    
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
        super.viewWillAppear(animated)
        
        savedMovies = MovieRepository.shared.getAll()
        
        if currentSearchQuery.isEmpty {
            showSavedMovies()
            return
        }
        
        tableViewDefinition.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineDiscoverButton()
        defineMoreButton()
        defineSearchBar()
        defineTableView()
        
        setDefaultColors()
        
        if !UserDefaults.standard.bool(forKey: CinePickerSettingKeys.didAgreeToUseDataSource) {
            showDataSourceAgreementAlert()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        downloadedImages = [:]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            if !UserDefaults.standard.bool(forKey: CinePickerSettingKeys.didAgreeToUseDataSource) {
                return
            }
            
            UIViewUtils.closeAlert()
        }
    }
    
    override func onReloadData() {
        super.onReloadData()
        
        unsetAllStates()
        performRequest(shouldScrollToFirstRow: false)
    }
    
    override func updateTable<DataType>(providingData data: [DataType]) {
        super.updateTable(providingData: data)
        
        entities = data as! [MultiSearchEntity]
        entityTableView.reloadData()
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.back, style: .plain, target: nil, action: nil
        )
        navigationItem.leftBarButtonItems = []
        navigationItem.rightBarButtonItems = []
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func defineDiscoverButton() {
        let item = UIBarButtonItem(
            title: CinePickerCaptions.discover,
            style: .plain,
            target: self,
            action: #selector(MultiSearchViewController.onPressDiscoverButton)
        )
        
        navigationItem.leftBarButtonItems?.append(item)
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
    
    private func defineSearchBar() {
        searchBar.placeholder = CinePickerCaptions.typeMovieOrActor
        searchBar.setValue(CinePickerCaptions.cancel, forKey: "cancelButtonText")
        
        OperationQueue.main.addOperation {
            let isSavedMoviesEmpty = self.savedMovies.isEmpty
            let didAgreeToUseDataSource = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.didAgreeToUseDataSource)
            
            if isSavedMoviesEmpty && didAgreeToUseDataSource {
                self.searchBar.becomeFirstResponder()
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
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        
        navigationController?.navigationBar.barTintColor = CinePickerColors.getBackgroundColor()
        navigationController?.navigationBar.tintColor = CinePickerColors.getActionColor()
        
        searchBar.tintColor = CinePickerColors.getActionColor()
        
        entityTableView.backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    private func showSavedMovies() {
        let reversedSavedMovies = Array(savedMovies.reversed())
        let filteredSavedMovies = filter(savedMovies: reversedSavedMovies)
        
        updateTable(providingData: filteredSavedMovies)
    }
    
    private func removeSavedMovie(at indexPath: IndexPath) {
        let movie = entities[indexPath.row] as! SavedMovie
        MovieRepository.shared.remove(movie: movie)
        
        savedMovies = MovieRepository.shared.getAll()
        
        let reversedSavedMovies = Array(savedMovies.reversed())
        let filteredSavedMovies = filter(savedMovies: reversedSavedMovies)
        
        entities = filteredSavedMovies
        entityTableView.deleteRows(at: [indexPath], with: .automatic)
        
        if entities.isEmpty {
            resetViewController()
        }
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
                    return
                }
                
                if requestedSearchEntities.isEmpty {
                    self.setMessageState(withMessage: CinePickerCaptions.thereIsNoDataFound)
                    return
                }
                
                self.updateTable(providingData: requestedSearchEntities)
                
                if shouldScrollToFirstRow {
                    let firstIndexPath = IndexPath(row: 0, section: 0);
                    self.entityTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    @objc private func onPressDiscoverButton() {
        performSegue(withIdentifier: SegueIdentifiers.showDiscoverSettings, sender: nil)
    }
    
    @objc private func onPressActionsButton() {
        self.searchBarCancelButtonClicked(self.searchBar)
        
        UIViewUtils.showAlert(
            traitCollection: traitCollection,
            buttonActions: [
                (
                    title: CinePickerCaptions.selectLanguage,
                    action: onChangeLanguage
                ),
                (
                    title: CinePickerCaptions.eraseSavedMovies,
                    action: onEraseSavedMovies
                )
            ]
        )
    }
    
    private func onChangeLanguage() {
        UIViewUtils.showAlert(
            traitCollection: traitCollection,
            buttonActions: [
                (
                    title: CinePickerCaptions.english,
                    action: {
                        CinePickerConfig.setLanguage(language: .en)
                        self.resetViewController()
                }
                ),
                (
                    title: CinePickerCaptions.russian,
                    action: {
                        CinePickerConfig.setLanguage(language: .ru)
                        self.resetViewController()
                }
                )
            ],
            imageName: "lang_image",
            isAnimationRightToLeft: true
        )
    }
    
    private func onEraseSavedMovies() {
        MovieRepository.shared.removeAll()
        resetViewController()
    }
    
    private func showDataSourceAgreementAlert() {
        let action = {
            let willCheckItOut = Tag(name: SystemTagName.willCheckItOut.rawValue, russianName: "Буду смотреть")
            TagRepository.shared.save(tag: willCheckItOut)
            
            let iLikeIt = Tag(name: SystemTagName.iLikeIt.rawValue, russianName: "Нравится!")
            TagRepository.shared.save(tag: iLikeIt)
            
            UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.didAgreeToUseDataSource)
            
            UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.willCheckItOutFilter)
            UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.iLikeItFilter)
            
            self.onChangeLanguage()
        }
        
        UIViewUtils.showDatasourceAgreementAlert(
            traitCollection: traitCollection,
            buttonAction: action
        )
    }
    
    private func onTapWillCheckItOutFilter(cell: HeaderWithTagsUIView) {
        let isFilterSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.willCheckItOutFilter)
        UserDefaults.standard.set(!isFilterSelected, forKey: CinePickerSettingKeys.willCheckItOutFilter)
        
        showSavedMovies()
    }
    
    private func onTapILikeItFilter(cell: HeaderWithTagsUIView) {
        let isFilterSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.iLikeItFilter)
        UserDefaults.standard.set(!isFilterSelected, forKey: CinePickerSettingKeys.iLikeItFilter)
        
        showSavedMovies()
    }
    
    private func filter(savedMovies: [SavedMovie]) -> [SavedMovie] {
        let isWillCheckItOutFilterSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.willCheckItOutFilter)
        let isILikeItFilterSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.iLikeItFilter)
        
        let filteredSavedMovies = savedMovies.filter {
            if isWillCheckItOutFilterSelected && $0.containsTag(byName: .willCheckItOut) {
                return true
            }
            
            if isILikeItFilterSelected && $0.containsTag(byName: .iLikeIt){
                return true
            }
            
            return false
        }
        
        return filteredSavedMovies
    }
    
    private func resetViewController() {
        searchBarCancelButtonClicked(searchBar)
        
        viewWillAppear(false)
        viewDidLoad()
    }
    
}

extension MultiSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entities.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !currentSearchQuery.isEmpty {
            return 0
        }
        
        if savedMovies.isEmpty {
            return 0
        }
        
        return HeaderWithTagsUIView.standardHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentSearchQuery.isEmpty {
            let view = UIViewUtils.getHeaderWithTagsView(for: tableView)
            
            view.header = CinePickerCaptions.savedMovies
            
            view.isWillCheckItOutSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.willCheckItOutFilter)
            view.isILikeItSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.iLikeItFilter)
            
            view.onTapWillCheckItOut = onTapWillCheckItOutFilter
            view.onTapILikeIt = onTapILikeItFilter
            
            return view
        }
        
        return nil
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
        cell.selectedBackgroundView = UIViewUtils.getUITableViewCellSelectedBackgroundView()
        
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
        
        if downloadedImages[imagePath] != nil {
            return
        }
        
        var cell = cell as! ImageFromInternetViewCell
        cell.imagePath = imagePath
        let cellAdapter = ImageFromInternetViewCellAdapter(cell: cell)
        
        UIViewUtils.setImageFromInternet(at: cellAdapter, downloadedBy: imageService) { (image) in
            self.downloadedImages[imagePath] = image
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
        let cell = ImageFromInternetViewCellAdapter(cell: cell as! ImageFromInternetViewCell)
        
        if let imageUrl = cell.imageUrl {
            imageService.cancelDownloading(by: imageUrl)
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
        
        if let image = downloadedImages[movie.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = movie.imagePath
        }
        
        cell.onTapImageView = { (imagePath) in
            UIViewUtils.openImage(from: self, by: imagePath, using: self.imageService)
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
        
        if let image = downloadedImages[person.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = person.imagePath
        }
        
        cell.onTapImageView = { (imagePath) in
            UIViewUtils.openImage(from: self, by: imagePath, using: self.imageService)
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
        
        if segueIdentifier == SegueIdentifiers.showDiscoverSettings {
            return
        }
        
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

extension MultiSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchQuery = searchText
        downloadedImages = [:]
        
        if currentSearchQuery.isEmpty {
            unsetAllStates()
            showSavedMovies()
            
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        defer {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.endEditing(true)
        }
        
        guard let searchBarText = searchBar.text else {
            return
        }
        
        if searchBarText.isEmpty {
            return
        }
        
        searchBar.text = nil
        self.searchBar(searchBar, textDidChange: "")
    }
    
}
