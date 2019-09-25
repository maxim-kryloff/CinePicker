import UIKit
import LGButton

class DiscoverSettingsViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var discoverSettingsTableView: UITableView!
    
    @IBOutlet weak var searchLGButton: LGButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        return CinePickerColors.getStatusBarStyle(userInterfaceStyle: userInterfaceStyle)
    }
    
    private var loadingView: LoadingUIView!
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private let numberOfRows: Int = 3
    
    private let discoverSettingsGenresRowNumber: Int = 0
    
    private let discoverSettingsYearRowNumber: Int = 1
    
    private let discoverSettingsRatingRowNumber: Int = 2
    
    private var genres: [Genre] = []
    
    private var selectedGenres: [Genre] = []
    
    private var years: [NumericDiscoverSettingsItemToSelect] {
        var years: [NumericDiscoverSettingsItemToSelect] = []
        let currentYear: Int = Calendar.current.component(.year, from: Date())
        
        for value in 1900...currentYear {
            let year = NumericDiscoverSettingsItemToSelect(value: Double(value), label: String(value))
            years.append(year)
        }
        
        return years.reversed()
    }
    
    private var selectedYear: NumericDiscoverSettingsItemToSelect?
    
    private var ratings: [NumericDiscoverSettingsItemToSelect] {
        let ratings: [NumericDiscoverSettingsItemToSelect] = [
            NumericDiscoverSettingsItemToSelect(value: 6.5, label: "6.5 - \(CinePickerCaptions.high)"),
            NumericDiscoverSettingsItemToSelect(value: 5.0, label: "5.0 - \(CinePickerCaptions.medium)"),
            NumericDiscoverSettingsItemToSelect(value: 0.0, label: "0.0 - \(CinePickerCaptions.lowNone)")
        ]
        
        return ratings
    }
    
    private var selectedRating: NumericDiscoverSettingsItemToSelect?
    
    private let discoverSettingsService = DiscoverSettingsService(genreService: GenreService(), movieService: MovieService())
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        discoverSettingsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineLoadingView()
        defineFailedLoadingView()
        defineTableView()
        defineSearchLGButton()
        
        setDefaultColors()
        
        performRequest()
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.back, style: .plain, target: nil, action: nil
        )
    }
    
    private func defineLoadingView() {
        loadingView = UIViewHelper.getLoadingView(for: discoverSettingsTableView)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewHelper.getFailedLoadingView(for: discoverSettingsTableView, onTouchDownHandler: onReloadGettingGenres)
    }
    
    private func defineTableView() {
        discoverSettingsTableView.rowHeight = DiscoverSettingsTableViewCell.standardHeight
        discoverSettingsTableView.tableFooterView = UIView(frame: .zero)
        
        let discoverSettingsTableViewCellNib = UINib(nibName: "DiscoverSettingsTableViewCell", bundle: nil)
        discoverSettingsTableView.register(discoverSettingsTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.discoverSettings)
    }
    
    private func defineSearchLGButton() {
        searchLGButton.titleString = CinePickerCaptions.search
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        discoverSettingsTableView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        searchLGButton.bgColor = CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle)
        searchLGButton.titleColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    private func performRequest() {
        discoverSettingsTableView.backgroundView = loadingView
        searchLGButton.isHidden = true
        
        discoverSettingsService.requestGenres { (requestedGenres) in
            OperationQueue.main.addOperation {
                guard let requestedGenres = requestedGenres else {
                    self.discoverSettingsTableView.backgroundView = self.failedLoadingView
                    return
                }
                
                self.discoverSettingsTableView.backgroundView = nil
                self.searchLGButton.isHidden = false
                
                self.genres = requestedGenres
                self.discoverSettingsTableView.reloadData()
            }
        }
    }
    
    private func onReloadGettingGenres() {
        performRequest()
    }
    
    @IBAction func onSearchLGButtonTouchUpInside(_ sender: LGButton) {
        performSegue(withIdentifier: SegueIdentifiers.showRequestedMovies, sender: nil)
    }
    
}

