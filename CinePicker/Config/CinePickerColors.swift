import UIKit

class CinePickerColors {
    
    public static var backgroundColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(255, 255, 255)
        }
        
        return getUIColorFromRGB(26, 26, 26)
    }
    
    public static var selectedBackgroundColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(220, 220, 220)
        }
        
        return getUIColorFromRGB(50, 50, 50)
    }
    
    public static var activityIndicatorColor: UIColor {
        return titleColor
    }
    
    public static var titleColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(20, 20, 20)
        }
        
        return getUIColorFromRGB(247, 247, 247)
    }
    
    public static var subtitleColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(66, 66, 66)
        }
        
        return getUIColorFromRGB(153, 153, 153)
    }
    
    public static var genresColor: UIColor {
        return subtitleColor
    }
    
    public static var topBarColor: UIColor {
        return bottomBarColor
    }
    
    public static var bottomBarColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(200, 200, 200)
        }
        
        return getUIColorFromRGB(65, 65, 65)
    }
    
    public static var textNegativeColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return subtitleColor
        }
        
        return getUIColorFromRGB(252, 54, 53)
    }
    
    public static var textNeutralColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return subtitleColor
        }
        
        return getUIColorFromRGB(254, 173, 0)
    }
    
    public static var textPositiveColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return actionColor
        }
        
        return getUIColorFromRGB(32, 150, 0)
    }
    
    public static var tagColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(66, 66, 66)
        }
        
        return titleColor
    }
    
    public static var willCheckItOutTagColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return actionColor
        }
        
        return getUIColorFromRGB(230, 144, 90)
    }
    
    public static var iLikeItTagColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return actionColor
        }
        
        return getUIColorFromRGB(227, 102, 95)
    }
    
    public static var releaseYearColor: UIColor {
        return subtitleColor
    }
    
    public static var runtimeColor: UIColor {
        return titleColor
    }
    
    public static var voteCountColor: UIColor {
        return subtitleColor
    }
    
    public static var voteSeparatorColor: UIColor {
        return getUIColorFromRGB(153, 153, 153)
    }
    
    public static var messageColor: UIColor {
        return subtitleColor
    }
    
    public static var overviewColor: UIColor {
        return titleColor
    }
    
    public static var actionColor: UIColor {
        if CinePickerConfig.getTheme() == .light {
            return getUIColorFromRGB(225, 45, 85)
        }
        
        return getUIColorFromRGB(1, 122, 255)
    }
    
    public static var alertBorderColor: UIColor {
        return bottomBarColor
    }
    
    public static var barStyle: UIBarStyle {
        if CinePickerConfig.getTheme() == .light {
            return .default
        }
        
        return .black
    }
    
    public static var statusBarStyle: UIStatusBarStyle {
        if CinePickerConfig.getTheme() == .light {
            return .default
        }
        
        return .lightContent
    }
    
    public static var searchBarKeyboardAppearance: UIKeyboardAppearance {
        if CinePickerConfig.getTheme() == .light {
            return .light
        }
        
        return .dark
    }
    
    public static var agrumeStatusBarStyle: UIStatusBarStyle {
        if CinePickerConfig.getTheme() == .light {
             return .default
        }
        
        return .lightContent
    }
    
    public static var alertCircleBackgroundColor: UInt {
        if CinePickerConfig.getTheme() == .light {
            return 0xB4B4B4
        }
        
        return 0x323232
    }
    
    private static func getUIColorFromRGB(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
        let red = CGFloat(Double(red) / 255.0)
        let green = CGFloat(Double(green) / 255.0)
        let blue = CGFloat(Double(blue) / 255.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
