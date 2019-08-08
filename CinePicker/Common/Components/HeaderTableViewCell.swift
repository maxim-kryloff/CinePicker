import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var headerButton: UIButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 40
    }
    
    public var header: String? {
        didSet {
            headerButton.setTitle(header, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultColors()
        
        headerButton.setTitle(nil, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        headerButton.setTitle(nil, for: .normal)
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        headerButton.setTitleColor(CinePickerColors.actionColor, for: .normal)
        bottomBarView.backgroundColor = CinePickerColors.bottomBarColor
    }

}
