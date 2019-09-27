import UIKit

class FailedLoadingUIView: UIView {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    public var onTouchDownHandler: (() -> Void)?
    
    @IBAction func onTouchDown(_ sender: UIButton) {
        onTouchDownHandler?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        messageLabel.text = CinePickerCaptions.couldntReloadData
        actionButton.setTitle(CinePickerCaptions.reload, for: .normal)
        
        onTouchDownHandler = nil
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        messageLabel.textColor = CinePickerColors.getMessageColor()
        actionButton.setTitleColor(CinePickerColors.getActionColor(), for: .normal)
    }
    
}
