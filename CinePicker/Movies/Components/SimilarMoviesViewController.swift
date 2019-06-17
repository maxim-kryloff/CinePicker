import UIKit

class SimilarMoviesViewController: StatesViewController {

    @IBOutlet weak var similarMoviesTableView: UITableView!
    
    override var tableViewDefinition: UITableView! {
        return similarMoviesTableView
    }
    
    public var movie: Movie!
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var requestedPage: Int = 1
    
    private var similarMovies: [Movie] = []
    
    private var isLiveScrollingRelevant = false

    private var isBeingLiveScrolled = false
    
    private let liveScrollingDellayMilliseconds: Int = 1000
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let similarMovieService = SimilarMovieService(movieService: MovieService())
    
    private let imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Similar to \(movie.originalTitle)"
        
        defineMoreButton()
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
    
    private func defineMoreButton() {
        actionsBarButtonItem = UIBarButtonItem(
            title: "More",
            style: .plain,
            target: self,
            action: #selector(SimilarMoviesViewController.onPressActionsButton)
        )
        
        navigationItem.rightBarButtonItem = actionsBarButtonItem
    }
    
    private func defineTableView() {
        similarMoviesTableView.rowHeight = MovieTableViewCell.standardHeight
        similarMoviesTableView.tableFooterView = UIView(frame: .zero)
        
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        similarMoviesTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
        
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        similarMoviesTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loading)
    }
    
    @objc private func onPressActionsButton() {
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        actionsBarButtonItem.isEnabled = false
        
        UIViewHelper.showAlert(
            [
                (title: "Back to Search", action: backToSearchAction)
            ]
        )
    }
    
    private func performRequest() {
        setLoadingState()
        
        let similarMovieRequest = SimilarMovieRequest(movieId: movie.id, page: requestedPage)
        
        similarMovieService.requestMovies(request: similarMovieRequest) { (_, requestedMoviesResult) in
            OperationQueue.main.addOperation {
                self.unsetLoadingState()
                
                guard let requestedMoviesResult = requestedMoviesResult else {
                    self.setFailedLoadingState()
                    self.updateTable(withData: [])
                    
                    return
                }
                
                self.similarMovies = requestedMoviesResult
                self.updateTable(withData: self.similarMovies)
                
                self.actionsBarButtonItem.isEnabled = true
                
                self.isLiveScrollingRelevant = !requestedMoviesResult.isEmpty
                
                if self.similarMovies.isEmpty {
                    self.setMessageState(withMessage: "There are no movies found...")
                    return
                }
            }
        }
    }
    
    private func performLiveScrollingRequest() {
        requestedPage += 1
        isBeingLiveScrolled = true
        
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(liveScrollingDellayMilliseconds)
        let similarMovieRequest = SimilarMovieRequest(movieId: movie.id, page: requestedPage)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.similarMovieService.requestMovies(request: similarMovieRequest) { (_, requestedMoviesResult) in
                OperationQueue.main.addOperation {
                    self.isBeingLiveScrolled = false
                    
                    guard let requestedMoviesResult = requestedMoviesResult else {
                        self.isLiveScrollingRelevant = false
                        self.updateTable(withData: self.similarMovies)
                        
                        return
                    }
                    
                    self.isLiveScrollingRelevant = !requestedMoviesResult.isEmpty
                    self.updateTable(withData: self.similarMovies + requestedMoviesResult)
                }
            }
        }
    }

}

extension SimilarMoviesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarMovies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == similarMovies.count - 1 && isLiveScrollingRelevant {
            return LoadingTableViewCell.standardHeight
        }
        
        return MovieTableViewCell.standardHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView()
        
        if !(cell is MovieTableViewCell) {
            return
        }
        
        let imagePath = similarMovies[indexPath.row].imagePath
        
        if imagePath.isEmpty {
            return
        }
        
        if self.loadedImages[imagePath] != nil {
            return
        }
        
        var cell = cell as! ImageFromInternet
        
        UIViewHelper.setImageFromInternet(by: imagePath, at: &cell, using: imageService) { (image) in
            self.loadedImages[imagePath] = image
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == similarMovies.count - 1 && isLiveScrollingRelevant {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
            
            if !isBeingLiveScrolled {
                performLiveScrollingRequest()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        
        let movie = similarMovies[indexPath.row]
        
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
        guard let cell = cell as? MovieTableViewCell else {
            return
        }
        
        guard let imageUrl = cell.imageUrl else {
            return
        }
        
        imageService.cancelDownloading(for: imageUrl)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie)!
        
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
        
        loadedImages = [:]
        
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
