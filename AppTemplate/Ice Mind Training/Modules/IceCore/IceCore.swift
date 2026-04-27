import SwiftUI
import SwiftData
import PhotosUI

struct IceCore: View {
    @Query private var stressLevels: [StressLevelModel]
    @Query private var users: [UserModel]
    @Query private var freezings: [FreezingModel]
    @Query private var meltings: [MeltingModel]
    @Environment(\.modelContext) private var modelContext

    @State private var showProfileSheet = false

    var currentUser: UserModel? { users.first }

    var currentStressLevel: Int {
        stressLevels.first?.currentLevel ?? 100
    }

    var composureStatus: (title: String, color: Color) {
        switch currentStressLevel {
        case 80...100:
            return ("STABLE & CLEAR", Color(red: 0.2, green: 0.5, blue: 1.0))
        case 60..<80:
            return ("SLIGHTLY STRESSED", Color(red: 0.2, green: 0.5, blue: 1.0))
        case 30..<60:
            return ("MELTING RAPIDLY", Color(red: 0.9, green: 0.3, blue: 0.2))
        default:
            return ("CRITICAL BURNOUT RISK", Color(red: 0.9, green: 0.3, blue: 0.2))
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
        if level >= 80 { return 0 }
        else if level >= 60 { return 1 }
        else if level >= 30 { return 2 }
        else { return 3 }
    }

    // Stats
    var daysActive: Int {
        guard let stress = stressLevels.first, !stress.updates.isEmpty else { return 0 }
        let uniqueDays = Set(stress.updates.keys.map { Calendar.current.startOfDay(for: $0) })
        return uniqueDays.count
    }

    var avgIceLevel: Int {
        guard let stress = stressLevels.first, !stress.updates.isEmpty else {
            return currentStressLevel
        }
        let values = stress.updates.values
        return values.reduce(0, +) / values.count
    }

    // Recent freezing entries (positive moments)
    var recentFreezings: [FreezingModel] {
        freezings.sorted { $0.date > $1.date }.prefix(3).map { $0 }
    }

    // Emotion icon mapping for FreezingModel
    func freezingEmotionIcon(_ emotion: PrimaryEmotionFreezingModel) -> (sfSymbol: String, color: Color) {
        switch emotion {
        case .joy:          return ("sun.max.fill",        Color(red: 1.0, green: 0.75, blue: 0.2))
        case .gratitude:    return ("heart.fill",          Color(red: 0.95, green: 0.4, blue: 0.5))
        case .pride:        return ("star.fill",           Color(red: 0.6, green: 0.4, blue: 1.0))
        case .calmness:     return ("leaf.fill",           Color(red: 0.3, green: 0.75, blue: 0.5))
        case .inspiration:  return ("bolt.fill",           Color(red: 0.3, green: 0.6, blue: 1.0))
        }
    }

    // Fallback rows for "What made you happy" when no data yet
    var happyRows: [(sfSymbol: String, color: Color, title: String, subtitle: String)] {
        if recentFreezings.isEmpty {
            return []
        }
        return recentFreezings.map { item in
            let (symbol, color) = freezingEmotionIcon(item.primaryEmotion)
            let subtitle = item.primaryEmotion.rawValue.capitalized + " • \(item.rating.rawValue)★"
            return (symbol, color, item.whatMadeUHappy, subtitle)
        }
    }

    // Fallback placeholder rows
    var badgeFallback: [(icon: String, title: String, subtitle: String, color: Color)] {
        [
            ("trophy.fill", "Ice Block", "7 days >90% ice level", Color(red: 1.0, green: 0.75, blue: 0.2)),
            ("flame.fill", "Antifreeze", "Recovered from 20%", Color(red: 1.0, green: 0.45, blue: 0.2)),
            ("figure.mind.and.body", "Pause Master", "Completed 50 sessions", Color(red: 0.3, green: 0.6, blue: 1.0))
        ]
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: — Header
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

                    // MARK: — Profile
                    VStack(spacing: 6) {
                        Button(action: { showProfileSheet = true }) {
                            ZStack(alignment: .bottomTrailing) {
                                IceAvatarView(iconName: currentUser?.icon ?? "icon1", photoData: currentUser?.photoData)
                                    .frame(width: 80, height: 80)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.black)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 3)
                                    .offset(x: 4, y: 4)
                            }
                        }

                        HStack(spacing: 4) {
                            Text(currentUser?.name ?? "User")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "pencil")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .onTapGesture { showProfileSheet = true }
                    }
                    .frame(maxWidth: .infinity)

