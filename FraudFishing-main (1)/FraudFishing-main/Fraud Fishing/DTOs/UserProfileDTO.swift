
import Foundation


struct UserProfile: Decodable {
    let email: String
    var name: String
}


struct UpdateUserDTO: Codable {
    let name: String?
    let email: String?
    let password: String?
}
