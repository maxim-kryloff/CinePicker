import UIKit
import Agrume
import SCLAlertView

class UIViewHelper {
    
    public static func getMovieRatingColor(userInterfaceStyle: UIUserInterfaceStyle, rating: Double) -> UIColor {
        switch(rating) {
        case 0.0..<5.0: return CinePickerColors.getTextNegativeColor(userInterfaceStyle: userInterfaceStyle)
        case 5.0..<6.5: return CinePickerColors.getTextNeutralColor(userInterfaceStyle: userInterfaceStyle)
        case 6.5...10: return CinePickerColors.getTextPositiveColor(userInterfaceStyle: userInterfaceStyle)
        default: return CinePickerColors.getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
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
        using imageService: ImageService,
        userInterfaceStyle: UIUserInterfaceStyle
    ) {
        
        let url = URLBuilder(string: CinePickerConfig.originalImagePath)
            .append(pathComponent: imagePath)
            .build()
        
        if url == nil {
            fatalError("Url to open image wasn't built...")
        }
        
        let agrume = Agrume(url: url!, background: .colored(CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)))
        agrume.statusBarStyle = CinePickerColors.getAgrumeStatusBarStyle(userInterfaceStyle: userInterfaceStyle)
        
        agrume.download = { url, completion in
            imageService.download(by: url) { (image) in
                completion(image)
            }
        }
        
        agrume.show(from: viewController)
    }
    
    public static func getUITableViewCellSelectedBackgroundView(userInterfaceStyle: UIUserInterfaceStyle) -> UIView {
        let view = UIView()
        view.backgroundColor = CinePickerColors.getSelectedBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        
        return view
    }
    
    public static func getHeaderView(for tableView: UITableView) -> HeaderUIView {
        let view = Bundle.main.loadNibNamed("HeaderUIView", owner: tableView, options: nil)!.first as! HeaderUIView
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
        userInterfaceStyle: UIUserInterfaceStyle,
        buttonActions: [(title: String, action: () -> Void)],
        imageName: String = "menu_image",
        message: String = "",
        showCloseButton: Bool = true,
        isAnimationRightToLeft: Bool = false,
        hideWhenBackgroundViewIsTapped: Bool = true,
        circleBackgroundColor: UInt? = nil
    ) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleHeight: 12,
            kTitleFont: UIFont.systemFont(ofSize: 0),
            kTextFont: message.isEmpty ? UIFont.systemFont(ofSize: 0) : UIFont.systemFont(ofSize: 14),
            showCloseButton: showCloseButton,
            contentViewCornerRadius: 7,
            buttonCornerRadius: 7,
            hideWhenBackgroundViewIsTapped: hideWhenBackgroundViewIsTapped,
            contentViewColor: CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle),
            contentViewBorderColor: CinePickerColors.getAlertBorderColor(userInterfaceStyle: userInterfaceStyle),
            titleColor: CinePickerColors.getTitleColor(userInterfaceStyle: userInterfaceStyle)
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        for buttonAction in buttonActions {
            alertView.addButton(buttonAction.title, backgroundColor: CinePickerColors.getActionColor(userInterfaceStyle: userInterfaceStyle), action: buttonAction.action)
        }
        
        let circleIconImage = UIImage(named: imageName)
        
        let animationStyle: SCLAnimationStyle = isAnimationRightToLeft ? .rightToLeft : .topToBottom
        
        let fakeTitle = message.isEmpty ? "" : " "
        
        let circleBackgroundColor = circleBackgroundColor
            ?? CinePickerColors.getAlertCircleBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        
        alertView.showSuccess(
            fakeTitle,
            subTitle: message,
            closeButtonTitle: CinePickerCaptions.cancel,
            colorStyle: circleBackgroundColor,
            circleIconImage: circleIconImage,
            animationStyle: animationStyle
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
