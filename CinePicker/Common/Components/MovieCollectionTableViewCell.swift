import UIKit

class MovieCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieCollectionCollectionView: UICollectionView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    public static var standardHeight: CGFloat {
        return 160
    }
    
    public var header: String? {
        didSet {
            if let header = header {
                headerLabel.text = header
            }
        }
    }
    
    public var movieCollection: [Movie] = [] {
        didSet {
            movieCollectionCollectionView.reloadData()
        }
    }
    
    public var onTouchDownHandler: ((_ movie: Movie) -> Void)?
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let imageService = ImageService()

    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultState()
        
        let movieCollectionCollectionViewCellNib = UINib(nibName: "MovieCollectionCollectionViewCell", bundle: nil)
        movieCollectionCollectionView.register(movieCollectionCollectionViewCellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.movieCollection)
    }
    
    private func setDefaultState() {
        headerLabel.text = nil
        
        movieCollection = []
        loadedImages = [:]
    }
    
}

extension MovieCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let imagePath = movieCollection[indexPath.row].imagePath
        
        if imagePath.isEmpty {
            return
        }
        
        if loadedImages[imagePath] != nil {
            return
        }
        
        var cell = cell as! ImageFromInternet
        
        UIViewHelper.setImageFromInternet(by: imagePath, at: &cell, using: imageService) { (image) in
            self.loadedImages[imagePath] = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = CollectionViewCellIdentifiers.movieCollection
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! MovieCollectionCollectionViewCell
        
        let movie = movieCollection[indexPath.row]
        
        if let image = loadedImages[movie.imagePath] {
            cell.imageValue = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MovieCollectionCollectionViewCell
        
        if let imageUrl = cell.imageUrl {
            imageService.cancelDownloading(for: imageUrl)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadedImages = [:]
        
        let movie = movieCollection[indexPath.row]
        
        onTouchDownHandler?(movie)
    }
    
}

