import UIKit
import LGButton

class DiscoverSettingsViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var discoverSettingsTableView: UITableView!
    
    @IBOutlet weak var searchLGButton: LGButton!
    
    private var loadingView: LoadingUIView!
    
    private var failedLoadingView: FailedLoadingUIView!
    
    private let numberOfRows: Int = 3
    
    private let discoverSettingsGenresRowNumber: Int = 0
    
    private let discoverSettingsYearRowNumber: Int = 1
    
    private let discoverSettingsRatingRowNumber: Int = 2
    
    fileprivate var genres: [Genre] = []
    
    fileprivate var selectedGenres: [Genre] = []
    
    fileprivate var years: [NumericDiscoverSettingsItemToSelect] = {
        var years: [NumericDiscoverSettingsItemToSelect] = []
        let currentYear: Int = Calendar.current.component(.year, from: Date())
        for value in 1900...currentYear {
            let year = NumericDiscoverSettingsItemToSelect(value: Double(value), label: String(value))
            years.append(year)
        }
        return years.reversed()
    }()
    
    fileprivate var selectedYear: NumericDiscoverSettingsItemToSelect?
    
    fileprivate var ratings: [NumericDiscoverSettingsItemToSelect] = {
        let ratings: [NumericDiscoverSettingsItemToSelect] = [
            NumericDiscoverSettingsItemToSelect(value: 6.5, label: "6.5 - \(CinePickerCaptions.high)"),
            NumericDiscoverSettingsItemToSelect(value: 5.0, label: "5.0 - \(CinePickerCaptions.medium)"),
            NumericDiscoverSettingsItemToSelect(value: 0.0, label: "0.0 - \(CinePickerCaptions.lowNone)")
        ]
        return ratings
    }()
    
    fileprivate var selectedRating: NumericDiscoverSettingsItemToSelect?
    
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
        registerDiscoverSettingsTableViewCell()
        defineSearchLGButton()
        setDefaultColors()
        performRequest()
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
    }
    
    private func defineLoadingView() {
        loadingView = UIViewUtilsFactory.shared.getViewUtils().getLoadingView(for: discoverSettingsTableView)
    }
    
    private func defineFailedLoadingView() {
        failedLoadingView = UIViewUtilsFactory.shared.getViewUtils()
            .getFailedLoadingView(for: discoverSettingsTableView, onTouchDown: onReloadGettingGenres)
    }
    
    private func defineTableView() {
        discoverSettingsTableView.rowHeight = DiscoverSettingsTableViewCell.standardHeight
        discoverSettingsTableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func registerDiscoverSettingsTableViewCell() {
        let discoverSettingsTableViewCellNib = UINib(nibName: "DiscoverSettingsTableViewCell", bundle: nil)
        discoverSettingsTableView.register(discoverSettingsTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.discoverSettings)
    }
    
    private func defineSearchLGButton() {
        searchLGButton.titleString = CinePickerCaptions.search
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        discoverSettingsTableView.backgroundColor = CinePickerColors.getBackgroundColor()
        searchLGButton.bgColor = CinePickerColors.getActionColor()
        searchLGButton.titleColor = CinePickerColors.getBackgroundColor()
    }
    
    private func performRequest() {
        setLoadingState()
        discoverSettingsService.requestGenres { (requestedGenres) in
            OperationQueue.main.addOperation {
                guard let requestedGenres = requestedGenres else {
                    self.setFailedLoadingState()
                    return
                }
                self.unsetLoadingState()
                self.genres = requestedGenres
                self.discoverSettingsTableView.reloadData()
            }
        }
    }
    
    private func setLoadingState() {
        discoverSettingsTableView.backgroundView = loadingView
        searchLGButton.isHidden = true
    }
    
    private func setFailedLoadingState() {
        self.discoverSettingsTableView.backgroundView = self.failedLoadingView
    }
    
    private func unsetLoadingState() {
        self.discoverSettingsTableView.backgroundView = nil
        self.searchLGButton.isHidden = false
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
        let view = createHeaderView(for: tableView)
        return view
    }
    
    private func createHeaderView(for tableView: UITableView) -> HeaderUIView {
        let view = UIViewUtilsFactory.shared.getViewUtils().getHeaderView(for: tableView)
        view.header = CinePickerCaptions.discover
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectedBackgroundView = UIViewUtilsFactory.shared.getViewUtils()
            .getUITableViewCellSelectedBackgroundView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.discoverSettings, for: indexPath) as! DiscoverSettingsTableViewCell
        getCellUtilsFactory(by: indexPath.row, controller: self).setDiscoverySettingsTableViewCellProperties(cell: cell)
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
            prepareRequestedMoviesViewController(for: segue)
            return
        }
        if segueIdentifier == SegueIdentifiers.showDiscoverItemsToSelect {
            prepareItemsToSelectViewController(for: segue, sender: sender)
            return
        }
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
    private func prepareRequestedMoviesViewController(for segue: UIStoryboardSegue) {
        let requestedMoviesController = segue.destination as! RequestedMoviesViewController
        requestedMoviesController.title = CinePickerCaptions.discoverResults
        requestedMoviesController.requestMovies = { (requestedPage, callback) in
            let requestToDiscoverMovies = RequestToDiscoverMovies(
                genreIds: self.selectedGenres.map { $0.id },
                year: self.selectedYear != nil ? String(self.selectedYear!.value) : nil,
                rating: self.selectedRating?.value,
                page: requestedPage
            )
            self.discoverSettingsService.requestDiscoveredMovies(request: requestToDiscoverMovies) { (_, requestedMoviesResult) in
                callback(requestedMoviesResult)
            }
        }
    }
    
    private func prepareItemsToSelectViewController(for segue: UIStoryboardSegue, sender: Any?) {
        let movieListViewController = segue.destination as! DiscoverSettingsItemsToSelectViewController
        let sender = sender as! TableViewCellSender
        let cellUtilsFactory = getCellUtilsFactory(by: sender.indexPath.row, controller: self)
        cellUtilsFactory.setItemsToSelectViewControllerProperties(movieListViewController)
        movieListViewController.onViewWillDisappear = { (selectedItems) in
            cellUtilsFactory.setDiscoverSettingsViewControllerSelectedItems(selectedItems: selectedItems)
        }
    }
}

