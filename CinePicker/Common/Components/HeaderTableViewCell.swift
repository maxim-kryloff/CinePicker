import UIKit
import LGButton

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerButton: UIButton!
    
    @IBOutlet weak var rightArrowLGButton: LGButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 50
    }
    
    public var header: String? {
        didSet {
            headerButton.setTitle(header, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultColors()
        
        header = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        header = nil
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        headerButton.setTitleColor(CinePickerColors.getActionColor(), for: .normal)
        rightArrowLGButton.rightIconColor = CinePickerColors.getActionColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }

}
