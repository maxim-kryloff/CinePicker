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
    
    public func setImageFromInternet(at cell: ImageFromInternetViewCell) {
        let cell = ImageFromInternetViewCellAdapter(cell: cell)
        if cell.imagePath.isEmpty {
            setImage(at: cell, image: cell.defaultImage)
            return
        }
        if let downloadedImage = downloadedImages[cell.imageUrl!.path] {
            setImage(at: cell, image: downloadedImage)
            return
        }
        downloadAndSetImage(at: cell)
    }
    
    private func setImage(at cell: ImageFromInternetViewCellAdapter, image: UIImage?) {
        cell.imageValue = image
        self.update(cell: cell, bySettingActivityIndicatorAnimatingTo: false)
    }
    
    private func update(
        cell: ImageFromInternetViewCellAdapter,
        bySettingActivityIndicatorAnimatingTo activityIndicatorIsActive: Bool
    ) {
        if activityIndicatorIsActive {
            cell.activityIndicatorAlpha = 1.0
            cell.imageViewAlpha = 0.0
            cell.activityIndicatorStartAnimating()
            return
        }
        // 0.3 sec user will see stopped activity indicator
        // because after indicator stopped it will be disappearing during 0.3 sec
        cell.activityIndicatorStopAnimating()
        let animations = {
            cell.activityIndicatorAlpha = 0.0
            cell.imageViewAlpha = 1.0
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: nil)
    }
    
    private func downloadAndSetImage(at cell: ImageFromInternetViewCellAdapter) {
        update(cell: cell, bySettingActivityIndicatorAnimatingTo: true)
        imageService.download(by: cell.imageUrl!) { (image, url) in
            OperationQueue.main.addOperation {
                self.downloadedImages[url.path] = image
                // Don't use 'cell.imageUrl!' here. You will get a crash related with async code when seguing to the next view controller
                // because cell.imageUrl will be nil
                if let cellImageUrl = cell.imageUrl, cellImageUrl.path == url.path {
                    self.setImage(at: cell, image: image)
                }
            }
        }
    }
    
    public func openImage(from viewController: UIViewController, by imagePath: String) {
        let url = buildOriginalImageUrl(by: imagePath)
        openFullScreenImage(from: viewController, downloadedBy: url)
    }
    
    private func buildOriginalImageUrl(by imagePath: String) -> URL {
        let url = URLBuilder(string: CinePickerConfig.originalImagePath)
            .append(pathComponent: imagePath)
            .build()
        return url!
    }
    
    private func openFullScreenImage(from viewController: UIViewController, downloadedBy url: URL) {
        let agrume = Agrume(url: url, background: .colored(CinePickerColors.getBackgroundColor()))
        agrume.download = { (url, completion) in
            self.imageService.download(by: url) { (image, _) in
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
