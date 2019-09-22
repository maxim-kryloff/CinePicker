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
    
    public static var selectLanguage: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Выбрать язык"
        }
        
        return "Select Language"
    }
    
    public static var chooseTheme: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Выбрать тему"
        }
        
        return "Choose Theme"
    }
    
    public static var discover: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Поиск"
        }
        
        return "Discover"
    }
    
    public static var discoverResults: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Результаты поиска"
        }
        
        return "Discover Results"
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
    
    public static var lightTheme: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Светлая тема"
        }
        
        return "Light"
    }
    
    public static var darkTheme: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Темная тема"
        }
        
        return "Dark"
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
    
    public static var genres: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Жанры"
        }
        
        return "Genres"
    }
    
    public static var year: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Год"
        }
        
        return "Year"
    }
    
    public static var rating: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Рейтинг"
        }
        
        return "Rating"
    }
    
    public static var search: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Искать"
        }
        
        return "Search"
    }
    
    public static var high: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Высокий"
        }
        
        return "High"
    }
    
    public static var medium: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Средний"
        }
        
        return "Medium"
    }
    
    public static var lowNone: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "Низкий / Отсутствует"
        }
        
        return "Low / None"
    }
    
    public static var min: String {
        if CinePickerConfig.getLanguage() == .ru {
            return "мин"
        }
        
        return "min"
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
