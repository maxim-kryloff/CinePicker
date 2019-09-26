import UIKit
import LGButton

class MovieDetailsTagsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
    @IBOutlet weak var iLikeItLGButton: LGButton!
    
    public static var standardHeight: CGFloat {
        return 50
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
    
    public var onTapWillCheckItOut: ((_ cell: MovieDetailsTagsTableViewCell) -> Void)?
    
    public var onTapILikeIt: ((_ cell: MovieDetailsTagsTableViewCell) -> Void)?
    
    private var willCheckItOutSystemTag: Tag!
    
    private var iLikeItSystemTag: Tag!
    
    private var willCheckItOutSystemTagName: String {
        return CinePickerConfig.getLanguage() == .ru ? willCheckItOutSystemTag.russianName : willCheckItOutSystemTag.name
    }
    
    private var iLikeItSystemTagName: String {
        return CinePickerConfig.getLanguage() == .ru ? iLikeItSystemTag.russianName : iLikeItSystemTag.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        willCheckItOutSystemTag = TagRepository.shared.getSystemTag(byName: .willCheckItOut)
        iLikeItSystemTag = TagRepository.shared.getSystemTag(byName: .iLikeIt)
        
        setDefaultState()
    }

    private func setDefaultState() {
        setDefaultColors()
        
        willCheckItOutLGButton.titleString = willCheckItOutSystemTagName
        iLikeItLGButton.titleString = iLikeItSystemTagName
        
        isWillCheckItOutSelected = nil
        isILikeItSelected = nil
        
        onTapWillCheckItOut = nil
        onTapILikeIt = nil
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
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
