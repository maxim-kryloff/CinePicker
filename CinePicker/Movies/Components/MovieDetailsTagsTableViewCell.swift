import UIKit
import LGButton

class MovieDetailsTagsTableViewCell: UITableViewCell {

    @IBOutlet weak var willCheckItOutLGButton: LGButton!
    
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
    
    public var onTapWillCheckItOut: ((_ cell: MovieDetailsTagsTableViewCell) -> Void)?
    
    private var willCheckItOutSystemTag: Tag!
    
    private var willCheckItOutSystemTagName: String {
        return CinePickerConfig.getLanguage() == .ru ? willCheckItOutSystemTag.russianName : willCheckItOutSystemTag.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        willCheckItOutSystemTag = TagRepository.shared.getSystemTag(byName: .willCheckItOut)
        
        setDefaultState()
    }

    private func setDefaultState() {
        willCheckItOutLGButton.titleString = willCheckItOutSystemTagName
        isWillCheckItOutSelected = false
    }
    
    private func selectWillCheckItOut() {
        willCheckItOutLGButton.borderColor = CinePickerColors.yellow
        willCheckItOutLGButton.titleColor = CinePickerColors.yellow
        willCheckItOutLGButton.rightIconColor = CinePickerColors.yellow
    }
    
    private func deselectWillCheckItOut() {
        willCheckItOutLGButton.borderColor = CinePickerColors.white
        willCheckItOutLGButton.titleColor = CinePickerColors.white
        willCheckItOutLGButton.rightIconColor = CinePickerColors.white
    }

    @IBAction func onWillCheckItOutLGButtonTouchUpInside(_ sender: LGButton) {
        onTapWillCheckItOut?(self)
    }
}
