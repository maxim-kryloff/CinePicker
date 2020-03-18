import UIKit

class LoadingUIView: UIView {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        setCaptions()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        loadingActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        messageLabel.textColor = CinePickerColors.getMessageColor()
    }
    
    private func setCaptions() {
        messageLabel.text = CinePickerCaptions.loadingData
    }
}
