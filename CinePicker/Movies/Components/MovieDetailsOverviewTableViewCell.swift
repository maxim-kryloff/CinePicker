import UIKit

class MovieDetailsOverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return UITableView.automaticDimension
    }
    
    public var overview: String? {
        didSet {
            overviewLabel.text = overview
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultColors()
        
        overview = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        overview = nil
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        overviewLabel.textColor = CinePickerColors.getOverviewColor(userInterfaceStyle: userInterfaceStyle)
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
