import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        loadingActivityIndicator.startAnimating()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = false
    }

}
