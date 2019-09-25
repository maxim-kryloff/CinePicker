import UIKit
import LGButton

class DiscoverSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var iconLGButton: LGButton!
    
    @IBOutlet weak var headerButton: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var rightArrowLGButton: LGButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 50
    }
    
    public var iconString: String? {
        didSet {
            iconLGButton.rightIconString = iconString ?? ""
        }
    }
    
    public var header: String? {
        didSet {
            headerButton.setTitle(header, for: .normal)
        }
    }
    
    public var info: String? {
        didSet {
            infoLabel.text = info
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultState()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        
        iconString = nil
        header = nil
        info = nil
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        iconLGButton.rightIconColor = CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle)
        headerButton.setTitleColor(CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle), for: .normal)
        infoLabel.textColor = CinePickerColors.getTitleColor(userInterfaceStyle: userInterfaceStyle)
        rightArrowLGButton.rightIconColor = CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle)
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }
    
}
