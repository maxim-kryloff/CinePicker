import UIKit
import LGButton

class DiscoverSettingsItemsToSelectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var selectedLGButton: LGButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 50
    }
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
    public var isItemSelected: Bool? {
        didSet {
            if let isItemSelected = isItemSelected {
                selectedLGButton.isHidden = !isItemSelected
                return
            }
            
            selectedLGButton.isHidden = true
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
        
        header = nil
        isItemSelected = nil
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        headerLabel.textColor = CinePickerColors.getTitleColor(userInterfaceStyle: userInterfaceStyle)
        selectedLGButton.rightIconColor = CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle)
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }
    
}
