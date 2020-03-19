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
        initTags()
        setDefaultState()
    }
    
    private func initTags() {
        willCheckItOutSystemTag = TagRepository.shared.getSystemTag(byName: .willCheckItOut)
        iLikeItSystemTag = TagRepository.shared.getSystemTag(byName: .iLikeIt)
    }
    
    private func setDefaultState() {
        setDefaultColors()
        setDefaultTagState()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    private func setDefaultTagState() {
        willCheckItOutLGButton.titleString = willCheckItOutSystemTagName
        iLikeItLGButton.titleString = iLikeItSystemTagName
    }
    
    private func setDefaultPropertyValues() {
        isWillCheckItOutSelected = nil
        isILikeItSelected = nil
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
        onTapWillCheckItOut?(self)
    }
    
    @IBAction func onILikeItLGButtonTouchUpInside(_ sender: LGButton) {
        onTapILikeIt?(self)
    }
}
