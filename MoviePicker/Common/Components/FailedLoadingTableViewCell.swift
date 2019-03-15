import UIKit

class FailedLoadingTableViewCell: UITableViewCell {
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    public var onTouchDownHandler: (() -> Void)!
    
    @IBAction func onTouchDown(_ sender: UIButton) {
        onTouchDownHandler()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
    }

}
