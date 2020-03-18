import UIKit

class MovieCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieCollectionCollectionView: UICollectionView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 158
    }
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
    public var movieCollection: [Movie] = [] {
        didSet {
            movieCollectionCollectionView.reloadData()
        }
    }
    
    public var onTouchDown: ((_ movie: Movie) -> Void)?
    
    private var downloadedImages: [String: UIImage] = [:]
    
    private let imageService = ImageService()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultState()
        registerMovieCollectionCollectionViewCell()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        movieCollectionCollectionView.backgroundColor = CinePickerColors.getBackgroundColor()
        headerLabel.textColor = CinePickerColors.getTitleColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }
    
    private func setDefaultPropertyValues() {
        header = nil
        movieCollection = []
        onTouchDown = nil
        downloadedImages = [:]
    }
    
    private func registerMovieCollectionCollectionViewCell() {
        let movieCollectionCollectionViewCellNib = UINib(nibName: "MovieCollectionCollectionViewCell", bundle: nil)
        movieCollectionCollectionView.register(movieCollectionCollectionViewCellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.movieCollection)
    }
}

extension MovieCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var cell = cell as! ImageFromInternetViewCell
        cell.imagePath = movieCollection[indexPath.row].imagePath
        if downloadedImages[cell.imagePath] != nil {
            return
        }
        setImageFromInternet(at: cell)
    }
    
    func setImageFromInternet(at cell: ImageFromInternetViewCell) {
        let cellAdapter = ImageFromInternetViewCellAdapter(cell: cell)
        UIViewUtils.setImageFromInternet(at: cellAdapter, downloadedBy: imageService) { (image) in
            self.downloadedImages[cell.imagePath] = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueMovieCollectionCollectionViewCell(from: collectionView, at: indexPath)
        let movie = movieCollection[indexPath.row]
        if let image = downloadedImages[movie.imagePath] {
            cell.imageValue = image
        }
        return cell
    }
    
    func dequeueMovieCollectionCollectionViewCell(from collectionView: UICollectionView, at indexPath: IndexPath) -> MovieCollectionCollectionViewCell {
        let identifier = CollectionViewCellIdentifiers.movieCollection
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MovieCollectionCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MovieCollectionCollectionViewCell
        if let imageUrl = UIViewUtils.buildImageUrl(by: cell.imagePath) {
            imageService.cancelDownloading(by: imageUrl)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadedImages = [:]
        let movie = movieCollection[indexPath.row]
        onTouchDown?(movie)
    }
}

