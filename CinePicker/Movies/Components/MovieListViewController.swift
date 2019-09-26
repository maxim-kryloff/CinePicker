import UIKit

class MovieListViewController: StatesViewController {
    
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
            savedMovieMap = [:]
            
            for movie in savedMovies {
                savedMovieMap[movie.id] = movie
            }
        }
    }
    
    private var savedMovieMap: [Int: SavedMovie] = [:]
    
    private var isBeingRequested = false
    
    private var isRequestFailed = false
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let movieListService = MovieListService(movieService: MovieService())
    
    private let imageService = ImageService()
    
    @IBAction func onPersonTypeSegmentControlAction(_ sender: Any) {
        if isBeingRequested || isRequestFailed {
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
        updateTable(withData: moviesToDisplay)
        
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

        navigationItem.title = CinePickerCaptions.movies(ofPerson: person.name)
        
        defineNavigationController()
        defineMoreButton()
        defineSegmentControl()
        defineTableView()
        
        setDefaultColors()

        performRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        loadedImages = [:]
    }
    
    override func onReloadData() {
        super.onReloadData()

        unsetAllStates()
        performRequest()
    }
    
    override func updateTable<DataType>(withData data: [DataType]) {
        super.updateTable(withData: data)
        
        movies = data as! [Movie]
        movieListTableView.reloadData()
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
        
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        movieListTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        
        if (userInterfaceStyle == .dark) {
            personTypeSegmentControl.selectedSegmentTintColor = CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle)
        }
        
        movieListTableView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    @objc private func onPressActionsButton() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        UIViewHelper.showAlert(
            userInterfaceStyle: userInterfaceStyle,
            buttonActions: [
                (title: CinePickerCaptions.backToSearch, action: backToSearchAction)
            ]
        )
    }

    private func performRequest() {
        setLoadingState()
        
        isBeingRequested = true
        isRequestFailed = false
        
        movieListService.requestMovies(by: person.id) { (requestedMoviesResult) in
            OperationQueue.main.addOperation {
                self.unsetLoadingState()
                
                self.isBeingRequested = false
                
                guard let requestedMoviesResult = requestedMoviesResult else {
                    self.isRequestFailed = true
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
                
                self.updateTable(withData: moviesToDisplay)
            }
        }
    }

}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView(userInterfaceStyle: userInterfaceStyle)
        
        let imagePath = movies[indexPath.row].imagePath
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        if let image = loadedImages[movie.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = movie.imagePath
        }
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        cell.onTapImageViewHandler = { (imagePath) in
            UIViewHelper.openImage(from: self, by: imagePath, using: self.imageService, userInterfaceStyle: userInterfaceStyle)
        }
        
        cell.title = movie.title
        cell.originalTitle = movie.originalTitle
        cell.releaseYear = movie.releaseYear
        
        if let savedMovie = savedMovieMap[movie.id] {
            cell.isWillCheckItOutHidden = !savedMovie.containsTag(byName: .willCheckItOut)
            cell.isILikeItHidden = !savedMovie.containsTag(byName: .iLikeIt)
        }
        
        cell.voteCount = movie.voteCount
        cell.rating = movie.rating
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MovieTableViewCell
        
        if let imageUrl = cell.imageUrl {
            imageService.cancelDownloading(for: imageUrl)
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
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            movieDetailsViewController.movieId = movies[indexPath.row].id
            movieDetailsViewController.movieTitle = movies[indexPath.row].title
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
