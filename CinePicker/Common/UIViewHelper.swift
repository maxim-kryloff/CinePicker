import UIKit
import Agrume
import SCLAlertView

class UIViewHelper {
    
    public static func getMovieRatingColor(rating: Double) -> UIColor {
        switch(rating) {
        case 0.0..<5.0: return CinePickerColors.red
        case 5.0..<6.5: return CinePickerColors.yellow
        case 6.5...10: return CinePickerColors.green
        default: fatalError("Rating is out of allowed range...")
        }
    }
    
    public static func setImageFromInternet(
        by imagePath: String,
        at view: inout ImageFromInternet,
        using imageService: ImageService,
        _ callback: @escaping (_: UIImage?) -> Void
    ) {
        
        view.imagePath = imagePath
        
        update(imageViewWithActivityIndicator: &view, whenIsWaitingForImage: true)
        
        if view.imagePath.isEmpty {
            setImagesFromInternetAsyncResultHandler(view: &view, image: nil, callback: callback)
            return
        }
        
        guard let url = view.imageUrl else {
            fatalError("View image url wasn't built...")
        }
        
        var escapedView = view
        
        imageService.download(by: url) { (image) in
            setImagesFromInternetAsyncResultHandler(view: &escapedView, image: image, callback: callback)
        }
    }
    
    public static func openImage(
        from viewController: UIViewController,
        by imagePath: String,
        using imageService: ImageService
    ) {
        
        let url = URLBuilder(string: CinePickerConfig.originalImagePath)
            .append(pathComponent: imagePath)
            .build()
        
        if url == nil {
            fatalError("Url to open image wasn't built...")
        }
        
        let agrume = Agrume(url: url!, background: .colored(CinePickerColors.black))
        agrume.statusBarStyle = .lightContent
        
        agrume.download = { url, completion in
            imageService.download(by: url) { (image) in
                completion(image)
            }
        }
        
        agrume.show(from: viewController)
    }
    
    public static func getUITableViewCellSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = CinePickerColors.darkGray
        
        return view
    }
    
    public static func getHeaderWithTagsView(for tableView: UITableView) -> HeaderWithTagsUIView {
        let view = Bundle.main.loadNibNamed("HeaderWithTagsUIView", owner: tableView, options: nil)!.first as! HeaderWithTagsUIView
        return view
    }
    
    public static func getLoadingView(for tableView: UITableView) -> LoadingUIView {
        let view = Bundle.main.loadNibNamed("LoadingUIView", owner: tableView, options: nil)!.first as! LoadingUIView
        
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
    
    public static func showAlert(
        _ buttonActions: [(title: String, action: () -> Void)],
        _ imageName: String = "menu_image",
        _ title: String = "",
        _ subTitle: String = "",
        _ showCloseButton: Bool = true
    ) {

        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: showCloseButton,
            contentViewColor: CinePickerColors.black,
            contentViewBorderColor: CinePickerColors.darkGray,
            titleColor: CinePickerColors.gray
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        for buttonAction in buttonActions {
            alertView.addButton(buttonAction.title, backgroundColor: CinePickerColors.blue, action: buttonAction.action)
        }
        
        let circleIconImage = UIImage(named: imageName)
        
        alertView.showSuccess(
            title,
            subTitle: subTitle,
            closeButtonTitle: CinePickerCaptions.cancel,
            colorStyle: CinePickerColors.blackHex,
            circleIconImage: circleIconImage
        )
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
    
    private static func setImagesFromInternetAsyncResultHandler(
        view: inout ImageFromInternet,
        image: UIImage?,
        callback: @escaping (_: UIImage?) -> Void
    ) {
        
        var escapedView = view
        
        OperationQueue.main.addOperation {
            escapedView.imageValue = image
            update(imageViewWithActivityIndicator: &escapedView, whenIsWaitingForImage: false)
            
            callback(image)
        }
    }

}
