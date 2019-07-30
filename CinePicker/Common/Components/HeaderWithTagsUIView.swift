import UIKit
import LGButton

class HeaderWithTagsUIView: UIView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
    @IBOutlet weak var iLikeItLGButton: LGButton!
    
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
        header = nil
        
        isWillCheckItOutSelected = false
        isILikeItSelected = false
    }
    
    private func selectWillCheckItOut() {
        willCheckItOutLGButton.borderColor = CinePickerColors.lightBlue
        willCheckItOutLGButton.titleColor = CinePickerColors.lightBlue
        willCheckItOutLGButton.rightIconColor = CinePickerColors.lightBlue
    }
    
    private func deselectWillCheckItOut() {
        willCheckItOutLGButton.borderColor = CinePickerColors.white
        willCheckItOutLGButton.titleColor = CinePickerColors.white
        willCheckItOutLGButton.rightIconColor = CinePickerColors.white
    }
    
    private func selectILikeIt() {
        iLikeItLGButton.borderColor = CinePickerColors.lightPink
        iLikeItLGButton.titleColor = CinePickerColors.lightPink
        iLikeItLGButton.rightIconColor = CinePickerColors.lightPink
    }
    
    private func deselectILikeIt() {
        iLikeItLGButton.borderColor = CinePickerColors.white
        iLikeItLGButton.titleColor = CinePickerColors.white
        iLikeItLGButton.rightIconColor = CinePickerColors.white
    }
    
    @IBAction func onWillCheckItOutLGButtonTouchUpInside(_ sender: LGButton) {
        onTapWillCheckItOut?(self)
    }
    
    @IBAction func onILikeItLGButtonTouchUpInside(_ sender: LGButton) {
        onTapILikeIt?(self)
    }
    
}
