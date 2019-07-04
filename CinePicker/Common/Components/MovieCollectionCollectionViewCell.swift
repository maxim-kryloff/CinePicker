import UIKit

class MovieCollectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    private var _imagePath: String!
    
    private let defaultImage = UIImage(named: "default_movie_image")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movieImageImageView.image = defaultImage
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        movieImageImageView.image = defaultImage
    }

}

extension MovieCollectionCollectionViewCell: ImageFromInternet {
    
    var imageViewAlpha: CGFloat {
        get { return movieImageImageView.alpha }
        set { movieImageImageView.alpha = newValue }
    }
    
    var activityIndicatorAlpha: CGFloat {
        get { return movieImageActivityIndicator.alpha }
        set { movieImageActivityIndicator.alpha = newValue }
    }
    
    var imageValue: UIImage? {
        get { return movieImageImageView.image }
        set { movieImageImageView.image = newValue ?? defaultImage }
    }
    
    var imagePath: String {
        get { return _imagePath }
        set { _imagePath = newValue }
    }
    
    var imageUrl: URL? {
        get {
            if imagePath.isEmpty {
                return nil
            }
            
            return URLBuilder(string: CinePickerConfig.imagePath)
                .append(pathComponent: imagePath)
                .build()
        }
    }
    
    func activityIndicatorStartAnimating() {
        movieImageActivityIndicator.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        movieImageActivityIndicator.stopAnimating()
    }

}
