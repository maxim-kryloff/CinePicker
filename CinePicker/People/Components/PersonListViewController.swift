import UIKit

class PersonListViewController: UIViewController {
    
    @IBOutlet var contentUIView: UIView!
    
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var personListTableView: UITableView!
    
    public var people: [Person] = []
    
    private var actionsBarButtonItem: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        personListTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineNavigationController()
        defineMoreButton()
        defineTableView()
        registerPersonTableViewCell()
        setDefaultColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            UIViewUtilsFactory.shared.getAlertUtils().closeAlert()
        }
    }
    
    private func defineNavigationController() {
        navigationItem.backBarButtonItem = UIViewUtilsFactory.shared.getViewUtils().getBackBarButtonItem()
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
    }
    
    private func registerPersonTableViewCell() {
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
        UIViewUtilsFactory.shared.getAlertUtils().showAlert(
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
        let cell = cell as! PersonTableViewCell
        setPersonTableViewCellImageProperties(cell: cell, indexPath: indexPath)
    }
    
    private func setPersonTableViewCellImageProperties(cell: PersonTableViewCell, indexPath: IndexPath) {
        cell.imagePath = people[indexPath.row].imagePath
        cell.onTapImageView = { (imagePath) in
            UIViewUtilsFactory.shared.getImageUtils().openImage(from: self, by: imagePath)
        }
        UIViewUtilsFactory.shared.getImageUtils().setImageFromInternet(at: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.person, for: indexPath) as! PersonTableViewCell
        setPersonTableViewCellProperties(cell: cell, indexPath: indexPath)
        cell.selectedBackgroundView = UIViewUtilsFactory.shared.getViewUtils().getUITableViewCellSelectedBackgroundView()
        return cell
    }
    
    private func setPersonTableViewCellProperties(cell: PersonTableViewCell, indexPath: IndexPath) {
        let person = people[indexPath.row]
        cell.personName = person.name
        if let character = person as? Character {
            cell.personPosition = character.characterName
            cell.personPositionIsValid = !character.isUncredited
        } else if let crewPerson  = person as? CrewPerson {
            cell.personPosition = crewPerson.jobs.joined(separator: ", ")
            cell.personPositionIsValid = true
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
            setMovieListControllerProperties(for: segue, sender: sender)
            return
        }
        fatalError("Unexpected Segue Identifier: \(segueIdentifier)")
    }
    
    private func setMovieListControllerProperties(for segue: UIStoryboardSegue, sender: Any?) {
        let movieListViewController = segue.destination as! MovieListViewController
        let sender = sender as! TableViewCellSender
        movieListViewController.person = people[sender.indexPath.row]
    }
}
