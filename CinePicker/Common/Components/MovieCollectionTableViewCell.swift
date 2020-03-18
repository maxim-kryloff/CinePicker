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
        let cellAdapter = ImageFromInternetViewCellAdapter(cell: cell)
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cellAdapter)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = CollectionViewCellIdentifiers.movieCollection
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MovieCollectionCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movieCollection[indexPath.row]
        onTouchDown?(movie)
    }
}
