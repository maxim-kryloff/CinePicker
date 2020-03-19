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
    
    public var imageValue: UIImage? {
        didSet {
            movieImageImageView.image = imageValue
        }
    }
    
    public var imagePath: String {
        get { return _imagePath }
        set { _imagePath = newValue }
    }
    
    private var _imagePath: String!
    
    var defaultImage: UIImage {
        return UIImage(named: "default_movie_image")!
    }
    
    public var onTapImageView: ((String) -> Void)?
    
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
            if let rating = rating {
                ratingLabel.textColor = UIViewUtilsFactory.shared.getViewUtils()
                    .getMovieRatingColor(rating: rating)
                ratingLabel.text = String(rating)
                return
            }
            ratingLabel.textColor = CinePickerColors.getSubtitleColor()
            ratingLabel.text = "--"
        }
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
        setImageViewGesture()
        setDefaultVoteResultsState()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        movieImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        titleLabel.textColor = CinePickerColors.getTitleColor()
        originalTitleLabel.textColor = CinePickerColors.getSubtitleColor()
        releaseYearLabel.textColor = CinePickerColors.getReleaseYearColor()
        willCheckItOutLGButton.rightIconColor = CinePickerColors.getWillCheckItOutTagColor()
        iLikeItLGButton.rightIconColor = CinePickerColors.getILikeItTagColor()
        voteCountLabel.textColor = CinePickerColors.getVoteCountColor()
        voteSeparatorLabel.textColor = CinePickerColors.getVoteSeparatorColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }
    
    private func setImageViewGesture() {
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        movieImageImageView.gestureRecognizers = nil
        movieImageImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        movieImageImageView.isUserInteractionEnabled = false
    }
    
    @objc private func onImageViewTap(tapGestureRecognizer: UITapGestureRecognizer) {
        if !(tapGestureRecognizer.view is UIImageView) {
            return
        }
        if imagePath.isEmpty {
            return
        }
        onTapImageView?(imagePath)
    }
    
    private func setDefaultVoteResultsState() {
        voteResultsStackView.isHidden = false
    }
    
    private func setDefaultPropertyValues() {
        imageValue = defaultImage
        imagePath = ""
        onTapImageView = nil
        title = nil
        originalTitle = nil
        releaseYear = nil
        isWillCheckItOutHidden = true
        isILikeItHidden = true
        voteCount = nil
        rating = nil
    }
}

extension MovieTableViewCell: ImageFromInternetViewCell {
    
    var imageFromInternetImageView: UIImageView {
        return movieImageImageView
    }
    
    var activityIndicatorView: UIActivityIndicatorView {
        return movieImageActivityIndicator
    }
}
