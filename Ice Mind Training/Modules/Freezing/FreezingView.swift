import SwiftUI
import SwiftData

struct FreezingView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var whatMadeUHappy: String = ""
    @State private var selectedEmotion: PrimaryEmotionFreezingModel = .joy
    @State private var intensity: Double = 3.0

    var wellnessLevel: String {
        switch Int(intensity) {
        case 1, 2:
            return "GOOD"
        case 3:
            return "VERY GOOD"
        case 4, 5:
            return "EXCELLENT"
        default:
            return "VERY GOOD"
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Positive Diary")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Text("❄️")
                        .font(.system(size: 24))
                }
                .padding(.horizontal)
                .padding(.top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // What made you happy section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What made you happy?")
                                .font(.headline)
                                .foregroundColor(.black)

                            TextEditor(text: $whatMadeUHappy)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color(white: 0.95))
                                .cornerRadius(12)
                                .font(.body)
                        }

                        // Primary Emotion section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Primary Emotion")
                                .font(.headline)
                                .foregroundColor(.black)

                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    EmotionButtonFreezing(
                                        title: "Joy",
                                        isSelected: selectedEmotion == .joy
                                    ) {
                                        selectedEmotion = .joy
                                    }

                                    EmotionButtonFreezing(
                                        title: "Gratitude",
                                        isSelected: selectedEmotion == .gratitude
                                    ) {
                                        selectedEmotion = .gratitude
                                    }

                                    EmotionButtonFreezing(
                                        title: "Pride",
                                        isSelected: selectedEmotion == .pride
                                    ) {
                                        selectedEmotion = .pride
                                    }
                                    
                                    Spacer()
                                }

                                HStack(spacing: 8) {
                                    EmotionButtonFreezing(
                                        title: "Calmness",
                                        isSelected: selectedEmotion == .calmness
                                    ) {
                                        selectedEmotion = .calmness
                                    }
                                    
                                    EmotionButtonFreezing(
                                        title: "Inspiration",
                                        isSelected: selectedEmotion == .inspiration
                                    ) {
                                        selectedEmotion = .inspiration
                                    }

                                    Spacer()
                                }
                            }
                        }

                        // Intensity section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Intensity")
                                    .font(.headline)
                                    .foregroundColor(.black)

                                Spacer()

                                Text("\(Int(intensity))/5")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                            }

                            Text(wellnessLevel)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)

                            VStack(spacing: 8) {
                                Slider(value: $intensity, in: 1...5, step: 1)
                                    .tint(Color(red: 0.2, green: 0.5, blue: 1.0))

                                HStack {
                                    Text("Mild")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Spacer()

                                    Text("Intense")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal)
                }

                // Record Event button
                Button(action: recordEvent) {
                    Text("Record Event")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                        .cornerRadius(24)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(whatMadeUHappy.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(whatMadeUHappy.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
        .hideKeyboardOnTap()
    }

    func recordEvent() {
        let freezingModel = FreezingModel(
            whatMadeUHappy: whatMadeUHappy,
            primaryEmotion: selectedEmotion,
            rating: Rating(rawValue: Int(intensity)) ?? .`3`
        )

        modelContext.insert(freezingModel)
        
        // Увеличиваем StressLevelModel на 5%
        let fetchDescriptor = FetchDescriptor<StressLevelModel>()
        if let stressLevel = try? modelContext.fetch(fetchDescriptor).first {
            stressLevel.currentLevel = min(100, stressLevel.currentLevel + 5)
            
            // Записываем обновление в updates
            stressLevel.updates[Date()] = 5
        }
        
        try? modelContext.save()

        // Reset form
        whatMadeUHappy = ""
        selectedEmotion = .joy
        intensity = 3.0
    }
}

// MARK: - Emotion Button
struct EmotionButtonFreezing: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 0.2, green: 0.5, blue: 1.0) : Color(white: 0.93))
                .cornerRadius(20)
        }
    }
}

#Preview {
    FreezingView()
        .modelContainer(for: FreezingModel.self, inMemory: true)
}
