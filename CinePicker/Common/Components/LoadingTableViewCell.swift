import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bottomBarView: UIView!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setDefaultColors()
        
        loadingActivityIndicator.startAnimating()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultColors()
        
        isUserInteractionEnabled = false
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        loadingActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
        bottomBarView.backgroundColor = CinePickerColors.getBottomBarColor()
    }

}
