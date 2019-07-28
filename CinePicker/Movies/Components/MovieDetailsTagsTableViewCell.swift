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
        willCheckItOutLGButton.titleString = willCheckItOutSystemTagName
        iLikeItLGButton.titleString = iLikeItSystemTagName
        
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
