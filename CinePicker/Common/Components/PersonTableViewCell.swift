import UIKit

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var personImageImageView: UIImageView!
    
    @IBOutlet weak var personImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var personNameLabel: UILabel!
    
    @IBOutlet weak var personPositionLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    public var imageValue: UIImage? {
        didSet {
            personImageImageView.image = imageValue
        }
    }
    
    public var imagePath: String {
        get { return _imagePath }
        set { _imagePath = newValue }
    }
    
    private var _imagePath: String!
    
    public var defaultImage: UIImage {
        return UIImage(named: "default_person_image")!
    }
    
    public var onTapImageView: ((String) -> Void)?
    
    public var personName: String? {
        didSet {
            personNameLabel.text = personName
        }
    }
    
    public var personPosition: String? {
        didSet {
            personPositionLabel.text = personPosition
        }
    }
    
    public var personPositionIsValid: Bool? {
        didSet {
            personPositionLabel.textColor = (personPositionIsValid ?? true)
                ? CinePickerColors.getSubtitleColor()
                : CinePickerColors.getTextNegativeColor()
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
        personImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        personNameLabel.textColor = CinePickerColors.getTitleColor()
        personPositionLabel.textColor = CinePickerColors.getSubtitleColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }
    
    private func setImageViewGesture() {
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        personImageImageView.gestureRecognizers = nil
        personImageImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        personImageImageView.isUserInteractionEnabled = false
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
        personName = nil
        personPosition = nil
        personPositionIsValid = nil
    }
}

extension PersonTableViewCell: ImageFromInternetViewCell {
    
    var imageFromInternetImageView: UIImageView {
        return personImageImageView
    }
    
    var activityIndicatorView: UIActivityIndicatorView {
        return personImageActivityIndicator
    }
}
