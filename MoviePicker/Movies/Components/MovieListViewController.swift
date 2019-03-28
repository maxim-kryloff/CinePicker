import UIKit

class MovieListViewController: StatesViewController {
    
    @IBOutlet weak var movieListTableView: UITableView!
    
    @IBOutlet weak var personTypeSegmentControl: UISegmentedControl!
    
    override var tableViewDefinition: UITableView! {
        return movieListTableView
    }
    
    public var person: Person!
    
    private var movies: [Movie] = []
    
    private var castMovies: [Movie] = []
    
    private var crewMovies: [Movie] = []
    
    private var isBeingRequested = false
    
    private var isRequestFailed = false
    
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
    
    private func defineSegmentControl() {
        personTypeSegmentControl.backgroundColor = .clear
        personTypeSegmentControl.tintColor = .clear
        
        personTypeSegmentControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.darkGray
            ],
            for: .normal
        )
        
        personTypeSegmentControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ],
            for: .selected
        )
    }
    
    private func defineTableView() {
        movieListTableView.rowHeight = MovieTableViewCell.standardHeight
        movieListTableView.tableFooterView = UIView(frame: .zero)
        
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        movieListTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }

    private func performRequest() {
        setLoadingState()
        
        isBeingRequested = true
        isRequestFailed = false
        
        movieListService.requestMovies(by: person.id) { (requestedMoviesResult, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                self.unsetLoadingState()
                
                self.isBeingRequested = false
                self.isRequestFailed = isLoadingDataFailed
                
                if isLoadingDataFailed {
                    self.setFailedLoadingState()
                    self.updateTable(withData: [])
                    
                    return
                }
                
                self.castMovies = requestedMoviesResult.cast
                self.crewMovies = requestedMoviesResult.crew
                
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
        let movie = movies[indexPath.row]
        
        if !movie.imagePath.isEmpty {
            var cell = cell as! ImageFromInternet
            UIViewHelper.setImageFromInternet(by: movie.imagePath, at: &cell, using: imageService)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        
        cell.title = movies[indexPath.row].title
        cell.originalTitle = movies[indexPath.row].originalTitle
        cell.releaseYear = movies[indexPath.row].releaseYear
        cell.voteCount = movies[indexPath.row].voteCount
        cell.rating = movies[indexPath.row].rating
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! MovieTableViewCell
        
        guard let imageUrl = cell.imageUrl else {
            return
        }
    
        imageService.cancelDownloading(for: imageUrl)
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
