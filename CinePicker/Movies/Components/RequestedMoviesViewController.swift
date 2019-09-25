import UIKit

class RequestedMoviesViewController: StatesViewController {

    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var requestedMoviesTableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        return CinePickerColors.getStatusBarStyle(userInterfaceStyle: userInterfaceStyle)
    }
    
    override var tableViewDefinition: UITableView! {
        return requestedMoviesTableView
    }
    
    public var requestMovies: ((_ requestedPage: Int, _ callback: @escaping (_ requestedMovies: [Movie]?) -> Void) -> Void)!
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var requestedPage: Int = 1
    
    private var requestedMovies: [Movie] = []
    
    private var savedMovies: [SavedMovie] = [] {
        didSet {
            savedMovieMap = [:]
            
            for movie in savedMovies {
                savedMovieMap[movie.id] = movie
            }
        }
    }
    
    private var savedMovieMap: [Int: SavedMovie] = [:]
    
    private var isLiveScrollingRelevant = false

    private var isBeingLiveScrolled = false
    
    private let liveScrollingDellayMilliseconds: Int = 1000
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let imageService = ImageService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        savedMovies = MovieRepository.shared.getAll()
        requestedMoviesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineMoreButton()
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
        
        requestedMovies = data as! [Movie]
        requestedMoviesTableView.reloadData()
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
            action: #selector(RequestedMoviesViewController.onPressActionsButton)
        )
        
        actionsBarButtonItem.isEnabled = false
        
        navigationItem.rightBarButtonItem = actionsBarButtonItem
    }
    
    private func defineTableView() {
        requestedMoviesTableView.rowHeight = MovieTableViewCell.standardHeight
        requestedMoviesTableView.tableFooterView = UIView(frame: .zero)
        
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        requestedMoviesTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
        
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        requestedMoviesTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loading)
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        topBarView.backgroundColor = CinePickerColors.getTopBarColor(userInterfaceStyle: userInterfaceStyle)
        requestedMoviesTableView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
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
        
        requestMovies(requestedPage) { (requestedMoviesResult) in
            OperationQueue.main.addOperation {
                self.unsetLoadingState()
                
                guard let requestedMoviesResult = requestedMoviesResult else {
                    self.setFailedLoadingState()
                    return
                }
                
                self.actionsBarButtonItem.isEnabled = true
                
                self.isLiveScrollingRelevant = !requestedMoviesResult.isEmpty
                
                if requestedMoviesResult.isEmpty {
                    self.setMessageState(withMessage: CinePickerCaptions.thereAreNoMoviesFound)
                    return
                }
                
                self.updateTable(withData: requestedMoviesResult)
            }
        }
    }
    
    private func performLiveScrollingRequest() {
        requestedPage += 1
        isBeingLiveScrolled = true
        
        let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(liveScrollingDellayMilliseconds)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.requestMovies(self.requestedPage) { (requestedMoviesResult) in
                OperationQueue.main.addOperation {
                    self.isBeingLiveScrolled = false
                    
                    guard let requestedMoviesResult = requestedMoviesResult else {
                        self.isLiveScrollingRelevant = false
                        self.updateTable(withData: self.requestedMovies)
                        
                        return
                    }
                    
                    self.isLiveScrollingRelevant = !requestedMoviesResult.isEmpty
                    self.updateTable(withData: self.requestedMovies + requestedMoviesResult)
                }
            }
        }
    }

}

extension RequestedMoviesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestedMovies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == requestedMovies.count - 1 && isLiveScrollingRelevant {
            return LoadingTableViewCell.standardHeight
        }
        
        return MovieTableViewCell.standardHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView(userInterfaceStyle: userInterfaceStyle)
        
        if !(cell is MovieTableViewCell) {
            return
        }
        
        let imagePath = requestedMovies[indexPath.row].imagePath
        
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
        if indexPath.row == requestedMovies.count - 1 && isLiveScrollingRelevant {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
            
            if !isBeingLiveScrolled {
                performLiveScrollingRequest()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movie, for: indexPath) as! MovieTableViewCell
        
        let movie = requestedMovies[indexPath.row]
        
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

extension RequestedMoviesViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showMovieDetails {
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            movieDetailsViewController.movieId = requestedMovies[indexPath.row].id
            movieDetailsViewController.movieTitle = requestedMovies[indexPath.row].title
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
