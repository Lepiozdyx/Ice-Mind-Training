import SwiftUI
import SwiftData

struct MeltingView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var whatsHappened: String = ""
    @State private var selectedEmotion: PrimaryEmotion = .anger
    @State private var intensity: Double = 3.0
    @State private var showSuccessMessage = false

    var stressLevel: String {
        switch Int(intensity) {
        case 1, 2:
            return "MILD STRESS"
        case 3:
            return "MODERATE STRESS"
        case 4, 5:
            return "SEVERE STRESS"
        default:
            return "MODERATE STRESS"
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Stress Diary")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Text("🔥")
                        .font(.system(size: 24))
                }
                .padding(.horizontal)
                .padding(.top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // What happened section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What happened?")
                                .font(.headline)
                                .foregroundColor(.black)

                            TextEditor(text: $whatsHappened)
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
                                    EmotionButton(
                                        title: "Anger",
                                        isSelected: selectedEmotion == .anger
                                    ) {
                                        selectedEmotion = .anger
                                    }

                                    EmotionButton(
                                        title: "Anxiety",
                                        isSelected: selectedEmotion == .anxiety
                                    ) {
                                        selectedEmotion = .anxiety
                                    }

                                    EmotionButton(
                                        title: "Resentment",
                                        isSelected: selectedEmotion == .resentment
                                    ) {
                                        selectedEmotion = .resentment
                                    }
                                    Spacer()
                                }

                                HStack(spacing: 8) {
                                    EmotionButton(
                                        title: "Fatigue",
                                        isSelected: selectedEmotion == .fatigue
                                    ) {
                                        selectedEmotion = .fatigue
                                    }

                                    EmotionButton(
                                        title: "Disappointment",
                                        isSelected: selectedEmotion == .disappointment
                                    ) {
                                        selectedEmotion = .disappointment
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
                                    .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                            }

                            Text(stressLevel)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)

                            VStack(spacing: 8) {
                                Slider(value: $intensity, in: 1...5, step: 1)
                                    .tint(Color(red: 0.9, green: 0.2, blue: 0.2))

                                HStack {
                                    Text("Mild")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Spacer()

                                    Text("Severe")
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
                        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
                        .cornerRadius(24)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(whatsHappened.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(whatsHappened.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
        .hideKeyboardOnTap()
    }

    func recordEvent() {
        let meltingModel = MeltingModel(
            whatsHappend: whatsHappened,
            primaryEmotion: selectedEmotion,
            rating: Rating(rawValue: Int(intensity)) ?? .`3`
        )

        modelContext.insert(meltingModel)
        
        // Уменьшаем StressLevelModel на 5%
        let fetchDescriptor = FetchDescriptor<StressLevelModel>()
        if let stressLevel = try? modelContext.fetch(fetchDescriptor).first {
            stressLevel.currentLevel = max(0, stressLevel.currentLevel - 5)
            
            // Записываем обновление в updates
            stressLevel.updates[Date()] = -5
        }
        
        try? modelContext.save()

        // Reset form
        whatsHappened = ""
        selectedEmotion = .anger
        intensity = 3.0
        showSuccessMessage = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSuccessMessage = false
        }
    }
}

// MARK: - Emotion Button
struct EmotionButton: View {
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
                .background(isSelected ? Color(red: 0.9, green: 0.2, blue: 0.2) : Color(white: 0.93))
                .cornerRadius(20)
        }
    }
}

#Preview {
    MeltingView()
        .modelContainer(for: MeltingModel.self, inMemory: true)
}
