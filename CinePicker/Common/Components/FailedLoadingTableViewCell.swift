import UIKit

class FailedLoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        setCaptions()
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
}
