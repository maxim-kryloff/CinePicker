import UIKit
import Agrume

class UIImageUtils {
    
    private static var instance: UIImageUtils?
    
    public static var shared: UIImageUtils {
        if instance == nil {
            instance = UIImageUtils()
        }
        return instance!
    }
    
    private init() { }
    
    private var downloadedImages: [String: UIImage] = [:]
    
    private var imageService = ImageService()
    
    public func setImageFromInternet(at view: ImageFromInternetViewCellAdapter) {
        if view.imagePath.isEmpty {
            setImage(at: view, image: view.defaultImage)
            return
        }
        if let downloadedImage = downloadedImages[view.imagePath] {
            setImage(at: view, image: downloadedImage)
            return
        }
        update(imageView: view, bySettingActivityIndicatorAnimatingTo: true)
        imageService.download(by: getImageUrl(from: view)) { (image) in
            OperationQueue.main.addOperation {
                self.setImage(at: view, image: image)
                self.downloadedImages[view.imagePath] = image
            }
        }
    }
    
    private func setImage(at view: ImageFromInternetViewCellAdapter, image: UIImage?) {
        view.imageValue = image
        self.update(imageView: view, bySettingActivityIndicatorAnimatingTo: false)
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
    
    public func openImage(from viewController: UIViewController, by imagePath: String) {
        let url = buildOriginalImageUrl(by: imagePath)
        openFullScreenImage(from: viewController, downloadedBy: url)
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
    
    private func openFullScreenImage(from viewController: UIViewController, downloadedBy url: URL) {
        let agrume = Agrume(url: url, background: .colored(CinePickerColors.getBackgroundColor()))
        agrume.download = { (url, completion) in
            self.imageService.download(by: url) { (image) in
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
