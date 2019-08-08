import UIKit
import LGButton

class HeaderWithTagsUIView: UIView {
    
    @IBOutlet weak var contentUIView: UIView!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
    @IBOutlet weak var iLikeItLGButton: LGButton!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 50
    }
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
    public var isWillCheckItOutSelected: Bool? {
        didSet {
            guard let isWillCheckItOutSelected = isWillCheckItOutSelected else {
                return
            }
            
            isWillCheckItOutSelected ? selectWillCheckItOut() : deselectWillCheckItOut()
        }
    }
    
    public var isILikeItSelected: Bool? {
        didSet {
            guard let isILikeItSelected = isILikeItSelected else {
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
        
        isWillCheckItOutSelected = false
        isILikeItSelected = false
    }
    
    private func setDefaultColors() {
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        headerLabel.textColor = CinePickerColors.titleColor
        bottomBarView.backgroundColor = CinePickerColors.bottomBarColor
    }
    
    private func selectWillCheckItOut() {
        willCheckItOutLGButton.bgColor = CinePickerColors.backgroundColor
        willCheckItOutLGButton.borderColor = CinePickerColors.willCheckItOutTagColor
        willCheckItOutLGButton.titleColor = CinePickerColors.willCheckItOutTagColor
        willCheckItOutLGButton.rightIconColor = CinePickerColors.willCheckItOutTagColor
    }
    
    private func deselectWillCheckItOut() {
        willCheckItOutLGButton.bgColor = CinePickerColors.backgroundColor
        willCheckItOutLGButton.borderColor = CinePickerColors.tagColor
        willCheckItOutLGButton.titleColor = CinePickerColors.tagColor
        willCheckItOutLGButton.rightIconColor = CinePickerColors.tagColor
    }
    
    private func selectILikeIt() {
        iLikeItLGButton.bgColor = CinePickerColors.backgroundColor
        iLikeItLGButton.borderColor = CinePickerColors.iLikeItTagColor
        iLikeItLGButton.titleColor = CinePickerColors.iLikeItTagColor
        iLikeItLGButton.rightIconColor = CinePickerColors.iLikeItTagColor
    }
    
    private func deselectILikeIt() {
        iLikeItLGButton.bgColor = CinePickerColors.backgroundColor
        iLikeItLGButton.borderColor = CinePickerColors.tagColor
        iLikeItLGButton.titleColor = CinePickerColors.tagColor
        iLikeItLGButton.rightIconColor = CinePickerColors.tagColor
    }
    
    @IBAction func onWillCheckItOutLGButtonTouchUpInside(_ sender: LGButton) {
        onTapWillCheckItOut?(self)
    }
    
    @IBAction func onILikeItLGButtonTouchUpInside(_ sender: LGButton) {
        onTapILikeIt?(self)
    }
    
}
