import UIKit

class PersonListViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var personListTableView: UITableView!
    
    public var people: [Person] = []
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    private var downloadedImages: [String: UIImage] = [:]
    
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
        
        downloadedImages = [:]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            UIViewHelper.closeAlert()
        }
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
        contentUIView.backgroundColor = CinePickerColors.getBackgroundColor()
        topBarView.backgroundColor = CinePickerColors.getTopBarColor()
        personListTableView.backgroundColor = CinePickerColors.getBackgroundColor()
    }
    
    @objc private func onPressActionsButton() {
        let backToSearchAction = {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        UIViewHelper.showAlert(
            traitCollection: traitCollection,
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
        cell.selectedBackgroundView = UIViewHelper.getUITableViewCellSelectedBackgroundView()
        var cell = cell as! ImageFromInternetViewCell
        cell.imagePath = people[indexPath.row].imagePath
        if downloadedImages[cell.imagePath] != nil {
            return
        }
        let cellAdapter = ImageFromInternetViewCellAdapter(cell: cell)
        UIViewHelper.setImageFromInternet(at: cellAdapter, downloadedBy: imageService) { (image) in
            self.downloadedImages[cell.imagePath] = image
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        
        let person = people[indexPath.row]
        
        if let image = downloadedImages[person.imagePath] {
            cell.imageValue = image
        }
        
        if cell.imagePath.isEmpty {
            cell.imagePath = person.imagePath
        }
        
        cell.onTapImageView = { (imagePath) in
            UIViewHelper.openImage(from: self, by: imagePath, using: self.imageService)
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
        
        if let imageUrl = UIViewHelper.buildImageUrl(byImagePath: cell.imagePath) {
            imageService.cancelDownloading(by: imageUrl)
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
