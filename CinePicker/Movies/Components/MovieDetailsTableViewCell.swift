import UIKit

class MovieDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    @IBOutlet weak var genresLabel: UILabel!
    
    @IBOutlet weak var releaseYearLabel: UILabel!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    public static var standardHeight: CGFloat {
        return 120
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
    
    public var genres: [Genre]? {
        didSet {
            if let genres = genres {
                let genreNames: [String] = genres.map { $0.name }
                genresLabel.text = genreNames.joined(separator: ", ")
            }
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
    
    private var _originalImageUrl: URL?
    
    private var _originalImageValue: UIImage?
    
    private let defaultImage = UIImage(named: "default_movie_image")
    
    private var imageViewGestureRecognizer: UITapGestureRecognizer!
    
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
        
        if let imageViewGestureRecognizer = imageViewGestureRecognizer {
            movieImageImageView.removeGestureRecognizer(imageViewGestureRecognizer)
        }
        
        movieImageImageView.isUserInteractionEnabled = false
        titleLabel.text = nil
        originalTitleLabel.text = nil
        genresLabel.text = nil
        releaseYearLabel.text = nil
        voteCountLabel.text = "--"
        ratingLabel.text = "--"
        
        movieImageImageView.alpha = 1.0
        movieImageActivityIndicator.alpha = 0.0
        
        imageUrl = nil
        originalImageUrl = nil
        originalImageValue = nil
        
        imageViewGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        
        onTapImageViewHandler = nil
    }
    
    @objc private func onImageViewTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if !(tapGestureRecognizer.view is UIImageView) {
            return
        }
        
        guard let originalImageValue = originalImageValue else {
            return
        }
        
        onTapImageViewHandler?(originalImageValue)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension MovieDetailsTableViewCell: ImageFromInternet {
    
    var imageViewAlpha: CGFloat {
        get { return movieImageImageView.alpha }
        set { movieImageImageView.alpha = newValue }
    }
    
    var activityIndicatorAlpha: CGFloat {
        get { return movieImageActivityIndicator.alpha }
        set { movieImageActivityIndicator.alpha = newValue }
    }
    
    public var imageValue: UIImage? {
        get { return movieImageImageView.image }
        set { movieImageImageView.image = newValue ?? defaultImage }
    }
    
    var originalImageValue: UIImage? {
        get { return _originalImageValue }
        set { _originalImageValue = newValue }
    }
    
    public var imageUrl: URL? {
        get { return _imageUrl }
        set { _imageUrl = newValue }
    }
    
    var originalImageUrl: URL? {
        get {
            return _originalImageUrl
        }
        
        set {
            if let newValue = newValue {
                movieImageImageView.addGestureRecognizer(imageViewGestureRecognizer)
                movieImageImageView.isUserInteractionEnabled = true
                
                _originalImageUrl = newValue
            }
        }
    }
    
    func activityIndicatorStartAnimating() {
        movieImageActivityIndicator.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        movieImageActivityIndicator.stopAnimating()
    }
    
}
