import UIKit

class RequestedMoviesViewController: StateViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var requestedMoviesTableView: UITableView!
    
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
        registerMovieTableViewCell()
        registerLoadingTableViewCell()
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
        requestedMovies = data as! [Movie]
        requestedMoviesTableView.reloadData()
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
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
    }
    
    private func registerMovieTableViewCell() {
        let movieTableViewCellNib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        requestedMoviesTableView.register(movieTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.movie)
    }
    
    private func registerLoadingTableViewCell() {
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        requestedMoviesTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loading)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        topBarView.backgroundColor = CinePickerColors.getTopBarColor()
        requestedMoviesTableView.backgroundColor = CinePickerColors.getBackgroundColor()
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
                self.updateTable(providingData: requestedMoviesResult)
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
                        self.updateTable(providingData: self.requestedMovies)
                        
                        return
                    }
                    self.isLiveScrollingRelevant = !requestedMoviesResult.isEmpty
                    self.updateTable(providingData: self.requestedMovies + requestedMoviesResult)
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
        if !(cell is MovieTableViewCell) {
            return
        }
        let cell = cell as! MovieTableViewCell
        setMovieTableViewCellImageProperties(cell: cell, indexPath: indexPath)
    }
    
    private func setMovieTableViewCellImageProperties(cell: MovieTableViewCell, indexPath: IndexPath) {
        cell.imagePath = requestedMovies[indexPath.row].imagePath
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
        cell.onTapImageView = { (imagePath) in
            UIViewUtilsFactory.shared.getImageUtils().openImage(from: self, by: imagePath)
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
        setMovieTableViewCellProperties(cell: cell, indexPath: indexPath)
        cell.selectedBackgroundView = UIViewUtilsFactory.shared.getViewUtils().getUITableViewCellSelectedBackgroundView()
        return cell
    }
    
    private func setMovieTableViewCellProperties(cell: MovieTableViewCell, indexPath: IndexPath) {
        let movie = requestedMovies[indexPath.row]
        cell.title = movie.title
        cell.originalTitle = movie.originalTitle
        cell.releaseYear = movie.releaseYear
        if let savedMovie = savedMovieMap[movie.id] {
            cell.willCheckItOutIsHidden = !savedMovie.containsTag(byName: .willCheckItOut)
            cell.iLikeItIsHidden = !savedMovie.containsTag(byName: .iLikeIt)
        }
        cell.voteCount = movie.voteCount
        cell.rating = movie.rating
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
            setMovieDetailsViewControllerProperties(for: segue, sender: sender)
            return
        }
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
    private func setMovieDetailsViewControllerProperties(for segue: UIStoryboardSegue, sender: Any?) {
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        let sender = sender as! TableViewCellSender
        let indexPath = sender.indexPath
        movieDetailsViewController.movieId = requestedMovies[indexPath.row].id
        movieDetailsViewController.movieTitle = requestedMovies[indexPath.row].title
    }
}
