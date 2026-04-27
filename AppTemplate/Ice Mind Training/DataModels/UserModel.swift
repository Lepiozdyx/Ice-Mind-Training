import SwiftData
import Foundation

@Model
class UserModel {
    var id = UUID()
    
    var name: String
    var icon: String
    var photoData: Data?
    
    init(id: UUID = UUID(), name: String = "User", icon: String = "icon1") {
        self.id = id
        self.name = name
        self.icon = icon
    }
}
