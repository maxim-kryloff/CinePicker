import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    @IBOutlet weak var releaseYearLabel: UILabel!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var originalTitle: String? {
        didSet {
            originalTitleLabel.text = originalTitle
        }
    }
    
    public var releaseYear: String? {
        didSet {
            releaseYearLabel.text = releaseYear
        }
    }
    
    public var voteCount: Int? {
        didSet {
            if let voteCount = voteCount {
                voteCountLabel.text = String(voteCount)
            }
        }
    }
    
    public var rating: Double? {
        didSet {
            if let rating = rating {
                ratingLabel.textColor = UIViewHelper.getMovieRatingColor(rating: rating)
                ratingLabel.text = String(rating)
            }
        }
    }
    
    public var onTapImageViewHandler: ((UIImage) -> Void)?
    
    private var _imageUrl: URL?
    
    private let defaultImage = UIImage(named: "default_movie_image")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultState()
    }
    
    private func setDefaultState() {
        movieImageImageView.image = defaultImage
        
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        
        movieImageImageView.gestureRecognizers = nil
        movieImageImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        movieImageImageView.isUserInteractionEnabled = false
        titleLabel.text = nil
        originalTitleLabel.text = nil
        releaseYearLabel.text = nil
        voteCountLabel.text = "--"
        ratingLabel.text = "--"
        
        movieImageImageView.alpha = 1.0
        movieImageActivityIndicator.alpha = 0.0
        
        imageUrl = nil
        
        onTapImageViewHandler = nil
    }
    
    @objc private func onImageViewTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if !(tapGestureRecognizer.view is UIImageView) {
            return
        }
        
        guard let imageValue = imageValue else {
            return
        }
        
        onTapImageViewHandler?(imageValue)
    }
    
}

extension MovieTableViewCell: ImageFromInternet {
    
    var imageViewAlpha: CGFloat {
        get { return movieImageImageView.alpha }
        set { movieImageImageView.alpha = newValue }
    }
    
    var activityIndicatorAlpha: CGFloat {
        get { return movieImageActivityIndicator.alpha }
        set { movieImageActivityIndicator.alpha = newValue }
    }
    
    var imageValue: UIImage? {
        get {
            return movieImageImageView.image
        }
        
        set {
            movieImageImageView.isUserInteractionEnabled = newValue != nil
            movieImageImageView.image = newValue ?? defaultImage
        }
    }
    
    var imageUrl: URL? {
        get { return _imageUrl }
        set { _imageUrl = newValue }
    }
    
    func activityIndicatorStartAnimating() {
        movieImageActivityIndicator.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        movieImageActivityIndicator.stopAnimating()
    }
    
}
