import UIKit

class FailedLoadingUIView: UIView {
    
    public var onTouchDownHandler: (() -> Void)!
    
    @IBAction func onTouchDown(_ sender: UIButton) {
        onTouchDownHandler!()
    }
    
}
