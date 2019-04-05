import Foundation

class CinePickerConfig {

    public static let apiPath = "https://api.themoviedb.org/3"
    
    public static let imagesPath = "https://image.tmdb.org/t/p/w185"
    
    public static let apiToken = ""
    
    public static func getLanguage() -> String {
        return UserDefaults.standard.string(forKey: "Language") ?? "en-US"
    }
    
    public static func getLanguageShortcut() -> String {
        let currentLanguage = getLanguage()
        
        switch currentLanguage {
        case "en-US": return "EN"
        case "ru-RU": return "RU"
        case "fr-FR": return "FR"
        case "de-DE": return "DE"
        case "it-IT": return "IT"
        default: fatalError("Unexpected language code: \(currentLanguage)")
        }
    }

}
