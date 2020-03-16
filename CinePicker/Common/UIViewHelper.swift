import UIKit
import Agrume
import SCLAlertView

class UIViewHelper {
    
    private static var alertViewResponder: SCLAlertViewResponder?
    
    private static var deferredAlertViewButtonAction: (() -> Void)?
    
    public static func getMovieRatingColor(rating: Double) -> UIColor {
        switch(rating) {
            case 0.0..<5.0: return CinePickerColors.getTextNegativeColor()
            case 5.0..<6.5: return CinePickerColors.getTextNeutralColor()
            case 6.5...10: return CinePickerColors.getTextPositiveColor()
            default: return CinePickerColors.getSubtitleColor()
        }
    }
    
    public static func setImageFromInternet(
        at view: ImageFromInternetViewCellAdapter,
        downloadedBy imageService: ImageService,
        onComplete callback: @escaping (_: UIImage?) -> Void
    ) {
        if view.imagePath.isEmpty {
            setImage(at: view, image: nil, onComplete: callback)
            return
        }
        downloadAndSetImage(at: view, using: imageService, onComplete: callback)
    }
    
    private static func setImage(
        at view: ImageFromInternetViewCellAdapter,
        image: UIImage?,
        onComplete callback: @escaping (_: UIImage?) -> Void
    ) {
        OperationQueue.main.addOperation {
            view.imageValue = image
            update(imageView: view, bySettingActivityIndicatorAnimatingTo: false)
            callback(image)
        }
    }
    
    private static func update(
        imageView view: ImageFromInternetViewCellAdapter,
        bySettingActivityIndicatorAnimatingTo activityIndicatorIsActive: Bool
    ) {
        if activityIndicatorIsActive {
            view.activityIndicatorAlpha = 1.0
            view.imageViewAlpha = 0.0
            view.activityIndicatorStartAnimating()
            return
        }
        let escapingView = view
        // 300 milliseconds user will see stopped activity indicator
        view.activityIndicatorStopAnimating()
        let animations = {
            escapingView.activityIndicatorAlpha = 0.0
            escapingView.imageViewAlpha = 1.0
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: nil)
    }
    
    private static func downloadAndSetImage(
        at view: ImageFromInternetViewCellAdapter,
        using imageService: ImageService,
        onComplete callback: @escaping (_: UIImage?) -> Void
    ) {
        update(imageView: view, bySettingActivityIndicatorAnimatingTo: true)
        imageService.download(by: getImageUrl(from: view)) { (image) in
            setImage(at: view, image: image, onComplete: callback)
        }
    }
    
    private static func getImageUrl(from view: ImageFromInternetViewCellAdapter) -> URL {
        guard let url = view.imageUrl else {
            fatalError("View image url wasn't built...")
        }
        return url
    }
    
    public static func openImage(
        from viewController: UIViewController,
        by imagePath: String,
        using imageService: ImageService
    ) {
        let url = buildImageUrl(by: imagePath)
        openFullScreenImage(from: viewController, downloadedBy: url, using: imageService)
    }
    
    private static func buildImageUrl(by imagePath: String) -> URL {
        let optionalUrl = URLBuilder(string: CinePickerConfig.originalImagePath)
            .append(pathComponent: imagePath)
            .build()
        guard let url = optionalUrl else {
            fatalError("Url to open image wasn't built...")
        }
        return url
    }
    
    private static func openFullScreenImage(
        from viewController: UIViewController,
        downloadedBy url: URL,
        using imageService: ImageService
    ) {
        let agrume = Agrume(url: url, background: .colored(CinePickerColors.getBackgroundColor()))
        agrume.download = { (url, completion) in
            imageService.download(by: url) { (image) in
                completion(image)
            }
        }
        agrume.show(from: viewController)
    }
    
    public static func getUITableViewCellSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = CinePickerColors.getSelectedBackgroundColor()
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
    
    private static func getAdjustedFrame(from tableView: UITableView) -> CGRect {
        return CGRect(
            x: tableView.center.x,
            y: tableView.center.y,
            width: tableView.bounds.size.width,
            height: tableView.bounds.size.height
        )
    }
    
    public static func getFailedLoadingView(
        for tableView: UITableView,
        onTouchDown: @escaping () -> Void
    ) -> FailedLoadingUIView {
        let view = Bundle.main.loadNibNamed("FailedLoadingUIView", owner: tableView, options: nil)!.first as! FailedLoadingUIView
        view.onTouchDown = onTouchDown
        view.frame = getAdjustedFrame(from: tableView)
        return view
    }
    
    public static func getMessageView(for tableView: UITableView) -> MessageUIView {
        let view = Bundle.main.loadNibNamed("MessageUIView", owner: tableView, options: nil)!.first as! MessageUIView
        view.frame = getAdjustedFrame(from: tableView)
        return view
    }
    
