import UIKit

class PersonListViewController: UIViewController {

    @IBOutlet weak var personListTableView: UITableView!
    
    public var people: [Person]!
    
    private var loadedImages: [String: (image: UIImage, originalImage: UIImage)] = [:]
    
    private let imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineTableView()
    }
    
    private func defineTableView() {
        personListTableView.rowHeight = PersonTableViewCell.standardHeight
        personListTableView.tableFooterView = UIView(frame: .zero)
        
        let personTableViewCellNib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        personListTableView.register(personTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.person)
    }
    
}

extension PersonListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let person = people[indexPath.row]
        
        if person.imagePath.isEmpty {
            return
        }
        
        if loadedImages[person.imagePath] != nil {
            return
        }
        
        var cell = cell as! ImageFromInternet
        
        UIViewHelper.setImagesFromInternet(by: person.imagePath, at: &cell, using: imageService) { (images) in
            self.loadedImages[person.imagePath] = images
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
        let person = people[indexPath.row]
        
        if let (image, originalImage) = loadedImages[person.imagePath] {
            cell.imageValue = image
            cell.originalImageValue = originalImage
        }
        
        cell.onTapImageViewHandler = { (originalImageValue) in
            UIViewHelper.openImage(from: self, image: originalImageValue)
        }
        
        cell.personName = person.name
        
        if let character = person as? Character {
            cell.personPosition = character.characterName
            cell.isPersonPositionValid = !character.isUncredited
        } else if let crewPerson  = person as? CrewPerson {
            cell.personPosition = crewPerson.jobs.joined(separator: ", ")
            cell.isPersonPositionValid = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PersonTableViewCell
        
        if let imageUrl = cell.imageUrl {
            imageService.cancelDownloading(for: imageUrl)
        }
        
        if let originalImageUrl = cell.originalImageUrl {
            imageService.cancelDownloading(for: originalImageUrl)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath)
        
        let sender = TableViewCellSender(cell: cell, indexPath: indexPath)
        
        performSegue(withIdentifier: SegueIdentifiers.showPersonMovies, sender: sender)
    }
    
}

extension PersonListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        loadedImages = [:]
        
        if segueIdentifier == SegueIdentifiers.showPersonMovies {
            let movieListViewController = segue.destination as! MovieListViewController
            let sender = sender as! TableViewCellSender
            
            let indexPath = sender.indexPath
            
            movieListViewController.person = people[indexPath.row]
            
            return
        }
        
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
}
