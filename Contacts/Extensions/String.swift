import Foundation

extension String {
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
    
    func removeWhiteSpaces() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    func containsOnlyLetters() -> Bool {
        return rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
    }
    
    func containsOnlyDigits() -> Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func containsOnlyAlphanumerics() -> Bool {
        return rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
    }
    
}
