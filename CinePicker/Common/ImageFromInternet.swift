import Foundation
import UIKit

protocol ImageFromInternet {
    
    var imageViewAlpha: CGFloat { get set }
    
    var activityIndicatorAlpha: CGFloat { get set }
    
    var imageValue: UIImage? { get set }
    
    var originalImageValue: UIImage? { get set }
    
    var imageUrl: URL? { get set }
    
    var originalImageUrl: URL? { get set }
    
    func activityIndicatorStartAnimating () -> Void
    
    func activityIndicatorStopAnimating () -> Void
    
}
