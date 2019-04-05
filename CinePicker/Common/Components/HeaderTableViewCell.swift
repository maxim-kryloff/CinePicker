import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerButton: UIButton!
    
    public static var standardHeight: CGFloat {
        return 40
    }
    
    public var header: String? {
        didSet {
            headerButton.setTitle(header, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        headerButton.setTitle(nil, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerButton.setTitle(nil, for: .normal)
    }

}
