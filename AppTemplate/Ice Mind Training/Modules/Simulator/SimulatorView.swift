import SwiftUI
import SwiftData

struct SimulatorView: View {
    @Query private var stressLevels: [StressLevelModel]
    @Environment(\.modelContext) private var modelContext
    
    @State private var sessionScenarios: [Scenario] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var showResult: Bool = false
    @State private var resultChange: Int = 0
    @State private var resultMessage: String = ""
    @State private var resultIsPositive: Bool = true
    @State private var hasAnsweredAll: Bool = false
    @State private var isSessionStarted: Bool = false

    let allScenarios: [Scenario] = getAllScenarios()

    var body: some View {
        ZStack {
            

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Reaction Trainer")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                }
                .padding()
                .background(Color.white)

                if hasAnsweredAll {
                    // Completion screen
                    VStack(spacing: 20) {
                        Spacer()

                        VStack(spacing: 16) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.green)

                            Text("You answered all the questions ✅")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()

                        Button(action: startNewSession) {
                            Text("Start a new poll")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                } else if showResult {
                    // Result screen
                    VStack(spacing: 20) {
                        Spacer()

                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        resultIsPositive ?
                                        Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.2) :
                                        Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.2)
                                    )
                                    .frame(width: 80, height: 80)

                                Image(systemName: resultIsPositive ? "heart.fill" : "exclamationmark.triangle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(
                                        resultIsPositive ?
                                        Color(red: 0.2, green: 0.5, blue: 1.0) :
                                        Color(red: 0.9, green: 0.2, blue: 0.2)
                                    )
                            }

                            Text("\(resultIsPositive ? "+" : "")\(resultChange)% Ice")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)

                            Text(resultMessage)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(
                            resultIsPositive ?
                            Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.1) :
                            Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.1)
                        )
                        .cornerRadius(16)

                        Button(action: nextSituation) {
                            HStack {
                                Text("Next Situation")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(
                                resultIsPositive ?
                                Color(red: 0.2, green: 0.5, blue: 1.0) :
                                Color(red: 0.9, green: 0.2, blue: 0.2)
                            )
                            .cornerRadius(12)
                        }

                        Spacer()
                    }
                    .padding()
                } else if isSessionStarted && !sessionScenarios.isEmpty && currentQuestionIndex < sessionScenarios.count {
                    // Question screen
                    let scenario = sessionScenarios[currentQuestionIndex]

                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                            .frame(height: 40)

                        VStack(alignment: .leading, spacing: 12) {
                            // Category badge with progress
                            HStack {
                                Text(scenario.category)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.1))
                                    .cornerRadius(16)

                                Spacer()

                                Text("\(currentQuestionIndex + 1)/8")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                            }

                            // Main question
                            Text(scenario.question)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)

                        Spacer()
                            .frame(height: 24)

                        // Response options
                        VStack(spacing: 12) {
                            // Impulse (Bad)
                            Button(action: { selectResponse(-1) }) {
                                HStack {
                                    Text(scenario.impulsiveResponse)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)

                                    Spacer()

                                    Image(systemName: "arrow.right.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color(white: 0.96))
                                .cornerRadius(12)
                            }

                            // Conscious (Good)
                            Button(action: { selectResponse(1) }) {
                                HStack {
                                    Text(scenario.consciousResponse)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)

                                    Spacer()

                                    Image(systemName: "arrow.right.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(Color(white: 0.96))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                } else {
                    // Loading screen or empty state
                    VStack(spacing: 20) {
                        Spacer()

                        VStack(spacing: 16) {
                            Image(systemName: "bolt.circle")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))

                            Text("Ready to train your reactions?")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()

                        Button(action: startNewSession) {
                            Text("Start a new poll")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                }
            }
        }
        .bg()
        .onAppear {
            ensureStressLevelModelExists()
        }
    }

    func ensureStressLevelModelExists() {
        if stressLevels.isEmpty {
            let newStressLevel = StressLevelModel(currentLevel: 50, updates: [:])
            modelContext.insert(newStressLevel)
            try? modelContext.save()
        } else {
        }
    }

    func startNewSession() {
        let shuffled = allScenarios.shuffled()
        sessionScenarios = Array(shuffled.prefix(8))
        currentQuestionIndex = 0
        showResult = false
        hasAnsweredAll = false
        isSessionStarted = true
    }

    func selectResponse(_ change: Int) {
        resultChange = change
        resultIsPositive = change > 0

        resultMessage = resultIsPositive ?
            "You chose mindfulness and calm!" :
            "Impulse melts your ice."

        updateStressLevel(change)
        showResult = true
    }

    func nextSituation() {
        if currentQuestionIndex < 7 {
            currentQuestionIndex += 1
            showResult = false
        } else {
            hasAnsweredAll = true
        }
    }

    func updateStressLevel(_ change: Int) {
        if let stressLevel = stressLevels.first {
            
            var newLevel = stressLevel.currentLevel + change
            newLevel = max(0, min(100, newLevel))

            stressLevel.currentLevel = newLevel
            stressLevel.updates[Date()] = change

            do {
                try modelContext.save()
            } catch {
                print("❌ Save failed: \(error)")
            }
        } else {
            print("❌ No StressLevelModel found to update")
        }
    }
}

