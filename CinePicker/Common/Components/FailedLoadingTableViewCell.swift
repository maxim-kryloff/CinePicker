import UIKit

class FailedLoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        messageLabel.text = CinePickerCaptions.couldntReloadData
        actionButton.setTitle(CinePickerCaptions.reload, for: .normal)
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        messageLabel.textColor = CinePickerColors.getMessageColor(userInterfaceStyle: userInterfaceStyle)
        actionButton.setTitleColor(CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle), for: .normal)
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }

}
