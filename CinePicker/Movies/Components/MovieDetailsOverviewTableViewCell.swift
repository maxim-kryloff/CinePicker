import UIKit

class MovieDetailsOverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var overviewLabel: UILabel!
    
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
        
        overviewLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overviewLabel.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
