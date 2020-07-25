struct CodableContact: Codable {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    let address: CodableAddress
    let emergency: String
}
