import UIKit

class FailedLoadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    public static var standardHeight: CGFloat {
        return 80
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageLabel.text = CinePickerCaptions.couldntReloadData
        actionButton.setTitle(CinePickerCaptions.reload, for: .normal)
    }

}
