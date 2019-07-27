class CinePickerCaptions {
    
    public static var wontCheckItOut: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Не буду смотреть"
        }
        
        return "Won't check it out"
    }
    
    public static var goToFullCast: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Все актеры"
        }
        
        return "Go to Full Cast"
    }
    
    public static var goToFullCrew: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Съемочная группа"
        }
        
        return "Go to Full Crew"
    }
    
    public static var cast: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Актер"
        }
        
        return "Cast"
    }
    
    public static var crew: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Участник съемок"
        }
        
        return "Crew"
    }
    
    public static var loadingData: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Загрузка данных..."
        }
        
        return "Loading data..."
    }
    
    public static var couldntReloadData: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Ошибка загрузки данных..."
        }
        
        return "Couldn't load data..."
    }
    
    public static var reload: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Загрузить"
        }
        
        return "Reload"
    }
    
    public static var thereIsNoDataFound: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Данные не найдены..."
        }
        
        return "There is no data found..."
    }
    
    public static var thereAreNoMoviesFound: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Фильмы не найдены..."
        }
        
        return "There are no movies found..."
    }
    
    public static var more: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Еще"
        }
        
        return "More"
    }
    
    public static var lang: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Язык"
        }
        
        return "Lang"
    }
    
    public static var typeMovieOrActor: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Название фильма, имя актера..."
        }
        
        return "Type movie or actor..."
    }
    
    public static var savedMovies: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Сохраненные"
        }
        
        return "Saved Movies"
    }
    
    public static var eraseSavedMovies: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Очистить список фильмов"
        }
        
        return "Erase Saved Movies"
    }
    
    public static var english: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Английский язык"
        }
        
        return "English"
    }
    
    public static var russian: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Русский язык"
        }
        
        return "Russian"
    }
    
    public static var backToSearch: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Назад к поиску"
        }
        
        return "Back to Search"
    }
    
    public static var goToSimilarMovies: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Похожие фильмы"
        }
        
        return "Go to Similar Movies"
    }
    
    public static var back: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Назад"
        }
        
        return "Back"
    }
    
    public static var cancel: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Отмена"
        }
        
        return "Cancel"
    }
    
    public static var alsoInSeries: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Другие части"
        }
        
        return "Also in Series"
    }
    
    public static func movies(ofPerson personName: String) -> String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Фильмы \(personName)"
        }
        
        return "\(personName)'s Movies"
    }
    
    public static func moviesSimilar(to movieTitle: String) -> String {
        if CinePickerConfig.getLanguage() == .ru {
            return "\(movieTitle). Похожие фильмы"
        }
        
        return "Similar to \(movieTitle)"
    }
    
}
