import UIKit

class MessageUIView: UIView {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    public var message: String? {
        didSet {
            messageLabel.text = message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        messageLabel.textColor = CinePickerColors.getMessageColor()
    }
    
    private func setDefaultPropertyValues() {
        message = nil
    }
}
