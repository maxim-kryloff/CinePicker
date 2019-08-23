import UIKit

class MessageUIView: UIView {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    public var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        message = nil
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        messageLabel.textColor = CinePickerColors.messageColor
    }
    
}
