import UIKit
import LGButton

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentUIView: UIView!
    
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
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        headerButton.setTitleColor(CinePickerColors.actionColor, for: .normal)
        rightArrowLGButton.rightIconColor = CinePickerColors.actionColor
        bottomBarView.backgroundColor = CinePickerColors.bottomBarColor
    }

}
