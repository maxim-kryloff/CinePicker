import UIKit
import LGButton

class DiscoverSettingsItemsToSelectTableViewCell: UITableViewCell {
    
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
    
    public var itemIsSelected: Bool? {
        didSet {
            if let itemIsSelected = itemIsSelected {
                selectedLGButton.isHidden = !itemIsSelected
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
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        headerLabel.textColor = CinePickerColors.getTitleColor()
        selectedLGButton.rightIconColor = CinePickerColors.getActionColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }
    
    private func setDefaultPropertyValues() {
        header = nil
        itemIsSelected = nil
    }
}
