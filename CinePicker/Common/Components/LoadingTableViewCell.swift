import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentUIView: UIView!
    
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
        contentUIView.backgroundColor = CinePickerColors.backgroundColor
        loadingActivityIndicator.color = CinePickerColors.activityIndicatorColor
        bottomBarView.backgroundColor = CinePickerColors.bottomBarColor
    }

}
