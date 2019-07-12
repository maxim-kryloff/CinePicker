import UIKit

class MovieDetailsTagsTableViewCell: UITableViewCell {

    @IBOutlet weak var tagButton: UIButton!

    public static var standardHeight: CGFloat {
        return 40
    }
    
    private var systemTag: Tag!
    
    private var systemTagName: String {
        return CinePickerConfig.getLanguage() == .ru ? systemTag.russianName : systemTag.name
    }
    
    public var isRemoveAction: Bool? {
        didSet {
            guard let isRemoveAction = isRemoveAction else {
                return
            }
            
            let title = isRemoveAction ? CinePickerCaptions.wontCheckItOut : systemTagName
            let titleColor = isRemoveAction ? CinePickerColors.red : CinePickerColors.blue
            
            tagButton.setTitle(title, for: UIControl.State.normal)
            tagButton.setTitleColor(titleColor, for: UIControl.State.normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.systemTag = TagRepository.shared.getSystemTag(byName: .willCheckItOut)
        
        setDefaultState()
    }

    private func setDefaultState() {
        tagButton.setTitle(systemTagName, for: UIControl.State.normal)
        tagButton.setTitleColor(CinePickerColors.blue, for: UIControl.State.normal)
    }

}
