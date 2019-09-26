import UIKit

class PersonListViewController: UIViewController {

    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var personListTableView: UITableView!
    
    public var people: [Person] = []
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var loadedImages: [String: UIImage] = [:]
    
    private let imageService = ImageService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        personListTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defineNavigationController()
        defineMoreButton()
        defineTableView()
        
        setDefaultColors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        loadedImages = [:]
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.back, style: .plain, target: nil, action: nil
        )
    }
    
    private func defineMoreButton() {
        actionsBarButtonItem = UIBarButtonItem(
            title: CinePickerCaptions.more,
            style: .plain,
            target: self,
            action: #selector(PersonListViewController.onPressActionsButton)
        )
        
        navigationItem.rightBarButtonItem = actionsBarButtonItem
    }
    
    private func defineTableView() {
        personListTableView.rowHeight = PersonTableViewCell.standardHeight
        personListTableView.tableFooterView = UIView(frame: .zero)
        
        let personTableViewCellNib = UINib(nibName: "PersonTableViewCell", bundle: nil)
        personListTableView.register(personTableViewCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.person)
    }
    
    private func setDefaultColors() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
        topBarView.backgroundColor = CinePickerColors.getTopBarColor(userInterfaceStyle: userInterfaceStyle)
        personListTableView.backgroundColor = CinePickerColors.getBackgroundColor(userInterfaceStyle: userInterfaceStyle)
    }
    
    @objc private func onPressActionsButton() {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        UIViewHelper.showAlert(
            userInterfaceStyle: userInterfaceStyle,
            buttonActions: [
                (title: CinePickerCaptions.backToSearch, action: backToSearchAction)
            ]
        )
    }
    
}

extension PersonListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView(userInterfaceStyle: userInterfaceStyle)
        
        let imagePath = people[indexPath.row].imagePath
        
        if imagePath.isEmpty {
            return
        }
        
        if loadedImages[imagePath] != nil {
            return
        }
        
        var cell = cell as! ImageFromInternet
        
        UIViewHelper.setImageFromInternet(by: imagePath, at: &cell, using: imageService) { (image) in
            self.loadedImages[imagePath] = image
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
        let person = people[indexPath.row]
        
        if let image = loadedImages[person.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = person.imagePath
        }
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        cell.onTapImageViewHandler = { (imagePath) in
            UIViewHelper.openImage(from: self, by: imagePath, using: self.imageService, userInterfaceStyle: userInterfaceStyle)
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
