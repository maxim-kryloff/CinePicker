import UIKit

class MovieDetailsCountriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countriesLabel: UILabel!
    
    public static var standardHeight: CGFloat {
        return UITableView.automaticDimension
    }
    
    public var countries: [Country]? {
        didSet {
            if let countries = countries {
                countriesLabel.text = getCountriesLabelText(from: countries)
                return
            }
            countriesLabel.text = nil
        }
    }
    
    private func getCountriesLabelText(from countries: [Country]) -> String {
        var countryNames: [String] = []
        if CinePickerConfig.getLanguage() == .ru {
            countryNames = countries.map { $0.russianName }
        } else {
            countryNames = countries.map { $0.englishName }
        }
        return "\(CinePickerCaptions.countries): \(countryNames.joined(separator: ", "))"
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
        countriesLabel.textColor = CinePickerColors.getOverviewColor()
    }
    
    private func setDefaultPropertyValues() {
        countries = nil
    }
}