                    // MARK: — Composure + Ice
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text("COMPOSURE LEVEL")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)

                            Text(composureStatus.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(composureStatus.color)
                                .multilineTextAlignment(.center)
                        }

                        ZStack {
                            VStack(spacing: 0) {
                                ZStack(alignment: .bottom) {
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
                                .padding(.top, 24)
                            }
                            Text("\(currentStressLevel)%")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        }

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
                        .padding(.top, 24)
                    }
                    .padding(.horizontal)

                    // MARK: — Stats Widgets
                    HStack(spacing: 12) {
                        StatWidget(
                            icon: "calendar",
                            label: "DAYS ACTIVE",
                            value: "\(daysActive)",
                            color: Color(red: 0.2, green: 0.5, blue: 1.0)
                        )
                        StatWidget(
                            icon: "waveform.path.ecg",
                            label: "AVG ICE LVL",
                            value: "\(avgIceLevel)%",
                            color: Color(red: 0.2, green: 0.5, blue: 1.0)
                        )
                    }
                    .padding(.horizontal)

                    // MARK: — What made you happy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What made you happy?")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal)

                        if happyRows.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "snowflake")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 0.7, green: 0.85, blue: 1.0))
                                    Text("No happy moments logged yet")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 24)
                                Spacer()
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(happyRows.enumerated()), id: \.offset) { index, row in
                                    BadgeRow(
                                        icon: row.sfSymbol,
                                        title: row.title,
                                        subtitle: row.subtitle,
                                        color: row.color
                                    )
                                    if index < happyRows.count - 1 {
                                        Divider().padding(.leading, 68)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .bg()
        .sheet(isPresented: $showProfileSheet) {
            ProfileSheet(user: currentUser)
        }
        .onAppear {
            createDefaultsIfNeeded()
        }
    }

    private func createDefaultsIfNeeded() {
        if stressLevels.isEmpty {
            let newStressLevel = StressLevelModel(currentLevel: 100, updates: [:])
            modelContext.insert(newStressLevel)
        }
        if users.isEmpty {
            let newUser = UserModel(name: "User", icon: "icon1")
            modelContext.insert(newUser)
        }
        try? modelContext.save()
    }
}

// MARK: - Stat Widget
struct StatWidget: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(16)
        .background(color)
        .cornerRadius(16)
    }
}

// MARK: - Badge Row
struct BadgeRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Ice Avatar View
struct IceAvatarView: View {
    let iconName: String
    var photoData: Data? = nil

    var body: some View {
        Group {
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(iconName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 3))
        .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.4), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Profile Sheet
struct ProfileSheet: View {
    var user: UserModel?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var selectedIcon: String = "icon1"
    @State private var selectedPhotoData: Data? = nil
    @State private var photoPickerItem: PhotosPickerItem? = nil
    // "photo" means user picked a custom photo (selectedIcon ignored for display)
    @State private var isPhotoSelected: Bool = false

    let icons = ["icon1", "icon2", "icon3"]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                }
            }

            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)

                HStack {
                    TextField("Your name", text: $name)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    if !name.isEmpty {
                        Button(action: { name = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(white: 0.95))
                .cornerRadius(12)
            }

            // Icon + Photo Selector
            HStack(spacing: 12) {
                ForEach(icons, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                        isPhotoSelected = false
                        selectedPhotoData = nil
                    }) {
                        ZStack(alignment: .topTrailing) {
                            IceAvatarView(iconName: icon)
                                .frame(width: 72, height: 72)
                                .opacity((!isPhotoSelected && selectedIcon == icon) ? 1.0 : 0.6)
                                .scaleEffect((!isPhotoSelected && selectedIcon == icon) ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3), value: selectedIcon)

                            if !isPhotoSelected && selectedIcon == icon {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.2, green: 0.5, blue: 1.0))
                                        .frame(width: 22, height: 22)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                }

                // Add Photo via PhotosPicker
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    ZStack(alignment: .topTrailing) {
                        Group {
                            if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                    .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.4), radius: 10, x: 0, y: 4)
                            } else {
                                Image("addPhoto")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                    .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.4), radius: 10, x: 0, y: 4)
                                    .opacity(isPhotoSelected ? 1.0 : 0.6)
                            }
                        }

                        if isPhotoSelected {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.5, blue: 1.0))
                                    .frame(width: 22, height: 22)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                }
                .onChange(of: photoPickerItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                            isPhotoSelected = true
                        }
                    }
                }
            }

            Spacer()

            // Save Button
            Button(action: save) {
                Text("Save")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .cornerRadius(16)
            }
        }
        .padding(24)
        .background(Color.white)
        .onAppear {
            name = user?.name ?? ""
            selectedIcon = user?.icon ?? "icon1"
            selectedPhotoData = user?.photoData
            isPhotoSelected = user?.photoData != nil
        }
    }

    private func save() {
        if let user = user {
            user.name = name
            user.icon = isPhotoSelected ? user.icon : selectedIcon
            user.photoData = isPhotoSelected ? selectedPhotoData : nil
        } else {
            let newUser = UserModel(name: name, icon: selectedIcon)
            newUser.photoData = isPhotoSelected ? selectedPhotoData : nil
            modelContext.insert(newUser)
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    IceCore()
        .modelContainer(for: [StressLevelModel.self, UserModel.self, FreezingModel.self, MeltingModel.self], inMemory: true)
}
