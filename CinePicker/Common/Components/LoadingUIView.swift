import UIKit

class LoadingUIView: UIView {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageLabel.text = CinePickerCaptions.loadingData
    }
    
}
