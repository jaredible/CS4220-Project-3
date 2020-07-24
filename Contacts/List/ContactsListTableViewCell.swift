import UIKit
import class ObjectLibrary.Contact

final class ContactsListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emergencyImageView: UIImageView!
    
}

extension ContactsListTableViewCell {
    
    func setup(contact: Contact) {
        titleLabel.attributedText = contact.attributedDisplayText
        emergencyImageView.isHidden = !contact.isEmergencyContact
    }
    
}
