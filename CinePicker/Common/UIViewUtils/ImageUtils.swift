import UIKit
import Agrume

class ImageUtils {
    
    private static var instance: ImageUtils?
    
    public static var shared: ImageUtils {
        if instance == nil {
            instance = ImageUtils()
        }
        return instance!
    }
    
    public func setImageFromInternet(
        at view: ImageFromInternetViewCellAdapter,
        downloadedBy imageService: ImageService,
        onComplete callback: @escaping (_: UIImage?) -> Void
    ) {
        if view.imagePath.isEmpty {
            setImage(at: view, image: nil, onComplete: callback)
            return
        }
        update(imageView: view, bySettingActivityIndicatorAnimatingTo: true)
        imageService.download(by: getImageUrl(from: view)) { (image) in
            self.setImage(at: view, image: image, onComplete: callback)
        }
    }
    
    private func setImage(
        at view: ImageFromInternetViewCellAdapter,
        image: UIImage?,
        onComplete callback: @escaping (_: UIImage?) -> Void
    ) {
        OperationQueue.main.addOperation {
            view.imageValue = image
            self.update(imageView: view, bySettingActivityIndicatorAnimatingTo: false)
            callback(image)
        }
    }
    
    private func update(
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
    
    private func getImageUrl(from view: ImageFromInternetViewCellAdapter) -> URL {
        guard let url = view.imageUrl else {
            fatalError("View image url wasn't built...")
        }
        return url
    }
    
    public func openImage(
        from viewController: UIViewController,
        by imagePath: String,
        using imageService: ImageService
    ) {
        let url = buildOriginalImageUrl(by: imagePath)
        openFullScreenImage(from: viewController, downloadedBy: url, using: imageService)
    }
    
    private func buildOriginalImageUrl(by imagePath: String) -> URL {
        let optionalUrl = URLBuilder(string: CinePickerConfig.originalImagePath)
            .append(pathComponent: imagePath)
            .build()
        guard let url = optionalUrl else {
            fatalError("Url to open image wasn't built...")
        }
        return url
    }
    
    private func openFullScreenImage(
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
    
    public func buildImageUrl(by imagePath: String) -> URL? {
        return URLBuilder(string: CinePickerConfig.imagePath)
            .append(pathComponent: imagePath)
            .build()
    }
}
