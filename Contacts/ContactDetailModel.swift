import struct Foundation.UUID
import class ObjectLibrary.Contact
import enum ObjectLibrary.State
import enum ObjectLibrary.InputField

protocol ContactDetailModelDelegate: class {
    func save(isEnabled: Bool)
}

final class ContactDetailModel {
    
    private(set) var contact: Contact
    private weak var delegate: ContactDetailModelDelegate?
    private(set) var stateOptions: [(String, String)] = []
    
    init(contact: Contact, delegate: ContactDetailModelDelegate) {
        self.contact = contact
        self.delegate = delegate
        
        stateOptions.append(("--", ""))
        for state in State.allCases {
            stateOptions.append((state.rawValue, state.postalAbbreviation))
        }
    }
    
    func updateContact(value: String?, for type: InputField) {
        contact = contact.copy(withNewValue: value ?? "", for: type)
        updateSave()
    }
    
    private func updateSave() {
        delegate?.save(isEnabled: isValid(contact: contact))
    }
    
    func getInputText(for type: InputField) -> String {
        if type == InputField.state {
            guard
                let value = contact.value(for: InputField.state),
                let state = State(rawValue: value)
            else { return "" }
            
            return state.postalAbbreviation
        }
        
        return contact.value(for: type) ?? ""
    }
    
    func getStateOptionIndex() -> Int {
        guard
            let value = contact.value(for: InputField.state),
            let state = State(rawValue: value),
            let stateIndex = State.allCases.firstIndex(of: state)
        else { return 0 }
        
        return stateIndex + 1
    }
    
    func getEmergencyFlag() -> Bool {
        return contact.value(for: InputField.emergency)?.boolValue ?? false
    }
    
}

extension ContactDetailModel {
    
    private func isValid(contact: Contact) -> Bool {
        guard !contact.isEmpty else { return false }
        
        for section in InputField.sections {
            for field in section {
                guard let value = contact.value(for: field) else { continue }
                guard field.isValid(value: value) else { return false }
            }
        }
        
        return true
    }
    
}
