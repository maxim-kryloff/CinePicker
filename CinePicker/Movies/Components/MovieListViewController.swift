import UIKit

class MovieListViewController: StatesViewController {
    
    @IBOutlet weak var movieListTableView: UITableView!
    
    @IBOutlet weak var personTypeSegmentControl: UISegmentedControl!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var tableViewDefinition: UITableView! {
        return movieListTableView
    }
    
    public var person: Person!
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var movies: [Movie] = []
    
    private var castMovies: [Movie] = []
    
    private var crewMovies: [Movie] = []
    
    private var isBeingRequested = false
    
    private var isRequestFailed = false
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let movieListService = MovieListService(movieService: MovieService())
    
    private let imageService = ImageService()
    
    @IBAction func onPersonTypeSegmentControlAction(_ sender: Any) {
        if isBeingRequested || isRequestFailed {
            return
        }
        
        if personTypeSegmentControl.selectedSegmentIndex == 0 {
            updateTable(withData: castMovies)
        } else {
            updateTable(withData: crewMovies)
        }
        
        if movies.isEmpty {
            self.setMessageState(withMessage: "There are no movies found...")
        } else {
            unsetMessageState()
            
            let firstRowIndexPath = IndexPath(row: 0, section: 0)
            movieListTableView.scrollToRow(at: firstRowIndexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "\(person.name)'s Movies"
        
        defineMoreButton()
        defineSegmentControl()
        defineTableView()

        performRequest()
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
    
    private func defineMoreButton() {
        actionsBarButtonItem = UIBarButtonItem(
            title: "More",
            style: .plain,
            target: self,
            action: #selector(MovieListViewController.onPressActionsButton)
        )
        
        actionsBarButtonItem.isEnabled = false
        
        navigationItem.rightBarButtonItem = actionsBarButtonItem
    }
    
    private func defineSegmentControl() {
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
    
    @objc private func onPressActionsButton() {
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        UIViewHelper.showAlert(
            [
                (title: "Back to Search", action: backToSearchAction)
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
                    self.updateTable(withData: [])
                    
                    return
                }
                
                self.castMovies = requestedMoviesResult.cast
                self.crewMovies = requestedMoviesResult.crew
                
                self.actionsBarButtonItem.isEnabled = true
                
                if self.crewMovies.count > self.castMovies.count {
                    self.personTypeSegmentControl.selectedSegmentIndex = 1
                } else {
                    self.personTypeSegmentControl.selectedSegmentIndex = 0
                }
                
                if self.personTypeSegmentControl.selectedSegmentIndex == 0 {
                    self.updateTable(withData: self.castMovies)
                } else {
                    self.updateTable(withData: self.crewMovies)
                }
                
                if self.movies.isEmpty {
                    self.setMessageState(withMessage: "There are no movies found...")
                    return
                }
            }
        }
    }

}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView()
        
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
        
        loadedImages = [:]
        
        if segueIdentifier == SegueIdentifiers.showMovieDetails {
            let movieListViewController = segue.destination as! MovieDetailsViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            movieListViewController.movieId = movies[indexPath.row].id
            movieListViewController.movieOriginalTitle = movies[indexPath.row].originalTitle
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
