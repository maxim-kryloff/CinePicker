import UIKit
import SCLAlertView

class UIViewUtils {
    
    public static func getMovieRatingColor(rating: Double) -> UIColor {
        switch(rating) {
            case 0.0..<5.0: return CinePickerColors.getTextNegativeColor()
            case 5.0..<6.5: return CinePickerColors.getTextNeutralColor()
            case 6.5...10: return CinePickerColors.getTextPositiveColor()
            default: return CinePickerColors.getSubtitleColor()
        }
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
}
