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
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        messageLabel.textColor = CinePickerColors.getMessageColor(userInterfaceStyle: userInterfaceStyle)
    }
    
}
