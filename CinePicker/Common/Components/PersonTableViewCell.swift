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
    
    public var onTapImageViewHandler: ((UIImage) -> Void)?
    
    private var _imageUrl: URL?
    
    private var _originalImageUrl: URL?
    
    private var _originalImageValue: UIImage?
    
    private let defaultImage = UIImage(named: "default_person_image")
    
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
        personImageImageView.image = defaultImage
        
        if let imageViewGestureRecognizer = imageViewGestureRecognizer {
            personImageImageView.removeGestureRecognizer(imageViewGestureRecognizer)
        }
        
        personImageImageView.isUserInteractionEnabled = false
        personNameLabel.text = nil
        personPositionLabel.text = nil
        personPositionLabel.textColor = UIColor.darkGray
        
        personImageImageView.alpha = 1.0
        personImageActivityIndicator.alpha = 0.0
        
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
        get { return personImageImageView.image }
        set { personImageImageView.image = newValue ?? defaultImage }
    }
    
    var originalImageValue: UIImage? {
        get {
            return _originalImageValue
        }
        
        set {
            if let newValue = newValue {
                personImageImageView.addGestureRecognizer(imageViewGestureRecognizer)
                personImageImageView.isUserInteractionEnabled = true
                
                _originalImageValue = newValue
            }
        }
    }
    
    var imageUrl: URL? {
        get { return _imageUrl }
        set { _imageUrl = newValue }
    }
    
    var originalImageUrl: URL? {
        get { return _originalImageUrl }
        set { _originalImageUrl = newValue }
    }
    
    func activityIndicatorStartAnimating() {
        personImageActivityIndicator.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        personImageActivityIndicator.stopAnimating()
    }
    
}