extension DiscoverSettingsViewController {
    
    private func getCellUtilsFactory(by rowNumber: Int, controller: DiscoverSettingsViewController) -> CellUtilsAbstractFactory {
        switch rowNumber {
            case discoverSettingsGenresRowNumber:
                return GenresCellUtilsFactory.getShared(controller: self)
            case discoverSettingsYearRowNumber:
                return YearCellUtilsFactory.getShared(controller: self)
            case discoverSettingsRatingRowNumber:
                return RatingCellUtilsFactory.getShared(controller: self)
            default:
                fatalError("Discover settings cell is out of range...")
        }
    }
    
    private class CellUtilsAbstractFactory {
        
        public let discoverSettingsViewController: DiscoverSettingsViewController
        
        init(discoverSettingsViewController: DiscoverSettingsViewController) {
            self.discoverSettingsViewController = discoverSettingsViewController
        }
        
        public func setDiscoverySettingsTableViewCellProperties(cell: DiscoverSettingsTableViewCell) { }
        
        public func setItemsToSelectViewControllerProperties(_ controller: DiscoverSettingsItemsToSelectViewController) { }
        
        public func setDiscoverSettingsViewControllerSelectedItems(selectedItems: [DiscoverSettingsItemToSelect]) { }
    }
    
    private class GenresCellUtilsFactory: CellUtilsAbstractFactory {
        
        private static var instance: CellUtilsAbstractFactory?
        
