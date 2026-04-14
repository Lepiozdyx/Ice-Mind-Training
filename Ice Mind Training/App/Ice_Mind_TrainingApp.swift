import SwiftUI
import SwiftData

struct Ice_Mind_TrainingApp: View {
    var body: some View {
        TabBarView()
            .preferredColorScheme(.light)
            .modelContainer(for: [
                MeltingModel.self,
                FreezingModel.self,
                StressLevelModel.self,
            ])
    }
}
