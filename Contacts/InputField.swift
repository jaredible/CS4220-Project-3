import Foundation
import enum ObjectLibrary.InputField
import enum ObjectLibrary.State

extension InputField {
    
    func isValid(value: String) -> Bool {
        switch self {
        case .firstName, .lastName:
            return value.count >= 2
        case .phone:
            return value.count >= 7 && value.isInt
        case .email:
            return value.contains(elements: ["@"])
        case .street:
            return value.count >= 3 && value.removeWhiteSpaces().containsOnlyAlphanumerics()
        case .apartment:
            return value.count >= 1 && value.removeWhiteSpaces().containsOnlyAlphanumerics()
        case .city:
            return value.count >= 3 && value.removeWhiteSpaces().containsOnlyLetters()
        case .state:
            return State(rawValue: value) != nil
        case .zipcode:
            return value.count == 5 && value.containsOnlyDigits()
        case .emergency:
            return true
        }
    }
    
}