        public static func getShared(controller: DiscoverSettingsViewController) -> CellUtilsAbstractFactory {
            if (instance == nil) {
                instance = GenresCellUtilsFactory(discoverSettingsViewController: controller)
            }
            return instance!
        }
        
        override func setDiscoverySettingsTableViewCellProperties(cell: DiscoverSettingsTableViewCell) {
            cell.header = CinePickerCaptions.genres
            cell.iconString = "film"
            if !discoverSettingsViewController.selectedGenres.isEmpty {
                cell.info = String(discoverSettingsViewController.selectedGenres.count)
            }
        }
        
        override func setItemsToSelectViewControllerProperties(_ controller: DiscoverSettingsItemsToSelectViewController) {
            controller.title = CinePickerCaptions.genres
            controller.itemsToSelect = discoverSettingsViewController.genres
            controller.selectedItems = discoverSettingsViewController.selectedGenres
            controller.allowsMultipleSelection = true
        }
        
        override func setDiscoverSettingsViewControllerSelectedItems(selectedItems: [DiscoverSettingsItemToSelect]) {
            discoverSettingsViewController.selectedGenres = selectedItems as! [Genre]
        }
    }
    
    private class YearCellUtilsFactory: CellUtilsAbstractFactory {
        
        private static var instance: CellUtilsAbstractFactory?
        
        public static func getShared(controller: DiscoverSettingsViewController) -> CellUtilsAbstractFactory {
            if (instance == nil) {
                instance = YearCellUtilsFactory(discoverSettingsViewController: controller)
            }
            return instance!
        }
        
        override func setDiscoverySettingsTableViewCellProperties(cell: DiscoverSettingsTableViewCell) {
            cell.header = CinePickerCaptions.year
            cell.iconString = "calendar-o"
            cell.info = discoverSettingsViewController.selectedYear?.label
        }
        
        override func setItemsToSelectViewControllerProperties(_ controller: DiscoverSettingsItemsToSelectViewController) {
            controller.title = CinePickerCaptions.year
            controller.itemsToSelect = discoverSettingsViewController.years
            controller.selectedItems = discoverSettingsViewController.selectedYear != nil
                ? [discoverSettingsViewController.selectedYear!]
                : []
        }
        
        override func setDiscoverSettingsViewControllerSelectedItems(selectedItems: [DiscoverSettingsItemToSelect]) {
            let items = selectedItems as! [NumericDiscoverSettingsItemToSelect]
            discoverSettingsViewController.selectedYear = items.first
        }
    }
    
    private class RatingCellUtilsFactory: CellUtilsAbstractFactory {
        
        private static var instance: CellUtilsAbstractFactory?
        
        public static func getShared(controller: DiscoverSettingsViewController) -> CellUtilsAbstractFactory {
            if (instance == nil) {
                instance = RatingCellUtilsFactory(discoverSettingsViewController: controller)
            }
            return instance!
        }
        
        override func setDiscoverySettingsTableViewCellProperties(cell: DiscoverSettingsTableViewCell) {
            cell.header = CinePickerCaptions.rating
            cell.iconString = "star-half-o"
            if let selectedRating = discoverSettingsViewController.selectedRating {
                cell.info = "> \(selectedRating.value)"
            }
        }
        
        override func setItemsToSelectViewControllerProperties(_ controller: DiscoverSettingsItemsToSelectViewController) {
            controller.title = CinePickerCaptions.rating
            controller.itemsToSelect = discoverSettingsViewController.ratings
            controller.selectedItems = discoverSettingsViewController.selectedRating != nil
                ? [discoverSettingsViewController.selectedRating!]
                : []
        }
        
        override func setDiscoverSettingsViewControllerSelectedItems(selectedItems: [DiscoverSettingsItemToSelect]) {
            let items = selectedItems as! [NumericDiscoverSettingsItemToSelect]
            discoverSettingsViewController.selectedRating = items.first
        }
    }
}
