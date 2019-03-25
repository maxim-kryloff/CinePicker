import UIKit

class HeaderUIView: UIView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    
}
