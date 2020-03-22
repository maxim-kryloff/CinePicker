import UIKit
import LGButton

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerButton: UIButton!
    
    @IBOutlet weak var rightArrowLGButton: LGButton!
    
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
        headerButton.setTitleColor(CinePickerColors.getActionColor(), for: .normal)
        rightArrowLGButton.rightIconColor = CinePickerColors.getActionColor()
    }
    
    private func setDefaultPropertyValues() {
        header = nil
    }
}
