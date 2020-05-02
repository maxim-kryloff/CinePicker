import UIKit

class ImageFromInternetViewCellAdapter {
    
    public let originCell: ImageFromInternetViewCell
    
    init(cell: ImageFromInternetViewCell) {
        originCell = cell
    }
}

extension ImageFromInternetViewCellAdapter {
    
    var imageValue: UIImage? {
        get {
            return originCell.imageFromInternetImageView.image
        }
        set {
            originCell.imageFromInternetImageView.isUserInteractionEnabled = newValue != nil
            originCell.imageFromInternetImageView.image = newValue ?? originCell.defaultImage
        }
    }
    
    var imagePath: String {
        get { return originCell.imagePath }
    }
    
    var imageUrl: URL? {
        get {
            if imagePath.isEmpty {
                return nil
            }
            return UIViewUtilsFactory.shared.getImageUtils().buildImageUrl(by: imagePath)
        }
    }
    
    var defaultImage: UIImage {
        return originCell.defaultImage
    }
    
    public var imageViewAlpha: CGFloat {
        get { return originCell.imageFromInternetImageView.alpha }
        set { originCell.imageFromInternetImageView.alpha = newValue }
    }
    
    var activityIndicatorAlpha: CGFloat {
        get { return originCell.activityIndicatorView.alpha }
        set { originCell.activityIndicatorView.alpha = newValue }
    }
    
    func activityIndicatorStartAnimating() {
        originCell.activityIndicatorView.startAnimating()
    }
    
    func activityIndicatorStopAnimating() {
        originCell.activityIndicatorView.stopAnimating()
    }
}
