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
    
    private var savedMovies: [SavedMovie] = [] {
        didSet {
            savedMovieDictionary = [:]
            for movie in savedMovies {
                savedMovieDictionary[movie.id] = movie
            }
        }
    }
    
    private var savedMovieDictionary: [Int: SavedMovie] = [:]
    
    private let multiSearchService = MultiSearchService(movieService: MovieService(), personService: PersonService())
    
    private let movieDetailsService = MovieDetailsService(movieService: MovieService(), personService: PersonService())
    
    private let debounceActionService = DebounceActionService()
    
    private var movieUtilsFactory: EntityUtilsAbstractFactory!
    
    private var personUtilsFactory: EntityUtilsAbstractFactory!
    
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
        registerMovieTableViewCell()
        registerPersonTableViewCell()
        setDefaultColors()
        defineEntityUtilsFactories()
        if !UserDefaults.standard.bool(forKey: CinePickerSettingKeys.didAgreeToUseDataSource) {
            createAndSaveTags()
            showDataSourceAgreementAlert()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            if !UserDefaults.standard.bool(forKey: CinePickerSettingKeys.didAgreeToUseDataSource) {
                return
            }
            UIViewUtilsFactory.shared.getAlertUtils().closeAlert()
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
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
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
        DispatchQueue.main.async {
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
    }
    
    private func registerMovieTableViewCell() {
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        entityTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }
    
    private func registerPersonTableViewCell() {
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
    
    private func defineEntityUtilsFactories() {
        movieUtilsFactory = MovieUtilsFactory(multiSearchViewController: self)
        personUtilsFactory = PersonUtilsFactory(multiSearchViewController: self)
    }
    
    private func showSavedMovies() {
        let reversedSavedMovies = Array(savedMovies.reversed())
        let filteredSavedMovies = filter(savedMovies: reversedSavedMovies)
        updateTable(providingData: filteredSavedMovies)
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
    
    private func deleteSavedMovie(at indexPath: IndexPath) {
        let movie = entities[indexPath.row] as! SavedMovie
        MovieRepository.shared.delete(movie: movie)
        savedMovies = MovieRepository.shared.getAll()
        entities = getEntities(from: savedMovies)
        entityTableView.deleteRows(at: [indexPath], with: .automatic)
        if entities.isEmpty {
            resetViewController()
        }
    }
    
    private func getEntities(from savedMovies: [SavedMovie]) -> [MultiSearchEntity] {
        let reversedSavedMovies = Array(savedMovies.reversed())
        let filteredSavedMovies = filter(savedMovies: reversedSavedMovies)
        return filteredSavedMovies
    }
    
    private func performRequest(shouldScrollToFirstRow: Bool) {
        setLoadingState()
        let multiSearchRequest = MultiSearchRequest(searchQuery: currentSearchQuery, page: requestedPage)
        multiSearchService.requestEntities(request: multiSearchRequest) { (request, requestedSearchEntities) in
            DispatchQueue.main.async {
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
        UIViewUtilsFactory.shared.getAlertUtils().showAlert(
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
        UIViewUtilsFactory.shared.getAlertUtils().showAlert(
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
            animationIsRightToLeft: true
        )
    }
    
    private func onEraseSavedMovies() {
        MovieRepository.shared.deleteAll()
        resetViewController()
    }
    
    private func createAndSaveTags() {
        let willCheckItOut = Tag(name: SystemTagName.willCheckItOut.rawValue, russianName: "Буду смотреть")
        TagRepository.shared.save(tag: willCheckItOut)
        let iLikeIt = Tag(name: SystemTagName.iLikeIt.rawValue, russianName: "Нравится!")
        TagRepository.shared.save(tag: iLikeIt)
    }
    
    private func showDataSourceAgreementAlert() {
        let action = {
            UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.didAgreeToUseDataSource)
            UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.willCheckItOutFilter)
            UserDefaults.standard.set(false, forKey: CinePickerSettingKeys.iLikeItFilter)
            self.onChangeLanguage()
        }
        UIViewUtilsFactory.shared.getAlertUtils().showDatasourceAgreementAlert(
            traitCollection: traitCollection,
            buttonAction: action
        )
    }
    
    private func onTapWillCheckItOutFilter(cell: HeaderWithTagsUIView) {
        UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.willCheckItOutFilter)
        UserDefaults.standard.set(false, forKey: CinePickerSettingKeys.iLikeItFilter)
        showSavedMovies()
    }
    
    private func onTapILikeItFilter(cell: HeaderWithTagsUIView) {
        UserDefaults.standard.set(false, forKey: CinePickerSettingKeys.willCheckItOutFilter)
        UserDefaults.standard.set(true, forKey: CinePickerSettingKeys.iLikeItFilter)
        showSavedMovies()
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
            let view = UIViewUtilsFactory.shared.getViewUtils().getHeaderWithTagsView(for: tableView)
            setHeaderViewProperties(view: view)
            return view
        }
        return nil
    }
    
    func setHeaderViewProperties(view: HeaderWithTagsUIView) {
        view.header = CinePickerCaptions.savedMovies
        view.willCheckItOutIsSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.willCheckItOutFilter)
        view.iLikeItIsSelected = UserDefaults.standard.bool(forKey: CinePickerSettingKeys.iLikeItFilter)
        view.onTapWillCheckItOut = onTapWillCheckItOutFilter
        view.onTapILikeIt = onTapILikeItFilter
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return currentSearchQuery.isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteSavedMovie(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let entity = entities[indexPath.row]
        getEntityUtilsFactory(by: entity).setMultiSearchTableViewCellImageProperties(cell: cell, by: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = entities[indexPath.row]
        return getEntityUtilsFactory(by: entity).getMultiSearchTableViewCell(from: tableView, by: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ImageFromInternetViewCell {
            UIViewUtilsFactory.shared.getImageUtils().cancelSettingImageFromInternet(at: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = entities[indexPath.row]
        getEntityUtilsFactory(by: entity).performSegueForMultiSearchTableViewCell(from: tableView, at: indexPath)
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
        let entity = entities[sender.indexPath.row]
        if segueIdentifier == SegueIdentifiers.showMovieDetails {
            setMovieDetailsViewControllerProperties(for: segue, entity: entity)
            return
        }
        if segueIdentifier == SegueIdentifiers.showPersonMovies {
            setMovieListViewControllerProperties(for: segue, entity: entity)
            return
        }
        fatalError("Unexpected segue identifier: \(segueIdentifier).")
    }
    
    private func setMovieDetailsViewControllerProperties(for segue: UIStoryboardSegue, entity: MultiSearchEntity) {
        MovieTableViewCell.setMovieDetailsViewControllerProperties(for: segue, movie: entity as! Movie)
    }
    
    private func setMovieListViewControllerProperties(for segue: UIStoryboardSegue, entity: MultiSearchEntity) {
        let movieListViewController = segue.destination as! MovieListViewController
        movieListViewController.person = entity as! PopularPerson
    }
}

extension MultiSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchQuery = searchText
        if currentSearchQuery.isEmpty {
            unsetAllStates()
            showSavedMovies()
            return
        }
        debounceActionService.asyncAfter(delay: DispatchTimeInterval.milliseconds(searchDebounceDelayMilliseconds)) {
            if self.currentSearchQuery.isEmpty {
                return
            }
            DispatchQueue.main.async {
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

extension MultiSearchViewController {
    
    private func getEntityUtilsFactory(by entity: MultiSearchEntity) -> EntityUtilsAbstractFactory {
        switch entity {
            case is Movie: return movieUtilsFactory
            case is PopularPerson: return personUtilsFactory
            default: fatalError("Entity type is unexpected.")
        }
    }
    
    private class EntityUtilsAbstractFactory {
        
        public let multiSearchViewController: MultiSearchViewController
        
        init(multiSearchViewController: MultiSearchViewController) {
            self.multiSearchViewController = multiSearchViewController
        }
        
        public func setMultiSearchTableViewCellImageProperties(cell: UITableViewCell, by indexPath: IndexPath) { }
        
        public func getMultiSearchTableViewCell(from tableView: UITableView, by indexPath: IndexPath) -> UITableViewCell {
            fatalError("getTableViewCell(..) must be overridden.")
        }
        
        public func performSegueForMultiSearchTableViewCell(from tableView: UITableView, at indexPath: IndexPath) { }
    }
    
    private class MovieUtilsFactory: EntityUtilsAbstractFactory {
        
        override func setMultiSearchTableViewCellImageProperties(cell: UITableViewCell, by indexPath: IndexPath) {
            let movie = multiSearchViewController.entities[indexPath.row] as! Movie
            (cell as! MovieTableViewCell).imagePath = movie.imagePath
            UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell as! ImageFromInternetViewCell) { (image, _) in
                if image != nil {
                    return
                }
                if let savedMovie = movie as? SavedMovie {
                    self.refreshImagePath(of: savedMovie)
                }
            }
        }
        
        private func refreshImagePath(of savedMovie: SavedMovie) {
            multiSearchViewController.movieDetailsService.requestMovieDetails(by: savedMovie.id) { (movieDetails) in
                DispatchQueue.main.async {
                    if let movieDetails = movieDetails {
                        savedMovie.update(imagePath: movieDetails.imagePath)
                        MovieRepository.shared.update(movie: savedMovie)
                    }
                }
            }
        }
        
        override func getMultiSearchTableViewCell(from tableView: UITableView, by indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
            let movie = multiSearchViewController.entities[indexPath.row] as! Movie
            cell.movie = movie
            cell.originController = multiSearchViewController
            if let savedMovie = movie as? SavedMovie {
                cell.savedMovie = savedMovie
                cell.voteResultsAreHidden = true
                return cell
            }
            if let savedMovie = multiSearchViewController.savedMovieDictionary[movie.id] {
                cell.savedMovie = savedMovie
            }
            return cell
        }
        
        override func performSegueForMultiSearchTableViewCell(from tableView: UITableView, at indexPath: IndexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath)
            let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
            multiSearchViewController.performSegue(withIdentifier: SegueIdentifiers.showMovieDetails, sender: sender)
        }
    }
    
    private class PersonUtilsFactory: EntityUtilsAbstractFactory {
        
        override func setMultiSearchTableViewCellImageProperties(cell: UITableViewCell, by indexPath: IndexPath) {
            let popularPerson = multiSearchViewController.entities[indexPath.row] as! PopularPerson
            (cell as! PersonTableViewCell).imagePath = popularPerson.imagePath
            UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell as! ImageFromInternetViewCell)
        }
        
        override func getMultiSearchTableViewCell(from tableView: UITableView, by indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
            let person = multiSearchViewController.entities[indexPath.row] as! Person
            cell.originController = multiSearchViewController
            cell.personName = person.name
            return cell
        }
        
        override func performSegueForMultiSearchTableViewCell(from tableView: UITableView, at indexPath: IndexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath)
            let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
            multiSearchViewController.performSegue(withIdentifier: SegueIdentifiers.showPersonMovies, sender: sender)
        }
    }
}
