import UIKit
import LGButton

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    @IBOutlet weak var releaseYearLabel: UILabel!
    
    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
    @IBOutlet weak var iLikeItLGButton: LGButton!
    
    @IBOutlet weak var voteResultsStackView: UIStackView!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var voteSeparatorLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    
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
    
    public var isWillCheckItOutHidden: Bool {
        set { willCheckItOutLGButton.isHidden = newValue }
        get { return willCheckItOutLGButton.isHidden }
    }
    
    public var isILikeItHidden: Bool {
        set { iLikeItLGButton.isHidden = newValue }
        get { return iLikeItLGButton.isHidden }
    }
    
    public var isVoteResultsHidden: Bool {
        set { voteResultsStackView.isHidden = newValue }
        get { return voteResultsStackView.isHidden }
    }
    
    public var voteCount: Int? {
        didSet {
            if let voteCount = voteCount {
                voteCountLabel.text = String(voteCount)
                return
            }
            
            voteCountLabel.text = "--"
        }
    }
    
    public var rating: Double? {
        didSet {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            
            if let rating = rating {
                ratingLabel.textColor = UIViewHelper.getMovieRatingColor(userInterfaceStyle: userInterfaceStyle, rating: rating)
                ratingLabel.text = String(rating)
                
                return
            }
            
            ratingLabel.textColor = CinePickerColors.getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
            ratingLabel.text = "--"
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
        voteResultsStackView.isHidden = false
        
        title = nil
        originalTitle = nil
        releaseYear = nil
        isWillCheckItOutHidden = true
        isILikeItHidden = true
        voteCount = nil
        rating = nil
        
        onTapImageViewHandler = nil
        
        imageViewAlpha = 1.0
        activityIndicatorAlpha = 0.0
        imageValue = nil
        imagePath = ""
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        movieImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor(userInterfaceStyle: userInterfaceStyle)
        titleLabel.textColor = CinePickerColors.getTitleColor(userInterfaceStyle: userInterfaceStyle)
        originalTitleLabel.textColor = CinePickerColors.getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
        releaseYearLabel.textColor = CinePickerColors.getReleaseYearColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.rightIconColor = CinePickerColors.getWillCheckItOutTagColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.rightIconColor = CinePickerColors.getILikeItTagColor(userInterfaceStyle: userInterfaceStyle)
        voteCountLabel.textColor = CinePickerColors.getVoteCountColor(userInterfaceStyle: userInterfaceStyle)
        voteSeparatorLabel.textColor = CinePickerColors.getVoteSeparatorColor(userInterfaceStyle: userInterfaceStyle)
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
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
