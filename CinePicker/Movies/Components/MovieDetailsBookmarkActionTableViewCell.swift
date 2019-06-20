import UIKit

class MovieDetailsBookmarkActionTableViewCell: UITableViewCell {

    @IBOutlet weak var bookmarkActionButton: UIButton!

    public static var standardHeight: CGFloat {
        return 40
    }
    
    public var isRemoveAction: Bool? {
        didSet {
            guard let isRemoveAction = isRemoveAction else {
                return
            }
            
            let title = isRemoveAction ? CinePickerCaptions.removeFromBookmarks : CinePickerCaptions.saveToBookmarks
            let titleColor = isRemoveAction ? CinePickerColors.red : CinePickerColors.blue
            
            bookmarkActionButton.setTitle(title, for: UIControl.State.normal)
            bookmarkActionButton.setTitleColor(titleColor, for: UIControl.State.normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setDefaultState()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultState()
    }

    private func setDefaultState() {
        bookmarkActionButton.setTitle(CinePickerCaptions.saveToBookmarks, for: UIControl.State.normal)
        bookmarkActionButton.setTitleColor(CinePickerColors.blue, for: UIControl.State.normal)
    }

}
