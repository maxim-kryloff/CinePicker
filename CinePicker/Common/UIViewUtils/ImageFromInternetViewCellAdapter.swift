import UIKit

class ImageFromInternetViewCellAdapter {
    
    private var cell: ImageFromInternetViewCell
    
    init(cell: ImageFromInternetViewCell) {
        self.cell = cell
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
            return UIViewUtilsFactory.shared.getImageUtils().buildImageUrl(by: imagePath)
        }
    }
    
    var defaultImage: UIImage {
        return cell.defaultImage
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
}
