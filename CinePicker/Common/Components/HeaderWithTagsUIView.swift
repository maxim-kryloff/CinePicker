import UIKit
import LGButton

class HeaderWithTagsUIView: UIView {
    
    @IBOutlet weak var contentUIView: UIView!
    
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
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        headerLabel.textColor = CinePickerColors.getTitleColor(userInterfaceStyle: userInterfaceStyle)
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    private func selectWillCheckItOut() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        willCheckItOutLGButton.bgColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.borderColor = CinePickerColors.getWillCheckItOutTagColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.titleColor = CinePickerColors.getWillCheckItOutTagColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.rightIconColor = CinePickerColors.getWillCheckItOutTagColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    private func deselectWillCheckItOut() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        willCheckItOutLGButton.bgColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.borderColor = CinePickerColors.getTagColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.titleColor = CinePickerColors.getTagColor(userInterfaceStyle: userInterfaceStyle)
        willCheckItOutLGButton.rightIconColor = CinePickerColors.getTagColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    private func selectILikeIt() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        iLikeItLGButton.bgColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.borderColor = CinePickerColors.getILikeItTagColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.titleColor = CinePickerColors.getILikeItTagColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.rightIconColor = CinePickerColors.getILikeItTagColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    private func deselectILikeIt() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        iLikeItLGButton.bgColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.borderColor = CinePickerColors.getTagColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.titleColor = CinePickerColors.getTagColor(userInterfaceStyle: userInterfaceStyle)
        iLikeItLGButton.rightIconColor = CinePickerColors.getTagColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    @IBAction func onWillCheckItOutLGButtonTouchUpInside(_ sender: LGButton) {
        onTapWillCheckItOut?(self)
    }
    
    @IBAction func onILikeItLGButtonTouchUpInside(_ sender: LGButton) {
        onTapILikeIt?(self)
    }
    
}
