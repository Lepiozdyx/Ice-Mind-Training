import Foundation
import SwiftData

@Model
class MeltingModel {
    var id = UUID()
    var date = Date()
    
    var whatsHappend: String
    var primaryEmotion: PrimaryEmotion
    var rating: Rating
    
    init(id: UUID = UUID(), date: Date = Date(), whatsHappend: String, primaryEmotion: PrimaryEmotion, rating: Rating) {
        self.id = id
        self.date = date
        self.whatsHappend = whatsHappend
        self.primaryEmotion = primaryEmotion
        self.rating = rating
    }
}

enum PrimaryEmotion: String, CaseIterable, Codable {
    case anger, anxiety, resentment, fatigue, disappointment
}

enum Rating: Int, CaseIterable, Codable {
    case `1` = 1
    case `2` = 2
    case `3` = 3
    case `4` = 4
    case `5` = 5
}
