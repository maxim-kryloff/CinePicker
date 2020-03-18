import UIKit

class FailedLoadingUIView: UIView {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    public var onTouchDown: (() -> Void)?
    
    @IBAction func onTouchDown(_ sender: UIButton) {
        onTouchDown?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        setCaptions()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        messageLabel.textColor = CinePickerColors.getMessageColor()
        actionButton.setTitleColor(CinePickerColors.getActionColor(), for: .normal)
    }
    
    private func setCaptions() {
        messageLabel.text = CinePickerCaptions.couldntReloadData
        actionButton.setTitle(CinePickerCaptions.reload, for: .normal)
    }
    
    private func setDefaultPropertyValues() {
        onTouchDown = nil
    }
}
