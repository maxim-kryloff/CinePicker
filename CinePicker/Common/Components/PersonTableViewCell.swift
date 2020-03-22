import UIKit

class PersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var personImageImageView: UIImageView!
    
    @IBOutlet weak var personImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var personNameLabel: UILabel!
    
    @IBOutlet weak var personPositionLabel: UILabel!
    
    public static var standardHeight: CGFloat {
        return 88
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
    
    public var originController: UIViewController?
    
    private func onTapImageView() {
        if let originController = originController {
            UIViewUtilsFactory.shared.getImageUtils().openImage(from: originController, by: imagePath)
        }
    }
    
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
        setSelectedBackgroundView()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        setImageViewProperties()
        setImageViewGesture()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        personImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        personNameLabel.textColor = CinePickerColors.getTitleColor()
        personPositionLabel.textColor = CinePickerColors.getSubtitleColor()
    }
    
    private func setImageViewProperties() {
        personImageImageView.layer.cornerRadius = CinePickerDimensions.cornerRadius
        personImageImageView.clipsToBounds = true
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
        onTapImageView()
    }
    
    private func setDefaultPropertyValues() {
        imageValue = defaultImage
        imagePath = ""
        originController = nil
        personName = nil
        personPosition = nil
        personPositionIsValid = nil
    }
    
    private func setSelectedBackgroundView() {
        selectedBackgroundView = UIViewUtilsFactory.shared.getViewUtils().getUITableViewCellSelectedBackgroundView()
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
