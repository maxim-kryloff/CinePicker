import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var personImageImageView: UIImageView!
    
    @IBOutlet weak var personImageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var personNameLabel: UILabel!
    
    @IBOutlet weak var personPositionLabel: UILabel!
    
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
            if let isPersonPositionValid = isPersonPositionValid {
                personPositionLabel.textColor = isPersonPositionValid ? UIColor.darkGray : CinePickerColors.red
            }
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
        personImageImageView.image = defaultImage
        
        let imageViewTapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(onImageViewTap(tapGestureRecognizer:))
        )
        
        personImageImageView.gestureRecognizers = nil
        personImageImageView.addGestureRecognizer(imageViewTapGestureRecognizer)
        personImageImageView.isUserInteractionEnabled = false
        personNameLabel.text = nil
        personPositionLabel.text = nil
        personPositionLabel.textColor = UIColor.darkGray
        
        personImageImageView.alpha = 1.0
        personImageActivityIndicator.alpha = 0.0
        
        imagePath = ""

        onTapImageViewHandler = nil
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
