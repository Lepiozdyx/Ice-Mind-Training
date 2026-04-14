import SwiftData
import Foundation

@Model
class FreezingModel {
    var id = UUID()
    var date = Date()
    
    var whatMadeUHappy: String
    var primaryEmotion: PrimaryEmotionFreezingModel
    var rating: Rating
    
    init(id: UUID = UUID(), date: Date = Date(), whatMadeUHappy: String, primaryEmotion: PrimaryEmotionFreezingModel, rating: Rating) {
        self.id = id
        self.date = date
        self.whatMadeUHappy = whatMadeUHappy
        self.primaryEmotion = primaryEmotion
        self.rating = rating
    }
}

enum PrimaryEmotionFreezingModel: String, CaseIterable, Codable {
    case joy, gratitude, pride, calmness, inspiration
}
