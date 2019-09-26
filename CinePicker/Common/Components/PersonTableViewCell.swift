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
    
    public var isPersonPositionValid: Bool? {
        didSet {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            
            personPositionLabel.textColor = (isPersonPositionValid ?? true)
                ? CinePickerColors.getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
                : CinePickerColors.getTextNegativeColor(userInterfaceStyle: userInterfaceStyle)
        }
    }
    
    public var onTapImageViewHandler: ((String) -> Void)?
    
    private var _imagePath: String!
    
    private let defaultImage = UIImage(named: "default_person_image")
    
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
        
        personImageImageView.image = defaultImage
        
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        
        personImageImageView.gestureRecognizers = nil
        personImageImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        personImageImageView.isUserInteractionEnabled = false
        
        personName = nil
        personPosition = nil
        isPersonPositionValid = nil
        
        onTapImageViewHandler = nil
        
        imageViewAlpha = 1.0
        activityIndicatorAlpha = 0.0
        imageValue = nil
        imagePath = ""
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        personImageActivityIndicator.color = CinePickerColors.getActivityIndicatorColor(userInterfaceStyle: userInterfaceStyle)
        personNameLabel.textColor = CinePickerColors.getTitleColor(userInterfaceStyle: userInterfaceStyle)
        personPositionLabel.textColor = CinePickerColors.getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
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

extension PersonTableViewCell: ImageFromInternet {
    
    var imageViewAlpha: CGFloat {
        get { return personImageImageView.alpha }
        set { personImageImageView.alpha = newValue }
    }
    
    var activityIndicatorAlpha: CGFloat {
        get { return personImageActivityIndicator.alpha }
        set { personImageActivityIndicator.alpha = newValue }
    }
    
    var imageValue: UIImage? {
        get {
            return personImageImageView.image
        }
        
        set {
            personImageImageView.isUserInteractionEnabled = newValue != nil
            personImageImageView.image = newValue ?? defaultImage
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
        personImageActivityIndicator.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        personImageActivityIndicator.stopAnimating()
    }
    
}
