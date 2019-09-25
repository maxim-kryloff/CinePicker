import UIKit

class FailedLoadingUIView: UIView {
    
    @IBOutlet weak var contentUIView: UIView!
    
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
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        messageLabel.textColor = CinePickerColors.getMessageColor(userInterfaceStyle: userInterfaceStyle)
        actionButton.setTitleColor(CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle), for: .normal)
    }
    
}
