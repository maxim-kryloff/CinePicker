import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var movieDetailsTableView: UITableView!
    
    public var movie: Movie!
    
    private let numberOfSections: Int = 3
    
    private let movieDetailsSectionNumber: Int = 0
    
    private let movieDetailsOverviewSectionNumber: Int = 1
    
    private let movieDetailsCharactersSectionNumber: Int = 2
    
    private var isBeingRequested = false
    
    private var isRequestFailed = false
    
    private var characters: [Character] = []
    
    private let imageService = ImageService()
    
    private let movieService = MovieService()
    
    private let movieDetailsService = MovieDetailsService(personService: PersonService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        defineTableView()
        
        performRequest(fromReloading: false)
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
    
    private func onReloadData() {
        performRequest(fromReloading: true)
    }
    
    private func performRequest(fromReloading: Bool) {
        isBeingRequested = true
        isRequestFailed = false
        
        if fromReloading {
            let firstCharactersIndexPath = IndexPath(row: 0, section: self.movieDetailsCharactersSectionNumber)
            self.movieDetailsTableView.reloadRows(at: [firstCharactersIndexPath], with: .automatic)
        }
        
        movieDetailsService.requestCharacters(by: movie.id) { (requestedCharacters, isLoadingDataFailed) in
            OperationQueue.main.addOperation {
                self.isBeingRequested = false
                self.isRequestFailed = isLoadingDataFailed
                
                let firstCharactersIndexPath = IndexPath(row: 0, section: self.movieDetailsCharactersSectionNumber)
                
                if self.isRequestFailed {
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
    
}

extension MovieDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case movieDetailsSectionNumber: return 1
        case movieDetailsOverviewSectionNumber: return 1
        case movieDetailsCharactersSectionNumber: return getMovieDetailsCharactersSectionNumberOfRows()
        default: fatalError("Section number is out of range...")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (movieDetailsSectionNumber, _): return MovieDetailsTableViewCell.standardHeight
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
        if isRequestFailed {
            onReloadData()
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

        cell.title = movie.title
        cell.originalTitle = movie.originalTitle
        cell.releaseYear = movie.releaseYear
        cell.voteCount = movie.voteCount
        cell.rating = movie.rating
        
        return cell
    }
    
    private func getMovieDetailsOverviewTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.movieDetailsOverview, for: indexPath) as! MovieDetailsOverviewTableViewCell

        cell.overview = movie.overview
        
        return cell
    }
    
    private func getCharacterTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isBeingRequested {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading) as! LoadingTableViewCell
            return cell
        }
        
        if isRequestFailed {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.failedLoading) as! FailedLoadingTableViewCell
            
            cell.onTouchDownHandler = onReloadData
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
        cell.personName = characters[indexPath.row].name
        cell.personPosition = characters[indexPath.row].characterName
        cell.isPersonPositionValid = !characters[indexPath.row].isUncredited
        
        return cell
    }
    
    private func prepare(movieDetailsTableViewCell cell: MovieDetailsTableViewCell) {
        if let movieImagePath = movie.imagePath {
            var cell = cell as ImageFromInternet
            
            UIViewHelper.setImageFromInternet(by: movieImagePath, at: &cell, using: imageService)
        }
        
        guard let genreIds = movie.genreIds else {
            return
        }
        
        CacheService.shared.getGenres(callback: { (genres) in
            OperationQueue.main.addOperation {
                cell.genres = genres.filter { genreIds.contains($0.id) }
            }
        })
    }
    
    private func prepare(personTableViewCell cell: PersonTableViewCell, forRowAt indexPath: IndexPath) {
        let character = characters[indexPath.row]
        
        guard let characterImagePath = character.imagePath else {
            return
        }
        
        var cell = cell as ImageFromInternet
        
        UIViewHelper.setImageFromInternet(by: characterImagePath, at: &cell, using: imageService)
    }
    
    private func getMovieDetailsCharactersSectionNumberOfRows() -> Int {
        return isBeingRequested || isRequestFailed ? 1 : characters.count
    }
    
    private func getMovieDetailsCharactersSectionRowHeight() -> CGFloat {
        if isBeingRequested {
            return LoadingTableViewCell.standardHeight
        }
        
        if isRequestFailed {
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
