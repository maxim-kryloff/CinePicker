import Foundation
import UIKit

class ImageService {
    
    private var downloadImageQueue = OperationQueue()
    
    private var operationDictionary: [String: Operation] = [:]
    
    public func download(by url: URL, onComplete callback: @escaping (_ image: UIImage?, _ url: URL) -> Void) {
        let operation = createDownloadImageOperation(downloadImageBy: url, onComplete: callback)
        downloadImageQueue.addOperation(operation)
        operationDictionary[url.path] = operation
    }
    
    private func createDownloadImageOperation(
        downloadImageBy url: URL,
        onComplete callback: @escaping (_ image: UIImage?, _ url: URL) -> Void
    ) -> AsyncOperation {
        let operation = DownloadImageOperation(url: url)
        operation.qualityOfService = .utility
        operation.completionBlock = {
            callback(operation.image, url)
        }
        return operation
    }
    
    public func cancelDownloading(by url: URL) {
        guard let operation = operationDictionary[url.path] else {
            return
        }
        if !operation.isFinished {
            operation.cancel()
        }
        operationDictionary[url.path] = nil
    }
}

extension ImageService {
    
    private class DownloadImageOperation: AsyncOperation {
        
        var url: URL
        
        var image: UIImage?
        
        init(url: URL) {
            self.url = url
            super.init()
        }
        
        override func main() {
            if isCancelled {
                return
            }
            downloadImage()
        }
        
        private func downloadImage() {
            let task = createDownloadImageTask()
            task.resume()
        }
        
        private func createDownloadImageTask() -> URLSessionDataTask {
            return URLSession.shared.dataTask(with: url) { (data, _, _) in
                if self.isCancelled {
                    return
                }
                guard let data = data else {
                    self.state = .isFinished
                    return
                }
                self.image = UIImage(data: data)
                self.state = .isFinished
            }
        }
    }
}
