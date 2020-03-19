import UIKit

protocol ImageFromInternetViewCell {
    
    var imagePath: String { get set }
    
    var defaultImage: UIImage { get }
    
    var imageFromInternetImageView: UIImageView { get }
    
    var activityIndicatorView: UIActivityIndicatorView { get }
}
