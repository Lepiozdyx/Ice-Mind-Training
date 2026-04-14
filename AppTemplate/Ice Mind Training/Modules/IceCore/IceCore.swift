import SwiftUI
import SwiftData

struct IceCore: View {
    @Query private var stressLevels: [StressLevelModel]
    @Environment(\.modelContext) private var modelContext
    
    var currentStressLevel: Int {
        stressLevels.first?.currentLevel ?? 100
    }
    
    var composureStatus: (title: String, color: Color, textColor: Color) {
        switch currentStressLevel {
        case 80...100:
            return ("STABLE & CLEAR", Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 1.0))
        case 60..<80:
            return ("SLIGHTLY STRESSED", Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 1.0))
        case 30..<60:
            return ("MELTING RAPIDLY", Color(red: 0.9, green: 0.3, blue: 0.2), Color(red: 0.9, green: 0.3, blue: 0.2))
        default:
            return ("CRITICAL BURNOUT RISK", Color(red: 0.9, green: 0.3, blue: 0.2), Color(red: 0.9, green: 0.3, blue: 0.2))
        }
    }
    
    var advice: String {
        switch currentStressLevel {
        case 80...100:
            return "You're keeping your cool perfectly. Keep noticing the positive moments!"
        case 60..<80:
            return "Your ice is starting to crack. Take a deep breath and log what happened."
        case 30..<60:
            return "You're overheating. Do a mindful exercise in the simulator to cool down."
        default:
            return "You're overheating. Do a mindful exercise in the simulator to cool down."
        }
    }
    
    var crackIntensity: Int {
        let level = currentStressLevel
        if level >= 80 {
            return 0
        } else if level >= 60 {
            return 1
        } else if level >= 30 {
            return 2
        } else {
            return 3
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Ice Mind Training")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "house")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                }
                .padding(.horizontal)
                .padding(.top)
                Spacer()
                VStack(spacing: 0) {
                    // Composure Level Text
                    VStack(spacing: 8) {
                        Text("COMPOSURE LEVEL")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                        
                        Text(composureStatus.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(composureStatus.color)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Ice Core Visualization
                    ZStack {
                        VStack(spacing: 0) {
                            ZStack(alignment: .bottom) {
                                // Container фон с тенью
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.75, green: 0.85, blue: 0.96),
                                                Color(red: 0.60, green: 0.75, blue: 0.92)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                                
                                // Трещины сверху
                                VStack(alignment: .center, spacing: 0) {
                                    if crackIntensity >= 1 {
                                        HStack {
                                            Spacer()
                                            
                                            Path { path in
                                                path.move(to: CGPoint(x: 0, y: 0))
                                                path.addCurve(to: CGPoint(x: 15, y: 20),
                                                              control1: CGPoint(x: 5, y: 10),
                                                              control2: CGPoint(x: 10, y: 15))
                                            }
                                            .stroke(Color(red: 0.75, green: 0.85, blue: 0.95), lineWidth: 1)
                                            .frame(width: 20, height: 25)
                                            
                                            Spacer()
                                            
                                            Path { path in
                                                path.move(to: CGPoint(x: 0, y: 0))
                                                path.addCurve(to: CGPoint(x: 20, y: 25),
                                                              control1: CGPoint(x: 5, y: 12),
                                                              control2: CGPoint(x: 15, y: 18))
                                            }
                                            .stroke(Color(red: 0.75, green: 0.85, blue: 0.95), lineWidth: 1)
                                            .frame(width: 25, height: 30)
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 16)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Жидкость снизу
                                VStack {
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.91, green: 0.78, blue: 1.0),
                                                    Color(red: 0.91, green: 0.95, blue: 1.0)
                                                ]),
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .shadow(color: Color(red: 0.55, green: 0.75, blue: 0.95).opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .frame(height: CGFloat(currentStressLevel) / 100.0 * 220)
                                
                                // Капли при критическом уровне
                                if crackIntensity >= 3 {
                                    VStack {
                                        Spacer()
                                        
                                        HStack(spacing: 16) {
                                            Spacer()
                                            
                                            Capsule()
                                                .fill(Color(red: 0.92, green: 0.75, blue: 0.75).opacity(0.5))
                                                .frame(width: 8, height: 14)
                                            
                                            Capsule()
                                                .fill(Color(red: 0.92, green: 0.75, blue: 0.75).opacity(0.5))
                                                .frame(width: 8, height: 14)
                                            
                                            Spacer()
                                        }
                                        .offset(y: 60)
                                    }
                                }
                            }
                            .frame(width: 120, height: 220)
                            .padding(.top, 24.fitH)
                        }
                        Text("\(currentStressLevel)%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    // Today's Advice
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Advice")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                        
                        Text(advice)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(Color(white: 0.96))
                    .cornerRadius(12)
                    .padding(.top, 50.fitH)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            createDefaultStressLevelIfNeeded()
        }
    }
    
    private func createDefaultStressLevelIfNeeded() {
        if stressLevels.isEmpty {
            let newStressLevel = StressLevelModel(
                currentLevel: 100,
                updates: [:]
            )
            modelContext.insert(newStressLevel)
            try? modelContext.save()
        }
    }
}

#Preview {
    IceCore()
        .modelContainer(for: StressLevelModel.self, inMemory: true)
}