    public static func showAlert(
        traitCollection: UITraitCollection,
        buttonActions: [(title: String, action: () -> Void)],
        imageName: String = "menu_image",
        isAnimationRightToLeft: Bool = false
    ) {
        let alert = createAlert()
        addButtons(toAlert: alert, usingButtonActions: buttonActions)
        initAlertViewResponder(traitCollection, imageName, isAnimationRightToLeft, alert)
    }
    
    private static func createAlert() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleHeight: 12,
            kTitleFont: UIFont.systemFont(ofSize: 0),
            kTextFont: UIFont.systemFont(ofSize: 0),
            contentViewCornerRadius: 7,
            buttonCornerRadius: 7,
            hideWhenBackgroundViewIsTapped: true,
            contentViewColor: CinePickerColors.getBackgroundColor(),
            contentViewBorderColor: CinePickerColors.getAlertBorderColor(),
            titleColor: CinePickerColors.getTitleColor()
        )
        let alert = SCLAlertView(appearance: appearance)
        return alert
    }
    
    private static func addButtons(
        toAlert alert: SCLAlertView,
        usingButtonActions buttonActions: [(title: String, action: () -> Void)]
    ) {
        for buttonAction in buttonActions {
            alert.addButton(
                buttonAction.title,
                backgroundColor: CinePickerColors.getActionColor(),
                action: { deferredAlertViewButtonAction = buttonAction.action }
            )
        }
    }
    
    private static func initAlertViewResponder(
        _ traitCollection: UITraitCollection,
        _ imageName: String,
        _ isAnimationRightToLeft: Bool,
        _ alert: SCLAlertView
    ) {
        alertViewResponder = alert.showSuccess(
            "",
            subTitle: "",
            closeButtonTitle: CinePickerCaptions.cancel,
            colorStyle: CinePickerColors.getAlertCircleBackgroundColor(traitCollection: traitCollection),
            circleIconImage: UIImage(named: imageName),
            animationStyle: isAnimationRightToLeft ? .rightToLeft : .topToBottom
        )
        alertViewResponder?.setDismissBlock {
            alertViewResponder = nil
            deferredAlertViewButtonAction?()
            deferredAlertViewButtonAction = nil
        }
    }
    
    public static func closeAlert() {
        alertViewResponder?.close()
    }
    
    public static func showDatasourceAgreementAlert(
        traitCollection: UITraitCollection,
        buttonAction: @escaping () -> Void
    ) {
        let alert = createDatasourceAgreementAlert(traitCollection: traitCollection)
        addButton(toDatasourceAgreementAlert: alert, usingButtonAction: buttonAction, traitCollection: traitCollection)
        initDatasourceAgreementAlertViewResponder(traitCollection, alert)
    }
    
    private static func createDatasourceAgreementAlert(traitCollection: UITraitCollection) -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleHeight: 12,
            kTitleFont: UIFont.systemFont(ofSize: 0),
            kTextFont: UIFont.systemFont(ofSize: 14),
            showCloseButton: false,
            contentViewCornerRadius: 7,
            buttonCornerRadius: 7,
            hideWhenBackgroundViewIsTapped: false,
            contentViewColor: CinePickerColors.getDataSourceAgreementAlertBackgroundColor(traitCollection: traitCollection),
            contentViewBorderColor: CinePickerColors.getDataSourceAgreementAlertBorderColor(traitCollection: traitCollection),
            titleColor: CinePickerColors.getDataSourceAgreementAlertTextColor(traitCollection: traitCollection)
        )
        let alert = SCLAlertView(appearance: appearance)
        return alert
    }
    
    private static func addButton(
        toDatasourceAgreementAlert alert: SCLAlertView,
        usingButtonAction buttonAction: @escaping () -> Void,
        traitCollection: UITraitCollection
    ) {
        alert.addButton(
            "OK",
            backgroundColor: CinePickerColors.getDataSourceAgreementActionColor(traitCollection: traitCollection),
            action: { deferredAlertViewButtonAction = buttonAction }
        )
    }
    
    private static func initDatasourceAgreementAlertViewResponder(
        _ traitCollection: UITraitCollection,
        _ alert: SCLAlertView
    ) {
        alertViewResponder = alert.showSuccess(
            " ",
            subTitle: "This product uses the TMDb API but is not endorsed or certified by TMDb.",
            closeButtonTitle: CinePickerCaptions.cancel,
            colorStyle: CinePickerColors.getDataSourceAgreementAlertCircleBackgroundColor(traitCollection: traitCollection),
            circleIconImage: UIImage(named: "data_source_logo")
        )
        alertViewResponder?.setDismissBlock {
            alertViewResponder = nil
            deferredAlertViewButtonAction?()
            deferredAlertViewButtonAction = nil
        }
    }
    
    public static func buildImageUrl(byImagePath imagePath: String) -> URL? {
        return URLBuilder(string: CinePickerConfig.imagePath)
            .append(pathComponent: imagePath)
            .build()
    }
}
