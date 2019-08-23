import UIKit
import LGButton

class MovieDetailsTagsTableViewCell: UITableViewCell {

    @IBOutlet weak var contentUIView: UIView!
    
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
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
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
