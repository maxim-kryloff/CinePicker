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
            
            let title = isRemoveAction ? "Remove from Bookmarks" : "Save to Bookmarks"
            let titleColor = isRemoveAction ? MoviePickerColors.red : MoviePickerColors.blue
            
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
        bookmarkActionButton.setTitle("Save to Bookmarks", for: UIControl.State.normal)
        bookmarkActionButton.setTitleColor(MoviePickerColors.blue, for: UIControl.State.normal)
    }

}
