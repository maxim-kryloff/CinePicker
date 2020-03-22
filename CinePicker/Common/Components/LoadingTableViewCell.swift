import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
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
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        loadingActivityIndicator.color = CinePickerColors.getActivityIndicatorColor()
    }
    
    private func setDefaultPropertyValues() {
        isUserInteractionEnabled = false
    }
}
