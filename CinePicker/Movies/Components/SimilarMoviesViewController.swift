import UIKit

class SimilarMoviesViewController: StatesViewController {

    @IBOutlet weak var similarMoviesTableView: UITableView!
    
    override var tableViewDefinition: UITableView! {
        return similarMoviesTableView
    }
    
    public var movie: Movie!
    
    private var similarMovies: [Movie] = []
    
    private let similarMovieService = SimilarMovieService(movieService: MovieService())
    
    private let imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Similar to \(movie.originalTitle)"
        
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
        
        similarMovies = data as! [Movie]
        similarMoviesTableView.reloadData()
    }
    
    private func defineTableView() {
        similarMoviesTableView.rowHeight = MovieTableViewCell.standardHeight
        similarMoviesTableView.tableFooterView = UIView(frame: .zero)
        
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        similarMoviesTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }
    
    private func performRequest() {
        setLoadingState()
        
        similarMovieService.requestMovies(byMovieId: movie.id, andPage: 1) { (requestedMoviesResult, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                self.unsetLoadingState()
                
                if isLoadingDataFailed {
                    self.setFailedLoadingState()
                    self.updateTable(withData: [])
                    
                    return
                }
                
                self.similarMovies = requestedMoviesResult
                self.updateTable(withData: self.similarMovies)
                
                if self.similarMovies.isEmpty {
                    self.setMessageState(withMessage: "There are no movies found...")
                    return
                }
            }
        }
    }

}

extension SimilarMoviesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarMovies.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let movie = similarMovies[indexPath.row]
        
        if !movie.imagePath.isEmpty {
            var cell = cell as! ImageFromInternet
            UIViewHelper.setImageFromInternet(by: movie.imagePath, at: &cell, using: imageService)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        
        cell.title = similarMovies[indexPath.row].title
        cell.originalTitle = similarMovies[indexPath.row].originalTitle
        cell.releaseYear = similarMovies[indexPath.row].releaseYear
        cell.voteCount = similarMovies[indexPath.row].voteCount
        cell.rating = similarMovies[indexPath.row].rating
        
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

extension SimilarMoviesViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showMovieDetails {
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            movieDetailsViewController.movieId = similarMovies[indexPath.row].id
            movieDetailsViewController.movieOriginalTitle = similarMovies[indexPath.row].originalTitle
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
