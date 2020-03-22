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
        setDefaultState()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDefaultState()
    }
    
    private func setDefaultState() {
        setDefaultColors()
        setDefaultPropertyValues()
    }
    
    private func setDefaultColors() {
        backgroundColor = CinePickerColors.getBackgroundColor()
        overviewLabel.textColor = CinePickerColors.getOverviewColor()
    }
    
    private func setDefaultPropertyValues() {
        overview = nil
    }
}
