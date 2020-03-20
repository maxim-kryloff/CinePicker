import UIKit
import SCLAlertView

class UIAlertUtils {
    
    private static var instance: UIAlertUtils?
    
    public static var shared: UIAlertUtils {
        if instance == nil {
            instance = UIAlertUtils()
        }
        return instance!
    }
    
    private init() { }
    
    private var alertViewResponder: SCLAlertViewResponder?
    
    private var deferredAlertViewButtonAction: (() -> Void)?
    
    public func showAlert(
        traitCollection: UITraitCollection,
        buttonActions: [(title: String, action: () -> Void)],
        imageName: String = "menu_image",
        animationIsRightToLeft: Bool = false
    ) {
        let alert = createAlert()
        addButtons(toAlert: alert, usingButtonActions: buttonActions)
        initAlertViewResponder(traitCollection, imageName, animationIsRightToLeft, alert)
    }
    
    private func createAlert() -> SCLAlertView {
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
    
    private func addButtons(
        toAlert alert: SCLAlertView,
        usingButtonActions buttonActions: [(title: String, action: () -> Void)]
    ) {
        for buttonAction in buttonActions {
            alert.addButton(
                buttonAction.title,
                backgroundColor: CinePickerColors.getActionColor(),
                action: { self.deferredAlertViewButtonAction = buttonAction.action }
            )
        }
    }
    
    private func initAlertViewResponder(
        _ traitCollection: UITraitCollection,
        _ imageName: String,
        _ animationIsRightToLeft: Bool,
        _ alert: SCLAlertView
    ) {
        alertViewResponder = alert.showSuccess(
            "",
            subTitle: "",
            closeButtonTitle: CinePickerCaptions.cancel,
            colorStyle: CinePickerColors.getAlertCircleBackgroundColor(traitCollection: traitCollection),
            circleIconImage: UIImage(named: imageName),
            animationStyle: animationIsRightToLeft ? .rightToLeft : .topToBottom
        )
        alertViewResponder?.setDismissBlock {
            self.alertViewResponder = nil
            self.deferredAlertViewButtonAction?()
            self.deferredAlertViewButtonAction = nil
        }
    }
    
    public func closeAlert() {
        alertViewResponder?.close()
    }
    
    public func showDatasourceAgreementAlert(
        traitCollection: UITraitCollection,
        buttonAction: @escaping () -> Void
    ) {
        let alert = createDatasourceAgreementAlert(traitCollection: traitCollection)
        addButton(toDatasourceAgreementAlert: alert, usingButtonAction: buttonAction, traitCollection: traitCollection)
        initDatasourceAgreementAlertViewResponder(traitCollection, alert)
    }
    
    private func createDatasourceAgreementAlert(traitCollection: UITraitCollection) -> SCLAlertView {
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
    
    private func addButton(
        toDatasourceAgreementAlert alert: SCLAlertView,
        usingButtonAction buttonAction: @escaping () -> Void,
        traitCollection: UITraitCollection
    ) {
        alert.addButton(
            "OK",
            backgroundColor: CinePickerColors.getDataSourceAgreementActionColor(traitCollection: traitCollection),
            action: { self.deferredAlertViewButtonAction = buttonAction }
        )
    }
    
    private func initDatasourceAgreementAlertViewResponder(
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
            self.alertViewResponder = nil
            self.deferredAlertViewButtonAction?()
            self.deferredAlertViewButtonAction = nil
        }
    }
}
