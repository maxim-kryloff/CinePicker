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
        if let downloadedImage = downloadedImages[cell.imagePath] {
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
        let escapingView = cell
        // 300 milliseconds user will see stopped activity indicator
        cell.activityIndicatorStopAnimating()
        let animations = {
            escapingView.activityIndicatorAlpha = 0.0
            escapingView.imageViewAlpha = 1.0
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: nil)
    }
    
    private func downloadAndSetImage(at cell: ImageFromInternetViewCellAdapter) {
        update(cell: cell, bySettingActivityIndicatorAnimatingTo: true)
        imageService.download(by: getImageUrl(from: cell)) { (image) in
            OperationQueue.main.addOperation {
                self.setImage(at: cell, image: image)
                self.downloadedImages[cell.imagePath] = image
            }
        }
    }
    
    private func getImageUrl(from cell: ImageFromInternetViewCellAdapter) -> URL {
        guard let url = cell.imageUrl else {
            fatalError("Couldn't build image url.")
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
            fatalError("Couldn't build original image url.")
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
