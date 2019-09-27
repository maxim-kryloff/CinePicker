import UIKit

class LoadingUIView: UIView {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        messageLabel.text = CinePickerCaptions.loadingData
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        loadingActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        messageLabel.textColor = CinePickerColors.getMessageColor()
    }
    
}
