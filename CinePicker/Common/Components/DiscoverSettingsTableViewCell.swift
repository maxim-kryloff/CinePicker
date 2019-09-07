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
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        iconLGButton.rightIconColor = CinePickerColors.actionColor
        headerButton.setTitleColor(CinePickerColors.actionColor, for: .normal)
        infoLabel.textColor = CinePickerColors.titleColor
        rightArrowLGButton.rightIconColor = CinePickerColors.actionColor
        bottomBarView.backgroundColor = CinePickerColors.bottomBarColor
    }
    
}
