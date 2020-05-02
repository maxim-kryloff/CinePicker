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
    
    private var downloadedImageDictionary: [String: UIImage] = [:]
    
    private var imageService = ImageService()
    
    public func setImageFromInternet(
        at cell: ImageFromInternetViewCell,
        _ callback: @escaping (_ image: UIImage?, _ cell: ImageFromInternetViewCell) -> Void = { (image, cell) in }
    ) {
        let cell = ImageFromInternetViewCellAdapter(cell: cell)
        if cell.imagePath.isEmpty {
            setImage(at: cell, image: cell.defaultImage)
            return
        }
        if let downloadedImage = downloadedImageDictionary[cell.imageUrl!.path] {
            setImage(at: cell, image: downloadedImage)
            return
        }
        downloadAndSetImage(at: cell, onComplete: callback)
    }
    
    private func setImage(at cell: ImageFromInternetViewCellAdapter, image: UIImage?) {
        cell.imageValue = image
        stopActivityIndicator(at: cell)
    }
    
    private func stopActivityIndicator(at cell: ImageFromInternetViewCellAdapter) {
        cell.activityIndicatorStopAnimating()
        let animations = {
            cell.activityIndicatorAlpha = 0.0
            cell.imageViewAlpha = 1.0
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: nil)
    }
    
    private func downloadAndSetImage(
        at cell: ImageFromInternetViewCellAdapter,
        onComplete callback: @escaping (_ image: UIImage?, _ cell: ImageFromInternetViewCell) -> Void = { (image, cell) in }
    ) {
        startActivityIndicator(at: cell)
        imageService.download(by: cell.imageUrl!) { (image, url) in
            DispatchQueue.main.async {
                self.downloadedImageDictionary[url.path] = image
                // Don't use 'cell.imageUrl!' here. You will get a crash related with async code when seguing to the next view controller
                // because cell.imageUrl will be nil
                if let cellImageUrl = cell.imageUrl, cellImageUrl.path == url.path {
                    self.setImage(at: cell, image: image)
                    callback(image, cell.originCell)
                }
            }
        }
    }
    
    private func startActivityIndicator(at cell: ImageFromInternetViewCellAdapter) {
        cell.activityIndicatorAlpha = 1.0
        cell.imageViewAlpha = 0.0
        cell.activityIndicatorStartAnimating()
    }
    
    public func openImage(from viewController: UIViewController, by imagePath: String) {
        let url = buildOriginalImageUrl(by: imagePath)!
        openFullScreenImage(from: viewController, downloadedBy: url)
    }
    
    private func buildOriginalImageUrl(by imagePath: String) -> URL? {
        let url = URLBuilder(string: CinePickerConfig.originalImagePath)
            .append(pathComponent: imagePath)
            .build()
        return url
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
    
    public func cancelSettingImageFromInternet(at cell: ImageFromInternetViewCell) {
        let cell = ImageFromInternetViewCellAdapter(cell: cell)
        if cell.imagePath.isEmpty {
            return
        }
        imageService.cancelDownloading(by: cell.imageUrl!)
    }
    
    public func buildImageUrl(by imagePath: String) -> URL? {
        let url = URLBuilder(string: CinePickerConfig.imagePath)
            .append(pathComponent: imagePath)
            .build()
        return url
    }
}
