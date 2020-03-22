import UIKit

class MovieCollectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    public var imageValue: UIImage? {
        didSet {
            movieImageImageView.image = imageValue
        }
    }
    
    var imagePath: String {
        get { return _imagePath }
        set { _imagePath = newValue }
    }
    
    private var _imagePath: String!
    
    public var defaultImage: UIImage {
        return UIImage(named: "default_movie_image")!
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultState()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        setImageViewProperties()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        movieImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
    }
    
    private func setImageViewProperties() {
        movieImageImageView.layer.cornerRadius = CinePickerDimensions.cornerRadius
        movieImageImageView.clipsToBounds = true
    }
    
    private func setDefaultPropertyValues() {
        imageValue = defaultImage
        imagePath = ""
    }
}

extension MovieCollectionCollectionViewCell: ImageFromInternetViewCell {
    
    var imageFromInternetImageView: UIImageView {
        return movieImageImageView
    }
    
    var activityIndicatorView: UIActivityIndicatorView {
        return movieImageActivityIndicator
    }
}
