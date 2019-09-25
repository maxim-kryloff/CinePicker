import UIKit

class LoadingUIView: UIView {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        messageLabel.text = CinePickerCaptions.loadingData
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        loadingActivityIndicator.color = CinePickerColors.getActivityIndicatorColor(userInterfaceStyle: userInterfaceStyle)
        messageLabel.textColor = CinePickerColors.getMessageColor(userInterfaceStyle: userInterfaceStyle)
    }
    
}