extension DiscoverSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if genres.isEmpty {
            return 0
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if genres.isEmpty {
            return 0
        }
        
        return HeaderUIView.standardHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if genres.isEmpty {
            return nil
        }
        
        let view = UIViewHelper.getHeaderView(for: tableView)
        
        view.header = CinePickerCaptions.discover
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView(userInterfaceStyle: userInterfaceStyle)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.discoverSettings, for: indexPath) as! DiscoverSettingsTableViewCell
        
        switch indexPath.row {
        case discoverSettingsGenresRowNumber:
            cell.header = CinePickerCaptions.genres
            cell.iconString = "film"
            
            if !selectedGenres.isEmpty {
                cell.info = String(selectedGenres.count)
            }
        case discoverSettingsYearRowNumber:
            cell.header = CinePickerCaptions.year
            cell.iconString = "calendar-o"
            cell.info = selectedYear?.label
        case discoverSettingsRatingRowNumber:
            cell.header = CinePickerCaptions.rating
            cell.iconString = "star-half-o"
            
            if let selectedRating = selectedRating {
                cell.info = "> \(selectedRating.value)"
            }
        default:
            fatalError("Discover settings cell is out of range...")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.discoverSettings, for: indexPath)
        let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
        
        performSegue(withIdentifier: SegueIdentifiers.showDiscoverItemsToSelect, sender: sender)
    }
    
}

extension DiscoverSettingsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showRequestedMovies {
            let requestedMoviesController = segue.destination as! RequestedMoviesViewController
            
            requestedMoviesController.title = CinePickerCaptions.discoverResults
            
            requestedMoviesController.requestMovies = { (requestedPage, callback) in
                let discoveredMovieRequest = DiscoveredMovieRequest(
                    genreIds: self.selectedGenres.map { $0.id },
                    year: self.selectedYear != nil ? String(self.selectedYear!.value) : nil,
                    rating: self.selectedRating?.value,
                    page: requestedPage
                )

                self.discoverSettingsService.requestDiscoveredMovies(request: discoveredMovieRequest) { (_, requestedMoviesResult) in
                    callback(requestedMoviesResult)
                }
            }
            
            return
        }
        
        if segueIdentifier == SegueIdentifiers.showDiscoverItemsToSelect {
            let movieListViewController = segue.destination as! DiscoverSettingsItemsToSelectViewController
            
            let sender = sender as! TableViewCellSender
            let indexPath = sender.indexPath
            
            switch indexPath.row {
            case discoverSettingsGenresRowNumber:
                movieListViewController.title = CinePickerCaptions.genres
                movieListViewController.itemsToSelect = genres
                movieListViewController.selectedItems = selectedGenres
                movieListViewController.allowsMultipleSelection = true
            case discoverSettingsYearRowNumber:
                movieListViewController.title = CinePickerCaptions.year
                movieListViewController.itemsToSelect = years
                movieListViewController.selectedItems = selectedYear != nil ? [selectedYear!] : []
            case discoverSettingsRatingRowNumber:
                movieListViewController.title = CinePickerCaptions.rating
                movieListViewController.itemsToSelect = ratings
                movieListViewController.selectedItems = selectedRating != nil ? [selectedRating!] : []
            default:
                fatalError("Discover settings cell is out of range...")
            }
            
            movieListViewController.onViewWillDisappear = { (selectedItems) in
                switch indexPath.row {
                case self.discoverSettingsGenresRowNumber:
                    self.selectedGenres = selectedItems as! [Genre]
                case self.discoverSettingsYearRowNumber:
                    let items = selectedItems as! [NumericDiscoverSettingsItemToSelect]
                    self.selectedYear = items.first
                case self.discoverSettingsRatingRowNumber:
                    let items = selectedItems as! [NumericDiscoverSettingsItemToSelect]
                    self.selectedRating = items.first
                default:
                    fatalError("Discover settings cell is out of range...")
                }
            }
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
