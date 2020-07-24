import UIKit
import class ObjectLibrary.Contact

final class ContactsListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var model: ContactsListModel!
    private let searchController = UISearchController(searchResultsController: nil)
    private var isFiltering: Bool { searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = ContactsListModel()
        configureSearchController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let contactDetailViewController = segue.destination as? ContactDetailViewController else { return }
        let contact = sender as? Contact ?? Contact.instance()
        let model = ContactDetailModel(contact: contact, delegate: contactDetailViewController)
        contactDetailViewController.setup(model: model, delegate: self)
    }
    
}

extension ContactsListViewController {
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}

extension ContactsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetail", sender: model.contact(for: indexPath, isFiltering: isFiltering))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ContactsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = model.numberOfSections(isFiltering: isFiltering)
        
        if numberOfSections == 0 {
            tableView.addEmptyListLabel(withText: "No Contacts", adjustSeparatorStyle: true)
        } else {
            tableView.removeEmptyListLabel()
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(in: section, isFiltering: isFiltering)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact") as! ContactsListTableViewCell
        cell.setup(contact: model.contact(for: indexPath, isFiltering: isFiltering))
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.titleForHeader(in: section, isFiltering: isFiltering)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return model.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return model.section(for: title, index: index, isFiltering: isFiltering)
    }
    
}

extension ContactsListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        model.filterContentForSearchText(text)
        tableView.reloadData()
    }
    
}

extension ContactsListViewController: ContactDetailViewControllerDelegate {
    
    func add(_ contact: Contact) {
        model.add(contact)
        updateSearchResults(for: searchController)
        navigationController?.popViewController(animated: true)
    }
    
    func remove(_ contact: Contact) {
        model.remove(contact)
        updateSearchResults(for: searchController)
        navigationController?.popViewController(animated: true)
    }
    
}
