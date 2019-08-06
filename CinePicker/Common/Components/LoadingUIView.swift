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
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        loadingActivityIndicator.color = CinePickerColors.activityIndicatorColor
        messageLabel.textColor = CinePickerColors.messageColor
    }
    
}
