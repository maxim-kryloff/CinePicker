import UIKit
import Agrume

class UIViewHelper {
    
    public static func getMovieRatingColor(rating: Double) -> UIColor {
        switch(rating) {
        case 0.0..<5.0: return CinePickerColors.red
        case 5.0..<6.5: return CinePickerColors.yellow
        case 6.5...10: return CinePickerColors.green
        default: fatalError("Rating is out of allowed range...")
        }
    }
    
    public static func setImagesFromInternet(
        by imagePath: String,
        at view: inout ImageFromInternet,
        using imageService: ImageService,
        _ callback: @escaping (_: UIImage?) -> Void
    ) {
        let imageUrl = getImageUrl(configImagePath: CinePickerConfig.imagePath, imagePath: imagePath)
        
        view.imageUrl = imageUrl
        
        update(imageViewWithActivityIndicator: &view, whenIsWaitingForImage: true)
        
        var escapedView = view
        
        imageService.download(by: imageUrl) { (image) in
            OperationQueue.main.addOperation {
                escapedView.imageValue = image
                update(imageViewWithActivityIndicator: &escapedView, whenIsWaitingForImage: false)
                
                callback(image)
            }
        }
    }
    
    public static func openImage(from viewController: UIViewController, image: UIImage) {
        let agrume = Agrume(image: image, background: .colored(.white))
        agrume.show(from: viewController)
    }
    
    public static func getHeaderView(
        for tableView: UITableView,
        withText text: String
    ) -> HeaderUIView {
        
        let view = Bundle.main.loadNibNamed("HeaderUIView", owner: tableView, options: nil)!.first as! HeaderUIView
        
        view.header = text
        
        return view
    }
    
    public static func getLoadingView(for tableView: UITableView) -> UIView {
        let view = Bundle.main.loadNibNamed("LoadingUIView", owner: tableView, options: nil)!.first as! UIView
        
        view.frame = getAdjustedFrame(from: tableView)
        
        return view
    }
    
    public static func getFailedLoadingView(
        for tableView: UITableView,
        onTouchDownHandler: @escaping () -> Void
    ) -> FailedLoadingUIView {
        
        let view = Bundle.main.loadNibNamed("FailedLoadingUIView", owner: tableView, options: nil)!.first as! FailedLoadingUIView
        
        view.onTouchDownHandler = onTouchDownHandler
        
        view.frame = getAdjustedFrame(from: tableView)
        
        return view
    }
    
    public static func getMessageView(for tableView: UITableView) -> MessageUIView {
        let view = Bundle.main.loadNibNamed("MessageUIView", owner: tableView, options: nil)!.first as! MessageUIView
        
        view.frame = getAdjustedFrame(from: tableView)
        
        return view
    }
    
    private static func update(imageViewWithActivityIndicator view: inout ImageFromInternet, whenIsWaitingForImage isWaiting: Bool) {
        if isWaiting {
            view.activityIndicatorAlpha = 1.0
            view.imageViewAlpha = 0.0
            
            view.activityIndicatorStartAnimating()
            
            return
        }
        
        var escapingView = view
        
        // 300 milliseconds user will see stopped activity indicator
        view.activityIndicatorStopAnimating()
        
        let animations = {
            escapingView.activityIndicatorAlpha = 0.0
            escapingView.imageViewAlpha = 1.0
        }
        
        UIView.animate(withDuration: 0.3, animations: animations, completion: nil)
    }
    
    private static func getAdjustedFrame(from tableView: UITableView) -> CGRect {
        return CGRect(
            x: tableView.center.x,
            y: tableView.center.y,
            width: tableView.bounds.size.width,
            height: tableView.bounds.size.height
        )
    }
    
    private static func getImageUrl(configImagePath: String, imagePath: String) -> URL {
        return URLBuilder(string: configImagePath).append(pathComponent: imagePath).build()!
    }
    
}
