import Foundation

class CinePickerConfig {

    public static let apiPath = "https://api.themoviedb.org/3"
    
    public static let imagePath = "https://image.tmdb.org/t/p/original"
    
    public static let apiToken = ""
    
    public static func getLanguage() -> String {
        return UserDefaults.standard.string(forKey: "Language") ?? "en-US"
    }

}
