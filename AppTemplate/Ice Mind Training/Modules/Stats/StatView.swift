import SwiftUI
import SwiftData

struct StatView: View {
    @Query private var stressLevels: [StressLevelModel]
    @Query private var meltingModels: [MeltingModel]
    @Query private var freezingModels: [FreezingModel]

    var weeklyData: [(String, Double)] {
        guard let stressLevel = stressLevels.first else {
            print("❌ No StressLevelModel found")
            return []
        }
        
        print("✅ StressLevelModel found")
        print("   Current Level: \(stressLevel.currentLevel)")
        print("   Updates count: \(stressLevel.updates.count)")
        print("   Updates: \(stressLevel.updates)")
        
        let calendar = Calendar.current
        let today = Date()
        var data: [String: [Int]] = [:] // Собираем все обновления по дням

        // Initialize all days
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayString = calendar.component(.weekday, from: date)
                let dayName = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][dayString - 1]
                data[dayName] = []
            }
        }

        // Collect all updates for each day
        for (updateDate, updateValue) in stressLevel.updates {
            let dayString = calendar.component(.weekday, from: updateDate)
            let dayName = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][dayString - 1]
            
            print("   Update: \(dayName) \(updateValue > 0 ? "+" : "")\(updateValue)")
            
            if data[dayName] != nil {
                data[dayName]?.append(updateValue)
            }
        }

        // Calculate daily values: currentLevel + sum of updates for that day
        let result = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].compactMap { day -> (String, Double)? in
            if let updates = data[day], !updates.isEmpty {
                let dayTotal = updates.reduce(0, +)
                let finalValue = Double(stressLevel.currentLevel + dayTotal)
                print("   \(day): base(\(stressLevel.currentLevel)) + updates(\(dayTotal)) = \(finalValue)")
                return (day, max(0, min(100, finalValue)))
            }
            return nil
        }
        
        print("📊 Weekly Data (only days with updates):")
        for (day, value) in result {
            print("   \(day): \(value)")
        }
        
        return result
    }

    var allDaysOfWeek: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }

    var averageIceLevel: Int {
        if let stressLevel = stressLevels.first {
            return stressLevel.currentLevel
        }
        return 0
    }

    var trainingAccuracy: Int {
        if stressLevels.isEmpty { return 0 }
        if let stressLevel = stressLevels.first {
            let totalUpdates = stressLevel.updates.count
            if totalUpdates == 0 { return 0 }
            let positiveUpdates = stressLevel.updates.values.filter { $0 > 0 }.count
            return (positiveUpdates * 100) / totalUpdates
        }
        return 0
    }

    var stressRecordsCount: Int {
        meltingModels.count
    }

    var positiveRecordsCount: Int {
        freezingModels.count
    }

    var hasData: Bool {
        !stressLevels.isEmpty || !meltingModels.isEmpty || !freezingModels.isEmpty
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Statistics")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()

                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                }
                .padding(.horizontal)
                .padding(.top)

                if hasData {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Weekly Temperature Chart
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))

                                    Text("Weekly Temperature")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }

                                VStack(spacing: 12) {
                                    // Chart with Y-axis
                                    HStack(alignment: .bottom, spacing: 8) {
                                        // Y-axis
                                        VStack(alignment: .trailing, spacing: 0) {
                                            Text("100")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("75")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("50")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("25")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("0")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 30, height: 150)

                                        // Chart container with padding for points
                                        ZStack {
                                            // Grid lines через Canvas
                                            Canvas { context, size in
                                                let lineCount = 5
                                                for i in 0..<lineCount {
                                                    let y = CGFloat(i) * (size.height / CGFloat(lineCount - 1))
                                                    var path = Path()
                                                    path.move(to: CGPoint(x: 0, y: y))
                                                    path.addLine(to: CGPoint(x: size.width, y: y))
                                                    context.stroke(path, with: .color(Color.gray.opacity(0.3)), lineWidth: 1)
                                                }
                                            }

                                            // Line chart with extra padding
                                            Canvas { context, size in
                                                print("🎨 Canvas size: \(size)")
                                                print("📈 weeklyData count: \(weeklyData.count)")
                                                
                                                guard weeklyData.count > 0 else {
                                                    print("❌ No weekly data to draw")
                                                    return
                                                }
                                                
                                                let padding: CGFloat = 8
                                                let chartWidth = size.width - (padding * 2)
                                                let chartHeight = size.height
                                                
                                                print("📐 Padding: \(padding), ChartWidth: \(chartWidth), ChartHeight: \(chartHeight)")
                                                
                                                // Draw line (only if more than 1 point)
                                                if weeklyData.count > 1 {
                                                    var path = Path()

                                                    for (index, (_, value)) in weeklyData.enumerated() {
                                                        let x = padding + (chartWidth / CGFloat(weeklyData.count - 1)) * CGFloat(index)
                                                        let y = chartHeight * (1 - value / 100)

                                                        if index == 0 {
                                                            path.move(to: CGPoint(x: x, y: y))
                                                        } else {
                                                            path.addLine(to: CGPoint(x: x, y: y))
                                                        }
                                                    }

                                                    context.stroke(
                                                        path,
                                                        with: .color(Color(red: 0.2, green: 0.5, blue: 1.0)),
                                                        lineWidth: 2
                                                    )
                                                }

                                                // Points (draw regardless of count)
                                                print("🔴 Drawing \(weeklyData.count) points:")
                                                for (index, (day, value)) in weeklyData.enumerated() {
                                                    let x: CGFloat
                                                    if weeklyData.count == 1 {
                                                        // Одна точка - слева
                                                        x = padding
                                                    } else {
                                                        // Несколько точек - распределяем равномерно
                                                        x = padding + (chartWidth / CGFloat(weeklyData.count - 1)) * CGFloat(index)
                                                    }
                                                    let y = chartHeight * (1 - value / 100)
                                                    
                                                    print("   Point \(index) (\(day)): x=\(x), y=\(y), value=\(value)")

                                                    var pointPath = Path()
                                                    pointPath.addEllipse(in: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                                                    context.fill(pointPath, with: .color(Color(red: 0.2, green: 0.5, blue: 1.0)))
                                                }
                                            }
                                            .frame(height: 150)
                                        }
                                    }

                                    // X-axis labels - ВСЕ ДНИ НЕДЕЛИ
                                    HStack(spacing: 0) {
                                        ForEach(allDaysOfWeek, id: \.self) { day in
                                            Text(day)
                                                .font(.caption2)
                                                .foregroundColor(weeklyData.contains { $0.0 == day } ? .black : .gray)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .frame(height: 20)
                                    .padding(.leading, 38)
                                }
                                .padding(12)
                                .background(Color(white: 0.96))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)

                            // Stats Grid
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    // Average Ice Level
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.2))
                                                    .frame(width: 44, height: 44)

                                                Image(systemName: "chart.line.uptrend.xyaxis")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                                            }

                                            Spacer()
                                        }

                                        Text("\(averageIceLevel)%")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.black)

                                        Text("Average Ice Level")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.08))
                                    .cornerRadius(12)

                                    // Training Accuracy
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 0.8, green: 0.6, blue: 0.8).opacity(0.2))
                                                    .frame(width: 44, height: 44)

                                                Image(systemName: "brain.head.profile")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.8))
                                            }

                                            Spacer()
                                        }

                                        Text("\(trainingAccuracy)%")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.black)

                                        Text("Training Accuracy")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.8, green: 0.6, blue: 0.8).opacity(0.08))
                                    .cornerRadius(12)
                                }

                                HStack(spacing: 12) {
                                    // Stress Records
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.2))
                                                    .frame(width: 44, height: 44)

                                                Image(systemName: "flame.fill")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.9, green: 0.2, blue: 0.2))
                                            }

                                            Spacer()
                                        }

                                        Text("\(stressRecordsCount)")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.black)

                                        Text("Stress Records")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.08))
                                    .cornerRadius(12)

                                    // Positive Records
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.2))
                                                    .frame(width: 44, height: 44)

                                                Image(systemName: "heart.fill")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                                            }

                                            Spacer()
                                        }

                                        Text("\(positiveRecordsCount)")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.black)

                                        Text("Positive Records")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.08))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                } else {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer()

                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)

                            VStack(spacing: 4) {
                                Text("No data yet")
                                    .font(.headline)
                                    .foregroundColor(.black)

                                Text("Your statistics will appear after the first entries")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .bg()
    }
}

#Preview {
    StatView()
        .modelContainer(for: StressLevelModel.self, inMemory: true)
}
