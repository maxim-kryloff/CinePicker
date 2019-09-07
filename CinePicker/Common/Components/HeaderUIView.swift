import UIKit

class HeaderUIView: UIView {
    
    @IBOutlet weak var contentUIView: UIView!
    
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
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        headerLabel.textColor = CinePickerColors.titleColor
        bottomBarView.backgroundColor = CinePickerColors.bottomBarColor
    }
    
}
