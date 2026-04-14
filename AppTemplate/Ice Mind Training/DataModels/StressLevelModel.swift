import SwiftData
import Foundation

@Model
class StressLevelModel {
    var id = UUID()
    
    var currentLevel: Int // от 0 до 100
    var updates: [Date: Int]
    
    init(id: UUID = UUID(), currentLevel: Int, updates: [Date : Int]) {
        self.id = id
        self.currentLevel = currentLevel
        self.updates = updates
    }
}
