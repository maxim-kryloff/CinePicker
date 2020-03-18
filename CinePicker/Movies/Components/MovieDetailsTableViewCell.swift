import UIKit

class MovieDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImageImageView: UIImageView!
    
    @IBOutlet weak var movieImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var originalTitleLabel: UILabel!
    
    @IBOutlet weak var genresLabel: UILabel!
    
    @IBOutlet weak var releaseYearLabel: UILabel!
    
    @IBOutlet weak var runtimeLabel: UILabel!
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    @IBOutlet weak var voteSeparatorLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    public static var standardHeight: CGFloat {
        return 120
    }
    
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
    
    public var runtime: Int? {
        didSet {
            if let runtime = runtime {
                runtimeLabel.text = "\(runtime) \(CinePickerCaptions.min)"
                return
            }
            runtimeLabel.text = nil
        }
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
                ratingLabel.textColor = UIViewUtils.getMovieRatingColor(rating: rating)
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
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        movieImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        titleLabel.textColor = CinePickerColors.getTitleColor()
        originalTitleLabel.textColor = CinePickerColors.getSubtitleColor()
        genresLabel.textColor = CinePickerColors.getGenresColor()
        releaseYearLabel.textColor = CinePickerColors.getReleaseYearColor()
        runtimeLabel.textColor = CinePickerColors.getRuntimeColor()
        voteCountLabel.textColor = CinePickerColors.getVoteCountColor()
        voteSeparatorLabel.textColor = CinePickerColors.getVoteSeparatorColor()
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
    
    private func setDefaultPropertyValues() {
        imageValue = defaultImage
        imagePath = ""
        onTapImageView = nil
        title = nil
        originalTitle = nil
        genres = nil
        releaseYear = nil
        runtime = nil
        voteCount = nil
        rating = nil
    }
}

extension MovieDetailsTableViewCell: ImageFromInternetViewCell {
    
    var imageFromInternetImageView: UIImageView {
        return movieImageImageView
    }
    
    var activityIndicatorView: UIActivityIndicatorView {
        return movieImageActivityIndicator
    }
}
