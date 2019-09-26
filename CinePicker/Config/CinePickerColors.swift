import UIKit

class CinePickerColors {
    
    public static func getBackgroundColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(26, 26, 26)
            
        }
        
        return getUIColorFromRGB(255, 255, 255)
    }
    
    public static func getSelectedBackgroundColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(50, 50, 50)
        }
        
        return getUIColorFromRGB(220, 220, 220)
    }
    
    public static func getActivityIndicatorColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getTitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getTitleColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(247, 247, 247)
        }
        
        return getUIColorFromRGB(20, 20, 20)
    }
    
    public static func getSubtitleColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(153, 153, 153)
        }
        
        return getUIColorFromRGB(66, 66, 66)
    }
    
    public static func getGenresColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getTopBarColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getBottomBarColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(65, 65, 65)
        }
        
        return getUIColorFromRGB(200, 200, 200)
    }
    
    public static func getTextNegativeColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(252, 54, 53)
        }
        
        return getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getTextNeutralColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(254, 173, 0)
        }
        
        return getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getTextPositiveColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(32, 150, 0)
        }
        
        return getActionColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getTagColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getTitleColor(userInterfaceStyle: userInterfaceStyle)
        }
        
        return getUIColorFromRGB(66, 66, 66)
    }
    
    public static func getWillCheckItOutTagColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(230, 144, 90)
        }
        
        return getActionColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getILikeItTagColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(227, 102, 95)
        }
        
        return getActionColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getReleaseYearColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getRuntimeColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getTitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getVoteCountColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getVoteSeparatorColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getUIColorFromRGB(153, 153, 153)
    }
    
    public static func getMessageColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getSubtitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getOverviewColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getTitleColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getActionColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        if userInterfaceStyle == .dark {
            return getUIColorFromRGB(1, 122, 255)
        }
        
        return getUIColorFromRGB(225, 45, 85)
    }
    
    public static func getAlertBorderColor(userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        return getBottomBarColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    public static func getAlertCircleBackgroundColor(userInterfaceStyle: UIUserInterfaceStyle) -> UInt {
        if userInterfaceStyle == .dark {
            return 0x323232
        }
        
        return 0xB4B4B4
    }
    
    public static func getDataSourceAgreementAlertCircleBackgroundColor(userInterfaceStyle: UIUserInterfaceStyle) -> UInt {
        if userInterfaceStyle == .dark {
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
