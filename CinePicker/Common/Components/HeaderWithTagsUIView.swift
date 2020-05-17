import UIKit
import LGButton

class HeaderWithTagsUIView: UIView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
    @IBOutlet weak var iLikeItLGButton: LGButton!
    
    public static var standardHeight: CGFloat {
        return 55
    }
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
    public var willCheckItOutIsSelected: Bool? {
        didSet {
            guard let willCheckItOutIsSelected = willCheckItOutIsSelected else {
                deselectWillCheckItOut()
                return
            }
            willCheckItOutIsSelected ? selectWillCheckItOut() : deselectWillCheckItOut()
        }
    }
    
    public var iLikeItIsSelected: Bool? {
        didSet {
            guard let iLikeItIsSelected = iLikeItIsSelected else {
                deselectILikeIt()
                return
            }
            iLikeItIsSelected ? selectILikeIt() : deselectILikeIt()
        }
    }
    
    public var onTapWillCheckItOut: (() -> Void)?
    
    public var onTapILikeIt: (() -> Void)?
    
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
        headerLabel.textColor = CinePickerColors.getTitleColor()
    }
    
    private func setDefaultPropertyValues() {
        header = nil
        willCheckItOutIsSelected = nil
        iLikeItIsSelected = nil
        onTapWillCheckItOut = nil
        onTapILikeIt = nil
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
        onTapWillCheckItOut?()
    }
    
    @IBAction func onILikeItLGButtonTouchUpInside(_ sender: LGButton) {
        onTapILikeIt?()
    }
}
