import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var movieDetailsTableView: UITableView!
    
    public var movieId: Int!
    
    public var movieOriginalTitle: String?
    
    private var movieDetails: MovieDetails!
    
    private var loadingView: UIView!
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private let numberOfSections: Int = 4
    
    private let movieDetailsSectionNumber: Int = 0
    
    private let movieDetailsBookmarkActionSectionNumber: Int = 1
    
    private let movieDetailsOverviewSectionNumber: Int = 2
    
    private let movieDetailsCharactersSectionNumber: Int = 3
    
    private var isCharactersGoingToBeRequested = false
    
    private var isCharactersBeingRequested = false
    
    private var isCharactersRequestFailed = false
    
    private var characters: [Character] = []
    
    private let imageService = ImageService()
    
    private var movieDetailsService: MovieDetailsService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movieOriginalTitle
        
        movieDetailsService = MovieDetailsService(movieService: MovieService(), personService: PersonService())
        
        defineLoadingView()
        defineFailedLoadingView()
        defineTableView()
        
        performMovieDetailsRequest()
    }
    
    private func defineTableView() {
        movieDetailsTableView.rowHeight = UITableView.automaticDimension
        movieDetailsTableView.estimatedRowHeight = 80
        movieDetailsTableView.tableFooterView = UIView(frame: .zero)
        
        let personTableViewCellNib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        movieDetailsTableView.register(personTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.person)
        
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        movieDetailsTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loading)
        
        let failedLoadingTableViewCellNib = UINib(nibName: "FailedLoadingTableViewCell", bundle: nil)
        movieDetailsTableView.register(failedLoadingTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.failedLoading)
    }
    
    private func defineLoadingView() {
        loadingView = UIViewHelper.getLoadingView(for: movieDetailsTableView)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewHelper.getFailedLoadingView(for: movieDetailsTableView, onTouchDownHandler: onReloadGettingMovieDetails)
    }
    
    private func onReloadGettingMovieDetails() {
        performMovieDetailsRequest()
    }
    
    private func onSelectFailedLoadingCell() {
        performCharactersRequest(fromReloading: true)
    }
    
    private func onSelectBookmarkActionCell() {
        defer {
            let bookmarkActionIndexPath = IndexPath(row: 0, section: movieDetailsBookmarkActionSectionNumber)
            movieDetailsTableView.reloadRows(at: [bookmarkActionIndexPath], with: .automatic)
        }
        
        let isSavedInBookmarks = checkIfSavedInBookmarks()
        
        if isSavedInBookmarks {
            _ = BookmarkRepository.shared.removeBookmark(movie: movieDetails)
        } else {
            _ = BookmarkRepository.shared.saveBookmark(movie: movieDetails)
        }
    }
    
    private func performMovieDetailsRequest() {
        movieDetailsTableView.backgroundView = loadingView
        
        movieDetailsService.requestMovieDetails(by: movieId) { (requestedMovieDetails) in
            OperationQueue.main.addOperation {
                guard let requestedMovieDetails = requestedMovieDetails else {
                    self.movieDetailsTableView.backgroundView = self.failedLoadingView
                    self.isCharactersGoingToBeRequested = false
                    
                    return
                }
                
                self.movieDetailsTableView.backgroundView = nil
                
                self.movieDetails = requestedMovieDetails
                
                self.isCharactersGoingToBeRequested = true
                self.movieDetailsTableView.reloadData()
                
                self.performCharactersRequest(fromReloading: false)
            }
        }
    }
    
    private func performCharactersRequest(fromReloading: Bool) {
        isCharactersGoingToBeRequested = false
        isCharactersBeingRequested = true
        isCharactersRequestFailed = false
        
        if fromReloading {
            let firstCharactersIndexPath = IndexPath(row: 0, section: self.movieDetailsCharactersSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstCharactersIndexPath], with: .automatic)
        }
        
        movieDetailsService.requestCharacters(by: movieDetails.id) { (requestedCharacters, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                self.isCharactersBeingRequested = false
                self.isCharactersRequestFailed = isLoadingDataFailed
                
                let firstCharactersIndexPath = IndexPath(row: 0, section: self.movieDetailsCharactersSectionNumber)
                
                if self.isCharactersRequestFailed {
                    self.movieDetailsTableView.reloadRows(at: [firstCharactersIndexPath], with: .automatic)
                    return
                }
                
                self.movieDetailsTableView.deleteRows(at: [firstCharactersIndexPath], with: .automatic)
                
                self.characters = requestedCharacters
                
                var indexPaths: [IndexPath] = []
                
                for index in 0..<self.characters.count {
                    let indexPath = IndexPath(row: index, section: self.movieDetailsCharactersSectionNumber)
                    indexPaths.append(indexPath)
                }
                
                self.movieDetailsTableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func checkIfSavedInBookmarks() -> Bool {
        let bookmarks = BookmarkRepository.shared.getBookmarks()
        return bookmarks.contains { $0.id == movieDetails.id }
    }
    
}

extension MovieDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if movieDetails == nil {
            return 0
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movieDetails == nil {
            return 0
        }
        
        switch section {
        case movieDetailsSectionNumber: return 1
        case movieDetailsBookmarkActionSectionNumber: return 1
        case movieDetailsOverviewSectionNumber: return 1
        case movieDetailsCharactersSectionNumber: return getMovieDetailsCharactersSectionNumberOfRows()
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (movieDetailsSectionNumber, _): return MovieDetailsTableViewCell.standardHeight
        case (movieDetailsBookmarkActionSectionNumber, _): return MovieDetailsBookmarkActionTableViewCell.standardHeight
        case (movieDetailsOverviewSectionNumber, _): return MovieDetailsOverviewTableViewCell.standardHeight
        case (movieDetailsCharactersSectionNumber, _): return getMovieDetailsCharactersSectionRowHeight()
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case is MovieDetailsTableViewCell: prepare(movieDetailsTableViewCell: (cell as! MovieDetailsTableViewCell))
        case is PersonTableViewCell: prepare(personTableViewCell: (cell as! PersonTableViewCell), forRowAt: indexPath)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (movieDetailsSectionNumber, _): return getMovieDetailsTableViewCell(tableView, cellForRowAt: indexPath)
        case (movieDetailsBookmarkActionSectionNumber, _): return getMovieDetailsBookmarkActionTableViewCell(tableView, cellForRowAt: indexPath)
        case (movieDetailsOverviewSectionNumber, _): return getMovieDetailsOverviewTableViewCell(tableView, cellForRowAt: indexPath)
        case (movieDetailsCharactersSectionNumber, _): return getCharacterTableViewCell(tableView, cellForRowAt: indexPath)
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var imageUrl: URL? = nil
        
        switch cell {
        case is MovieDetailsTableViewCell: imageUrl = (cell as! MovieDetailsTableViewCell).imageUrl
        case is PersonTableViewCell: imageUrl = (cell as! PersonTableViewCell).imageUrl
        default: return
        }
        
        if imageUrl == nil {
            return
        }
        
        imageService.cancelDownloading(for: imageUrl!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == movieDetailsBookmarkActionSectionNumber {
            onSelectBookmarkActionCell()
            return
        }
        
        if isCharactersRequestFailed {
            onSelectFailedLoadingCell()
            return
        }
        
        // TODO: This row is incorrect, there should be tableView.dequeueReusableCell(..., for: indexPath) instead, but
        // there is a bug which breaks cell after dequeueing by index path, and I don't know for now what's wrong!
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person)!
        
        let sender = TableViewCellSender(cell: cell, indexPath: indexPath)

        performSegue(withIdentifier: SegueIdentifiers.showPersonMovies, sender: sender)
    }
    
    private func getMovieDetailsTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetails, for: indexPath) as! MovieDetailsTableViewCell

        cell.title = movieDetails.title
        cell.originalTitle = movieDetails.originalTitle
        cell.genres = movieDetails.genres
        cell.releaseYear = movieDetails.releaseYear
        cell.voteCount = movieDetails.voteCount
        cell.rating = movieDetails.rating
        
        return cell
    }
    
    private func getMovieDetailsBookmarkActionTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsBookmarkAction, for: indexPath) as! MovieDetailsBookmarkActionTableViewCell

        cell.isRemoveAction = checkIfSavedInBookmarks()
        
        return cell
    }
    
    private func getMovieDetailsOverviewTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsOverview, for: indexPath) as! MovieDetailsOverviewTableViewCell

        cell.overview = movieDetails.overview
        
        return cell
    }
    
    private func getCharacterTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCharactersBeingRequested {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
            return cell
        }
        
        if isCharactersRequestFailed {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.failedLoading) as! FailedLoadingTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
        cell.personName = characters[indexPath.row].name
        cell.personPosition = characters[indexPath.row].characterName
        cell.isPersonPositionValid = !characters[indexPath.row].isUncredited
        
        return cell
    }
    
    private func prepare(movieDetailsTableViewCell cell: MovieDetailsTableViewCell) {
        if !movieDetails.imagePath.isEmpty {
            var cell = cell as ImageFromInternet
            UIViewHelper.setImageFromInternet(by: movieDetails.imagePath, at: &cell, using: imageService)
        }
    }
    
    private func prepare(personTableViewCell cell: PersonTableViewCell, forRowAt indexPath: IndexPath) {
        let character = characters[indexPath.row]

        if !character.imagePath.isEmpty {
            var cell = cell as ImageFromInternet
            UIViewHelper.setImageFromInternet(by: character.imagePath, at: &cell, using: imageService)
        }
    }
    
    private func getMovieDetailsCharactersSectionNumberOfRows() -> Int {
        if isCharactersGoingToBeRequested || isCharactersBeingRequested || isCharactersRequestFailed {
            return 1
        }
        
        return characters.count
    }
    
    private func getMovieDetailsCharactersSectionRowHeight() -> CGFloat {
        if isCharactersBeingRequested {
            return LoadingTableViewCell.standardHeight
        }
        
        if isCharactersRequestFailed {
            return FailedLoadingTableViewCell.standardHeight
        }
        
        return PersonTableViewCell.standardHeight
    }
    
}

extension MovieDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showPersonMovies {
            let movieListViewController = segue.destination as! MovieListViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            movieListViewController.person = characters[indexPath.row]
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
