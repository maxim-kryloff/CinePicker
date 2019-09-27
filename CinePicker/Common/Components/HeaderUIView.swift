import UIKit

class HeaderUIView: UIView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 55
    }
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultState()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        
        header = nil
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        headerLabel.textColor = CinePickerColors.getTitleColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }
    
}