// MARK: - Scenario Model
struct Scenario {
    let category: String
    let question: String
    let impulsiveResponse: String
    let consciousResponse: String
}

// MARK: - All Scenarios (40 total)
func getAllScenarios() -> [Scenario] {
    return [
        // Category 1: Work and Deadlines (8)
        Scenario(category: "🏢 Work and Deadlines", question: "The deadline is approaching fast", impulsiveResponse: "Panic and blame everyone", consciousResponse: "Break the task into smaller tasks and start"),
        Scenario(category: "🏢 Work and Deadlines", question: "Boss criticizes your work", impulsiveResponse: "Make excuses and get angry", consciousResponse: "Listen and take what's useful"),
        Scenario(category: "🏢 Work and Deadlines", question: "Error in the report", impulsiveResponse: "Hide it and hope for the best", consciousResponse: "Admit and fix it right away"),
        Scenario(category: "🏢 Work and Deadlines", question: "Colleague interrupted you", impulsiveResponse: "Say loudly \"Be quiet\"", consciousResponse: "Politely continue your thought"),
        Scenario(category: "🏢 Work and Deadlines", question: "Difficult client", impulsiveResponse: "Be rude in the chat", consciousResponse: "Offer a solution to the problem"),
        Scenario(category: "🏢 Work and Deadlines", question: "Meeting is cancelled", impulsiveResponse: "Get angry about wasted time", consciousResponse: "Use time for rest"),
        Scenario(category: "🏢 Work and Deadlines", question: "Overloaded with tasks", impulsiveResponse: "Take everything and burn out", consciousResponse: "Discuss priorities with your lead"),
        Scenario(category: "🏢 Work and Deadlines", question: "Technical failure", impulsiveResponse: "Hit the keyboard", consciousResponse: "Restart and call IT"),

        // Category 2: Relationships & Family (8)
        Scenario(category: "🤝 Relationships & Family", question: "Your partner forgot the date", impulsiveResponse: "Create a scandal", consciousResponse: "Remind them with a smile"),
        Scenario(category: "🤝 Relationships & Family", question: "Parents preaching again", impulsiveResponse: "Slam the door", consciousResponse: "Listen and nod"),
        Scenario(category: "🤝 Relationships & Family", question: "Friend is late", impulsiveResponse: "Yell at them", consciousResponse: "Ask if everything is okay"),
        Scenario(category: "🤝 Relationships & Family", question: "Argument over nothing", impulsiveResponse: "Sulk for three days", consciousResponse: "Suggest to talk"),
        Scenario(category: "🤝 Relationships & Family", question: "Guest without warning", impulsiveResponse: "Kick them out rudely", consciousResponse: "Accept but set a time limit"),
        Scenario(category: "🤝 Relationships & Family", question: "Plans cancelled by loved one", impulsiveResponse: "Stay offended forever", consciousResponse: "Suggest a new date"),
        Scenario(category: "🤝 Relationships & Family", question: "Criticism of your appearance", impulsiveResponse: "Withdraw into yourself", consciousResponse: "Say \"I'm comfortable this way\""),
        Scenario(category: "🤝 Relationships & Family", question: "Relatives need help", impulsiveResponse: "Refuse sharply", consciousResponse: "Explain your boundaries"),

        // Category 3: City & Unexpected Situations (8)
        Scenario(category: "🚗 City & Unexpected", question: "Someone cut you off on the road", impulsiveResponse: "Signal and seek revenge", consciousResponse: "Let it go and take a breath"),
        Scenario(category: "🚗 City & Unexpected", question: "Missed the bus", impulsiveResponse: "Kick the stop", consciousResponse: "Order a taxi and relax"),
        Scenario(category: "🚗 City & Unexpected", question: "Spilled coffee on yourself", impulsiveResponse: "Curse all day", consciousResponse: "Wipe and forget"),
        Scenario(category: "🚗 City & Unexpected", question: "Forgot keys at home", impulsiveResponse: "Blame yourself for an hour", consciousResponse: "Call a locksmith"),
        Scenario(category: "🚗 City & Unexpected", question: "Rain without umbrella", impulsiveResponse: "Run and get angry", consciousResponse: "Walk and enjoy it"),
        Scenario(category: "🚗 City & Unexpected", question: "Lost something valuable", impulsiveResponse: "Search in panic", consciousResponse: "Stop and try to remember"),
        Scenario(category: "🚗 City & Unexpected", question: "Long line in the store", impulsiveResponse: "Push and complain", consciousResponse: "Put on headphones and wait"),
        Scenario(category: "🚗 City & Unexpected", question: "Elevator is stuck", impulsiveResponse: "Panic in the cabin", consciousResponse: "Press the call button and wait"),

        // Category 4: Well-Being & Health (8)
        Scenario(category: "🧘 Well-Being & Health", question: "Overslept your workout", impulsiveResponse: "Quit sports altogether", consciousResponse: "Do a workout at home"),
        Scenario(category: "🧘 Well-Being & Health", question: "Ate too much", impulsiveResponse: "Start a hunger strike", consciousResponse: "Return to normal tomorrow"),
        Scenario(category: "🧘 Well-Being & Health", question: "Can't sleep", impulsiveResponse: "Scroll feeds until morning", consciousResponse: "Read a book in soft light"),
        Scenario(category: "🧘 Well-Being & Health", question: "Feeling tired", impulsiveResponse: "Load yourself with coffee", consciousResponse: "Allow yourself a 20-min nap"),
        Scenario(category: "🧘 Well-Being & Health", question: "Can't focus on work", impulsiveResponse: "Force yourself hard", consciousResponse: "Take a break and go for a walk"),
        Scenario(category: "🧘 Well-Being & Health", question: "Comparing yourself to others", impulsiveResponse: "Belittle yourself mentally", consciousResponse: "Remember your wins"),
        Scenario(category: "🧘 Well-Being & Health", question: "Fear of making mistakes", impulsiveResponse: "Paralyze yourself", consciousResponse: "Allow yourself to try"),
        Scenario(category: "🧘 Well-Being & Health", question: "Lonely evening", impulsiveResponse: "Stress-eat", consciousResponse: "Call a friend or do a hobby"),

        // Category 5: Social Media & Information (8)
        Scenario(category: "🌐 Social Media & Information", question: "Hate in the comments", impulsiveResponse: "Start a war", consciousResponse: "Block and forget"),
        Scenario(category: "🌐 Social Media & Information", question: "Bad news everywhere", impulsiveResponse: "Scroll for 2 hours", consciousResponse: "Turn off phone for an hour"),
        Scenario(category: "🌐 Social Media & Information", question: "Ignored in chat", impulsiveResponse: "Send 5 more messages", consciousResponse: "Do something and wait"),
        Scenario(category: "🌐 Social Media & Information", question: "Someone else's success", impulsiveResponse: "Feel envious", consciousResponse: "Be happy for them"),
        Scenario(category: "🌐 Social Media & Information", question: "Internet argument", impulsiveResponse: "Argue until night", consciousResponse: "Exit the discussion"),
        Scenario(category: "🌐 Social Media & Information", question: "Fake news", impulsiveResponse: "Share with friends", consciousResponse: "Check the source"),
        Scenario(category: "🌐 Social Media & Information", question: "Phone addiction", impulsiveResponse: "Blame yourself", consciousResponse: "Put it away and work"),
        Scenario(category: "🌐 Social Media & Information", question: "Notifications at night", impulsiveResponse: "Check immediately", consciousResponse: "Ignore until morning"),
    ]
}

#Preview {
    SimulatorView()
        .modelContainer(for: StressLevelModel.self, inMemory: true)
}
