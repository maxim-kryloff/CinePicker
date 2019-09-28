import UIKit
import LGButton

class HeaderWithTagsUIView: UIView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
    @IBOutlet weak var iLikeItLGButton: LGButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 55
    }
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
    public var isWillCheckItOutSelected: Bool? {
        didSet {
            guard let isWillCheckItOutSelected = isWillCheckItOutSelected else {
                deselectWillCheckItOut()
                return
            }
            
            isWillCheckItOutSelected ? selectWillCheckItOut() : deselectWillCheckItOut()
        }
    }
    
    public var isILikeItSelected: Bool? {
        didSet {
            guard let isILikeItSelected = isILikeItSelected else {
                deselectILikeIt()
                return
            }
            
            isILikeItSelected ? selectILikeIt() : deselectILikeIt()
        }
    }
    
    public var onTapWillCheckItOut: ((_ cell: HeaderWithTagsUIView) -> Void)?
    
    public var onTapILikeIt: ((_ cell: HeaderWithTagsUIView) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultState()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        
        header = nil
        
        isWillCheckItOutSelected = nil
        isILikeItSelected = nil
        
        onTapWillCheckItOut = nil
        onTapILikeIt = nil
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        headerLabel.textColor = CinePickerColors.getTitleColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }
    
    private func selectWillCheckItOut() {
        willCheckItOutLGButton.bgColor = CinePickerColors.getBackgroundColor()
        willCheckItOutLGButton.borderColor = CinePickerColors.getWillCheckItOutTagColor()
        willCheckItOutLGButton.titleColor = CinePickerColors.getWillCheckItOutTagColor()
        willCheckItOutLGButton.rightIconColor = CinePickerColors.getWillCheckItOutTagColor()
    }
    
    private func deselectWillCheckItOut() {
        willCheckItOutLGButton.bgColor = CinePickerColors.getBackgroundColor()
        willCheckItOutLGButton.borderColor = CinePickerColors.getTagColor()
        willCheckItOutLGButton.titleColor = CinePickerColors.getTagColor()
        willCheckItOutLGButton.rightIconColor = CinePickerColors.getTagColor()
    }
    
    private func selectILikeIt() {
        iLikeItLGButton.bgColor = CinePickerColors.getBackgroundColor()
        iLikeItLGButton.borderColor = CinePickerColors.getILikeItTagColor()
        iLikeItLGButton.titleColor = CinePickerColors.getILikeItTagColor()
        iLikeItLGButton.rightIconColor = CinePickerColors.getILikeItTagColor()
    }
    
    private func deselectILikeIt() {
        iLikeItLGButton.bgColor = CinePickerColors.getBackgroundColor()
        iLikeItLGButton.borderColor = CinePickerColors.getTagColor()
        iLikeItLGButton.titleColor = CinePickerColors.getTagColor()
        iLikeItLGButton.rightIconColor = CinePickerColors.getTagColor()
    }
    
    @IBAction func onWillCheckItOutLGButtonTouchUpInside(_ sender: LGButton) {
        onTapWillCheckItOut?(self)
    }
    
    @IBAction func onILikeItLGButtonTouchUpInside(_ sender: LGButton) {
        onTapILikeIt?(self)
    }
    
}
