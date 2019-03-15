import UIKit

class MovieListViewController: StatesViewController {
    
    @IBOutlet weak var movieListTableView: UITableView!
    
    override var tableViewDefinition: UITableView! {
        return movieListTableView
    }
    
    public var person: Person!
    
    private var movies: [Movie] = []
    
    private let movieListService = MovieListService(movieService: MovieService())
    
    private let imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "\(person.name)'s Movies"
        
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
    
    private func defineTableView() {
        movieListTableView.rowHeight = MovieTableViewCell.standardHeight
        movieListTableView.tableFooterView = UIView(frame: .zero)
        
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        movieListTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }

    private func performRequest() {
        setLoadingState()
        
        movieListService.requestMovies(by: person.id) { (requestedMovies, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                self.unsetLoadingState()
                
                if isLoadingDataFailed {
                    self.setFailedLoadingState()
                    self.updateTable(withData: [])
                    
                    return
                }
                
                self.updateTable(withData: requestedMovies)
                
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
        
        guard let movieImagePath = movie.imagePath else {
            return
        }
        
        var cell = cell as! ImageFromInternet
        
        UIViewHelper.setImageFromInternet(by: movieImagePath, at: &cell, using: imageService)
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
            
            movieListViewController.movie = movies[indexPath.row]
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
