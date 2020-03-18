import UIKit

class ImageFromInternetViewCellAdapter {
    
    private var cell: ImageFromInternetViewCell
    
    init(cell: ImageFromInternetViewCell) {
        self.cell = cell
        self.setDefaultPropertyValues()
    }
}

extension ImageFromInternetViewCellAdapter {
    
    var imageValue: UIImage? {
        get {
            return cell.imageFromInternetImageView.image
        }
        set {
            cell.imageFromInternetImageView.isUserInteractionEnabled = newValue != nil
            cell.imageFromInternetImageView.image = newValue ?? cell.defaultImage
        }
    }
    
    var imagePath: String {
        get { return cell.imagePath }
    }
    
    var imageUrl: URL? {
        get {
            if imagePath.isEmpty {
                return nil
            }
            return UIViewUtils.buildImageUrl(by: imagePath)
        }
    }
    
    public var imageViewAlpha: CGFloat {
        get { return cell.imageFromInternetImageView.alpha }
        set { cell.imageFromInternetImageView.alpha = newValue }
    }
    
    var activityIndicatorAlpha: CGFloat {
        get { return cell.activityIndicatorView.alpha }
        set { cell.activityIndicatorView.alpha = newValue }
    }
    
    func activityIndicatorStartAnimating() {
        cell.activityIndicatorView.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        cell.activityIndicatorView.stopAnimating()
    }
    
    private func setDefaultPropertyValues() {
        imageViewAlpha = 1.0
        activityIndicatorAlpha = 0.0
        imageValue = nil
    }
}
