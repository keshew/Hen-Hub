import SwiftUI

struct EggChartView: View {
    let entries: [EggData]
    
    var weeklyData: [(week: String, total: Int)] {
        var weeksDict = [String: Int]()
        let calendar = Calendar.current
        for entry in entries {
            let comp = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.date)
            if let year = comp.yearForWeekOfYear, let week = comp.weekOfYear {
                let key = "W\(week) \(year)"
                weeksDict[key, default: 0] += entry.count
            }
        }
        return weeksDict.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }
    
    var body: some View {
        GeometryReader { geo in
            let maxVal = weeklyData.map { $0.total }.max() ?? 1
            let width = geo.size.width / CGFloat(max(weeklyData.count, 1))
            let height = geo.size.height
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(weeklyData, id: \.week) { week, total in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentOrange)
                            .frame(width: width * 0.8, height: CGFloat(total) / CGFloat(maxVal) * height)
                        Text(week)
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                            .frame(width: width * 1.4)
                    }
                }
            }
            .frame(height: height)
        }
        .background(Color.whiteCard)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct StatisticsView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Statistics & Reports")
                        .font(.largeTitle.bold())
                        .foregroundColor(.textNeutral)
                        .padding(.top, 16)
                    
                    VStack(spacing: 16) {
                        StatCard2(title: "Eggs per day", value: "127")
                        StatCard2(title: "Feed consumption", value: "22 kg")
                        StatCard2(title: "Most productive chicken", value: "White Leghorn")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard2: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.accentYellow)
            Text(title)
                .font(.headline)
                .foregroundColor(.textNeutral)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.whiteCard)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
}

struct SettingsView: View {
    @AppStorage("unit") var unit: String = "kg"
    @AppStorage("currency") var currency: String = "USD"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units").foregroundColor(.textNeutral)) {
                    Picker("Weight Unit", selection: $unit) {
                        Text("Kilograms").tag("kg")
                        Text("Pounds").tag("lb")
                    }
                    .pickerStyle(.segmented)
                    .accentColor(.accentOrange)
                }

                Section(header: Text("Currency").foregroundColor(.textNeutral)) {
                    Picker("Currency", selection: $currency) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                        Text("RUB").tag("RUB")
                    }
                    .accentColor(.accentOrange)
                }

                Section(header: Text("Notifications").foregroundColor(.textNeutral)) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(.accentYellow)
                }

                Section {
                    Button("Reset Data") {
                        print("Reset data tapped")
                    }
                    .foregroundColor(.warningRed)
                }

                Section(header: Text("About").foregroundColor(.textNeutral)) {
                    Text("Chicken Farm Manager v1.0")
                    Text("Offline farm management app")
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }
}
