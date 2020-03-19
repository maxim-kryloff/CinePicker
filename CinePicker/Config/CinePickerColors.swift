import UIKit

class CinePickerColors {
    
    public static func getBackgroundColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(26, 26, 26)
            }
            return getUIColorFromRGB(255, 255, 255)
        }
    }
    
    public static func getSelectedBackgroundColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(50, 50, 50)
            }
            return getUIColorFromRGB(220, 220, 220)
        }
    }
    
    public static func getActivityIndicatorColor() -> UIColor {
        return getTitleColor()
    }
    
    public static func getTitleColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(247, 247, 247)
            }
            return getUIColorFromRGB(20, 20, 20)
        }
    }
    
    public static func getSubtitleColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(153, 153, 153)
            }
            return getUIColorFromRGB(66, 66, 66)
        }
    }
    
    public static func getGenresColor() -> UIColor {
        return getSubtitleColor()
    }
    
    public static func getTopBarColor() -> UIColor {
        return getBottomBarColor()
    }
    
    public static func getBottomBarColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(65, 65, 65)
            }
            return getUIColorFromRGB(200, 200, 200)
        }
    }
    
    public static func getTextNegativeColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(252, 54, 53)
            }
            return getSubtitleColor()
        }
    }
    
    public static func getTextNeutralColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(254, 173, 0)
            }
            return getSubtitleColor()
        }
    }
    
    public static func getTextPositiveColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(32, 150, 0)
            }
            return getActionColor()
        }
    }
    
    public static func getTagColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getTitleColor()
            }
            return getUIColorFromRGB(66, 66, 66)
        }
    }
    
    public static func getWillCheckItOutTagColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(230, 144, 90)
            }
            return getActionColor()
        }
    }
    
    public static func getILikeItTagColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(227, 102, 95)
            }
            return getActionColor()
        }
    }
    
    public static func getReleaseYearColor() -> UIColor {
        return getSubtitleColor()
    }
    
    public static func getRuntimeColor() -> UIColor {
        return getTitleColor()
    }
    
    public static func getVoteCountColor() -> UIColor {
        return getSubtitleColor()
    }
    
    public static func getVoteSeparatorColor() -> UIColor {
        return getUIColorFromRGB(153, 153, 153)
    }
    
    public static func getMessageColor() -> UIColor {
        return getSubtitleColor()
    }
    
    public static func getOverviewColor() -> UIColor {
        return getTitleColor()
    }
    
    public static func getActionColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getUIColorFromRGB(1, 122, 255)
            }
            return getUIColorFromRGB(225, 45, 85)
        }
    }
    
    public static func getSelectedSegmentTintColor() -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return getActionColor()
            }
            return getBackgroundColor()
        }
    }
    
    public static func getAlertBorderColor() -> UIColor {
        return getBottomBarColor()
    }
    
    public static func getAlertCircleBackgroundColor(traitCollection: UITraitCollection) -> UInt {
        if traitCollection.userInterfaceStyle == .dark {
            return 0x323232
        }
        return 0xB4B4B4
    }
    
    // Special Data Source Agreement Alert Colors (non-dynamic)
    public static func getDataSourceAgreementAlertBackgroundColor(traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return getUIColorFromRGB(26, 26, 26)
        }
        return getUIColorFromRGB(255, 255, 255)
    }
    
    public static func getDataSourceAgreementAlertBorderColor(traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return getUIColorFromRGB(65, 65, 65)
        }
        return getUIColorFromRGB(200, 200, 200)
    }
    
    public static func getDataSourceAgreementAlertTextColor(traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return getUIColorFromRGB(247, 247, 247)
        }
        return getUIColorFromRGB(20, 20, 20)
    }
    
    public static func getDataSourceAgreementActionColor(traitCollection: UITraitCollection) -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return getUIColorFromRGB(1, 122, 255)
        }
        return getUIColorFromRGB(225, 45, 85)
    }
    
    public static func getDataSourceAgreementAlertCircleBackgroundColor(traitCollection: UITraitCollection) -> UInt {
        if traitCollection.userInterfaceStyle == .dark {
            return 0x323232
        }
        return 0xFFFFFFF
    }
    
    private static func getUIColorFromRGB(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
        let red = CGFloat(Double(red) / 255.0)
        let green = CGFloat(Double(green) / 255.0)
        let blue = CGFloat(Double(blue) / 255.0)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
