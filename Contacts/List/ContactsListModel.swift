import UIKit
import class ObjectLibrary.Contact

final class ContactsListModel {
    
    private let collation = UILocalizedIndexedCollation.current()
    private var contacts: [Contact] = [] { didSet { sortSections() }}
    private var sections: [Section] = []
    private var filteredSections: [Section] = []
    
    var sectionIndexTitles: [String] { collation.sectionIndexTitles }
    
    init() {
        loadContacts()
    }
    
    func contact(for indexPath: IndexPath, isFiltering: Bool) -> Contact {
        return sections(for: isFiltering)[indexPath.section].contacts[indexPath.row]
    }
    
    func numberOfSections(isFiltering: Bool) -> Int {
        return sections(for: isFiltering).count
    }
    
    func numberOfRows(in section: Int, isFiltering: Bool) -> Int {
        return sections(for: isFiltering)[section].contacts.count
    }
    
    func titleForHeader(in section: Int, isFiltering: Bool) -> String? {
        guard contacts.count > 5 else { return nil }
        
        return sections(for: isFiltering)[section].title
    }
    
    func section(for title: String, index: Int, isFiltering: Bool) -> Int {
        return sections(for: isFiltering).firstIndex(where: { $0.title == title }) ?? index
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let searchTerms = searchText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { $0 != "" }
        
        filteredSections = sections.compactMap { $0.filtered(by: searchTerms) }
    }
    
    func add(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
        } else {
            contacts.append(contact)
        }
    }
    
    func remove(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts.remove(at: index)
        }
    }
    
}

extension ContactsListModel {
    
    private func sections(for isFiltering: Bool) -> [Section] {
        return isFiltering ? filteredSections : sections
    }
    
    private func sortSections() {
        let selector: Selector = #selector(getter: Contact.collationString)
        //swiftlint:disable:next force_cast
        let sortedContacts = collation.sortedArray(from: contacts, collationStringSelector: selector) as! [Contact]
        let sectionedContacts: [[Contact]] = sortedContacts.reduce(into: Array(repeating: [], count: collation.sectionTitles.count)) {
            let index = collation.section(for: $1, collationStringSelector: selector)
            
            $0[index].append($1)
        }
        
        sections = collation.sectionTitles.enumerated().compactMap {
            let contacts = sectionedContacts[$0.offset]
            return Section(title: $0.element, contacts: contacts)
        }
    }
    
}

extension ContactsListModel {
    
    private struct Section {
        let title: String
        let contacts: [Contact]
        
        init?(title: String, contacts: [Contact]) {
            guard !contacts.isEmpty else { return nil }
            
            self.title = title
            self.contacts = contacts
        }

        func filtered(by searchTerms: [String]) -> Section? {
            let contacts = self.contacts.filter { $0.searchableStrings.containsAll(elements: searchTerms) }
            return Section(title: title, contacts: contacts)
        }
    }
    
}

extension ContactsListModel {
    
    private func loadContacts() {
        if let url = Bundle.main.url(forResource: "contacts", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(CodableContacts.self, from: data)
                for contactData in jsonData.contacts {
                    var contact = Contact.instance()
                    contact = contact.copy(withNewValue: contactData.firstName, for: InputField.firstName)
                    contact = contact.copy(withNewValue: contactData.lastName, for: InputField.lastName)
                    contact = contact.copy(withNewValue: contactData.phone, for: InputField.phone)
                    contact = contact.copy(withNewValue: contactData.email, for: InputField.email)
                    contact = contact.copy(withNewValue: contactData.address.street, for: InputField.street)
                    contact = contact.copy(withNewValue: contactData.address.apartment, for: InputField.apartment)
                    contact = contact.copy(withNewValue: contactData.address.city, for: InputField.city)
                    contact = contact.copy(withNewValue: contactData.address.state, for: InputField.state)
                    contact = contact.copy(withNewValue: contactData.address.zipcode, for: InputField.zipcode)
                    contact = contact.copy(withNewValue: contactData.emergency, for: InputField.emergency)
                    add(contact)
                }
            } catch {
                print(error)
            }
        }
    }
    
}
