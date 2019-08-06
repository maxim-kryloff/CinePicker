import UIKit

class MovieDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    @IBOutlet weak var genresLabel: UILabel!
    
    @IBOutlet weak var releaseYearLabel: UILabel!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var voteSeparatorLabel: UILabel!
    
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
    
    public var onTapImageViewHandler: ((String) -> Void)?
    
    private var _imagePath: String!
    
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
        setDefaultColors()
        
        movieImageImageView.image = defaultImage
        
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        
        movieImageImageView.gestureRecognizers = nil
        movieImageImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        movieImageImageView.isUserInteractionEnabled = false
        titleLabel.text = nil
        originalTitleLabel.text = nil
        genresLabel.text = nil
        releaseYearLabel.text = nil
        voteCountLabel.text = "--"
        ratingLabel.text = "--"
        
        movieImageImageView.alpha = 1.0
        movieImageActivityIndicator.alpha = 0.0

        imagePath = ""

        onTapImageViewHandler = nil
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        movieImageActivityIndicator.color = CinePickerColors.activityIndicatorColor
        titleLabel.textColor = CinePickerColors.titleColor
        originalTitleLabel.textColor = CinePickerColors.subtitleColor
        genresLabel.textColor = CinePickerColors.genresColor
        releaseYearLabel.textColor = CinePickerColors.releaseYearColor
        voteCountLabel.textColor = CinePickerColors.voteCountColor
        voteSeparatorLabel.textColor = CinePickerColors.voteSeparatorColor
    }
    
    @objc private func onImageViewTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if !(tapGestureRecognizer.view is UIImageView) {
            return
        }
        
        if imagePath.isEmpty {
            return
        }
        
        onTapImageViewHandler?(imagePath)
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
    
    var imageValue: UIImage? {
        get {
            return movieImageImageView.image
        }
        
        set {
            movieImageImageView.isUserInteractionEnabled = newValue != nil
            movieImageImageView.image = newValue ?? defaultImage
        }
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
