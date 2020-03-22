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
    
    public static var standardHeight: CGFloat {
        return 88
    }
    
    public static func setMovieDetailsViewControllerProperties(for segue: UIStoryboardSegue, movie: Movie) {
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movieId = movie.id
        movieDetailsViewController.movieTitle = movie.title
    }
    
    public var movie: Movie? {
        didSet {
            title = movie?.title
            originalTitle = movie?.originalTitle
            releaseYear = movie?.releaseYear
            voteCount = movie?.voteCount
            rating = movie?.rating
        }
    }
    
    public var savedMovie: SavedMovie? {
        didSet {
            willCheckItOutIsVisible = savedMovie?.containsTag(byName: .willCheckItOut) ?? false
            iLikeItIsVisible = savedMovie?.containsTag(byName: .iLikeIt) ?? false
        }
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
    
    public var originController: UIViewController?
    
    private func onTapImageView() {
        if let originController = originController {
            UIViewUtilsFactory.shared.getImageUtils().openImage(from: originController, by: imagePath)
        }
    }
    
    public var voteResultsAreHidden: Bool {
        set { voteResultsStackView.isHidden = newValue }
        get { return voteResultsStackView.isHidden }
    }
    
    private var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private var originalTitle: String? {
        didSet {
            originalTitleLabel.text = originalTitle
        }
    }
    
    private var releaseYear: String? {
        didSet {
            releaseYearLabel.text = releaseYear
        }
    }
    
    private var willCheckItOutIsVisible: Bool {
        set { willCheckItOutLGButton.isHidden = !newValue }
        get { return willCheckItOutLGButton.isHidden }
    }
    
    private var iLikeItIsVisible: Bool {
        set { iLikeItLGButton.isHidden = !newValue }
        get { return iLikeItLGButton.isHidden }
    }
    
    private var voteCount: Int? {
        didSet {
            if let voteCount = voteCount {
                voteCountLabel.text = String(voteCount)
                return
            }
            voteCountLabel.text = "--"
        }
    }
    
    private var rating: Double? {
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
        setSelectedBackgroundView()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        setImageViewProperties()
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
    }
    
    private func setImageViewProperties() {
        movieImageImageView.layer.cornerRadius = CinePickerDimensions.cornerRadius
        movieImageImageView.clipsToBounds = true
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
        onTapImageView()
    }
    
    private func setDefaultVoteResultsState() {
        voteResultsStackView.isHidden = false
    }
    
    private func setDefaultPropertyValues() {
        movie = nil
        savedMovie = nil
        imageValue = defaultImage
        imagePath = ""
        originController = nil
        title = nil
        originalTitle = nil
        releaseYear = nil
        willCheckItOutIsVisible = false
        iLikeItIsVisible = false
        voteCount = nil
        rating = nil
    }
    
    private func setSelectedBackgroundView() {
        selectedBackgroundView = UIViewUtilsFactory.shared.getViewUtils().getUITableViewCellSelectedBackgroundView()
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
