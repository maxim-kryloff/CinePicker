import UIKit

class MovieListViewController: StateViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var movieListTableView: UITableView!
    
    @IBOutlet weak var personTypeSegmentControl: UISegmentedControl!
    
    override var tableViewDefinition: UITableView! {
        return movieListTableView
    }
    
    public var person: Person!
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var movies: [Movie] = []
    
    private var castMovies: [Movie] = []
    
    private var crewMovies: [Movie] = []
    
    private var savedMovies: [SavedMovie] = [] {
        didSet {
            savedMovieDictionary = [:]
            for movie in savedMovies {
                savedMovieDictionary[movie.id] = movie
            }
        }
    }
    
    private var savedMovieDictionary: [Int: SavedMovie] = [:]
    
    private var isBeingRequested = false
    
    private var requestIsFailed = false
    
    private let movieListService = MovieListService(movieService: MovieService())
    
    @IBAction func onPersonTypeSegmentControlAction(_ sender: Any) {
        if isBeingRequested || requestIsFailed {
            return
        }
        let moviesToDisplay = personTypeSegmentControl.selectedSegmentIndex == 0
            ? castMovies
            : crewMovies
        if moviesToDisplay.isEmpty {
            self.setMessageState(withMessage: CinePickerCaptions.thereAreNoMoviesFound)
            return
        }
        unsetMessageState()
        showMoviesAfterSegmentSelection(movies: moviesToDisplay)
    }
    
    private func showMoviesAfterSegmentSelection(movies: [Movie]) {
        updateTable(providingData: movies)
        let firstRowIndexPath = IndexPath(row: 0, section: 0)
        movieListTableView.scrollToRow(at: firstRowIndexPath, at: .top, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedMovies = MovieRepository.shared.getAll()
        movieListTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineTitle()
        defineNavigationController()
        defineMoreButton()
        defineSegmentControl()
        defineTableView()
        registerMovieTableViewCell()
        setDefaultColors()
        performRequest()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            UIViewUtilsFactory.shared.getAlertUtils().closeAlert()
        }
    }
    
    override func onReloadData() {
        super.onReloadData()
        unsetAllStates()
        performRequest()
    }
    
    override func updateTable<DataType>(providingData data: [DataType]) {
        super.updateTable(providingData: data)
        movies = data as! [Movie]
        movieListTableView.reloadData()
    }
    
    private func defineTitle() {
        navigationItem.title = CinePickerCaptions.movies(ofPerson: person.name)
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
    }
    
    private func defineMoreButton() {
        actionsBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.more,
            style: .plain,
            target: self,
            action: #selector(MovieListViewController.onPressActionsButton)
        )
        actionsBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = actionsBarButtonItem
    }
    
    private func defineSegmentControl() {
        personTypeSegmentControl.setTitle(CinePickerCaptions.cast, forSegmentAt: 0)
        personTypeSegmentControl.setTitle(CinePickerCaptions.crew, forSegmentAt: 1)
        personTypeSegmentControl.setTitleTextAttributes(
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)],
            for: .normal
        )
        personTypeSegmentControl.setTitleTextAttributes(
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)],
            for: .selected
        )
    }
    
    private func defineTableView() {
        movieListTableView.rowHeight = MovieTableViewCell.standardHeight
        movieListTableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func registerMovieTableViewCell() {
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        movieListTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        personTypeSegmentControl.selectedSegmentTintColor = CinePickerColors.getSelectedSegmentTintColor()
        movieListTableView.backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    @objc private func onPressActionsButton() {
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        UIViewUtilsFactory.shared.getAlertUtils().showAlert(
            traitCollection: traitCollection,
            buttonActions: [
                (title: CinePickerCaptions.backToSearch, action: backToSearchAction)
            ]
        )
    }
    
    private func performRequest() {
        setLoadingState()
        isBeingRequested = true
        requestIsFailed = false
        movieListService.requestMovies(by: person.id) { (requestedMoviesResult) in
            DispatchQueue.main.async {
                self.unsetLoadingState()
                self.isBeingRequested = false
                guard let requestedMoviesResult = requestedMoviesResult else {
                    self.requestIsFailed = true
                    self.setFailedLoadingState()
                    return
                }
                self.castMovies = requestedMoviesResult.cast
                self.crewMovies = requestedMoviesResult.crew
                self.actionsBarButtonItem.isEnabled = true
                let moviesToDisplay: [Movie]
                if self.crewMovies.count > self.castMovies.count {
                    self.personTypeSegmentControl.selectedSegmentIndex = 1
                    moviesToDisplay = self.crewMovies
                } else {
                    self.personTypeSegmentControl.selectedSegmentIndex = 0
                    moviesToDisplay = self.castMovies
                }
                if moviesToDisplay.isEmpty {
                    self.setMessageState(withMessage: CinePickerCaptions.thereAreNoMoviesFound)
                    return
                }
                self.updateTable(providingData: moviesToDisplay)
            }
        }
    }
}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MovieTableViewCell
        setMovieTableViewCellImageProperties(cell: cell, indexPath: indexPath)
    }
    
    private func setMovieTableViewCellImageProperties(cell: MovieTableViewCell, indexPath: IndexPath) {
        cell.imagePath = movies[indexPath.row].imagePath
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        setMovieTableViewCellProperties(cell: cell, indexPath: indexPath)
        return cell
    }
    
    private func setMovieTableViewCellProperties(cell: MovieTableViewCell, indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        cell.movie = movie
        cell.originController = self
        if let savedMovie = savedMovieDictionary[movie.id] {
            cell.savedMovie = savedMovie
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath)
        let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
        performSegue(withIdentifier: SegueIdentifiers.showMovieDetails, sender: sender)
    }
}

extension MovieListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let segueIdentifier = segue.identifier else {
            return
        }
        if segueIdentifier == SegueIdentifiers.showMovieDetails {
            setMovieDetailsViewControllerProperties(for: segue, sender: sender)
            return
        }
        fatalError("Unexpected segue identifier: \(segueIdentifier).")
    }
    
    private func setMovieDetailsViewControllerProperties(for segue: UIStoryboardSegue, sender: Any?) {
        let sender = sender as! TableViewCellSender
        MovieTableViewCell.setMovieDetailsViewControllerProperties(for: segue, movie: movies[sender.indexPath.row])
    }
}
