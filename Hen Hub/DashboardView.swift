import SwiftUI

#Preview {
    DashboardView()
        .environmentObject(FarmData())
        .environmentObject(WeatherJournal())
}

struct DashboardView: View {
    @EnvironmentObject var farm: FarmData
    @EnvironmentObject var eggTracker: EggTrackerData
    
    @State private var showingAddEgg = false
    @State private var eggCount = 0
    @State private var selectedDate = Date()
    @State private var eggCountInput = ""
    @State private var showAddChicken = false
    @State private var showAddEgg = false
    @State private var showAddTask = false

    private var chickensCount: Int { farm.chickens.count }
    private var eggsCollectedToday: Int { 127 }
    private var feedRemainingKg: Int { 72 }
    private var farmHealth: Int {
        guard chickensCount > 0 else { return 0 }
        let healthyCount = farm.chickens.filter { $0.isHealthy }.count
        return Int(Double(healthyCount) / Double(chickensCount) * 100)
    }
    
    // ШУМ: статичные данные
    private var totalEggsMonth: Int { 1842 }
    private var avgEggsPerDay: Int { 124 }
    private var revenueWeek: Double { 24560 }
    private var monthlyGoalProgress: Double { 0.76 }
    private var feedEfficiency: Double { 8.4 }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ШУМ 1: Расширенный заголовок
                    VStack(spacing: 8) {
                        HStack {
                            Text("Dashboard")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.textNeutral)
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentYellow)
                            }
                        }
                        Text("Today: \(eggsCollectedToday) eggs")
                            .font(.headline)
                            .foregroundColor(.accentYellow)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // ШУМ 2: Больше StatCard (сетка 2 ряда)
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatCard(title: "Chickens", value: "\(chickensCount) birds", icon: "🐔", color: .accentOrange)
                            StatCard(title: "Eggs Today", value: "\(eggsCollectedToday)", icon: "🥚", color: .accentYellow)
                            StatCard(title: "Feed Left", value: "\(feedRemainingKg) kg", icon: "🌾", color: .healthyGreen)
                        }
                    }
                    .padding(.horizontal)

                    // ОРИГИНАЛЬНЫЙ Farm Health
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Farm Health")
                            .font(.headline)
                            .foregroundColor(.textNeutral)
                        ProgressView(value: Double(farmHealth)/100)
                            .tint(.healthyGreen)
                            .scaleEffect(x: 1, y: 3, anchor: .center)
                            .cornerRadius(10)
                        Text("Farm is at \(farmHealth)% health")
                            .font(.caption)
                            .foregroundColor(.textNeutral.opacity(0.8))
                    }
                    .padding(20)
                    .background(Color.whiteCard)
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // ШУМ 3: Прогресс цели
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Monthly Egg Goal")
                            .font(.headline)
                            .foregroundColor(.textNeutral)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 16)
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.yellow)
                                .frame(width: CGFloat(monthlyGoalProgress) * 300, height: 16)
                        }
                        HStack {
                            Text("\(Int(monthlyGoalProgress * 100))%")
                                .font(.subheadline.bold())
                                .foregroundColor(.accentYellow)
                            Spacer()
                            Text("\(totalEggsMonth)/2400")
                                .font(.caption)
                                .foregroundColor(.textNeutral.opacity(0.7))
                        }
                    }
                    .padding(20)
                    .background(Color.whiteCard)
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // ОРИГИНАЛЬНЫЙ график
                    MiniEggChart()
                        .frame(height: 120)
                        .padding(.horizontal)

                    // ШУМ 4: Быстрые метрики
                    HStack(spacing: 16) {
                        QuickMetric(title: "Feed Eff.", value: "\(feedEfficiency)", unit: "eggs/kg", color: .healthyGreen)
                        QuickMetric(title: "Health", value: "\(farmHealth)", unit: "%", color: .accentOrange)
                        QuickMetric(title: "Chickens", value: "\(chickensCount)", unit: "active", color: .blue)
                    }
                    .padding(.horizontal)

                    // ОРИГИНАЛЬНЫЕ кнопки + 1 шума
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Button(action: { showAddChicken = true }) {
                                Text("Add Chick")
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.accentOrange)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .font(.headline)
                            }
                            Button(action: { showAddTask = true }) {
                                Text("Add Task")
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.healthyGreen)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .font(.headline)
                            }
                        }
                        
                        Button(action: { showAddEgg = true }) {
                            Text("Log Eggs")
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.accentYellow)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.backgroundMain)
            .sheet(isPresented: $showAddChicken) {
                AddChickenView()
                    .environmentObject(farm)
                    .onDisappear {
                        showAddChicken = false
                    }
            }
            .sheet(isPresented: $showAddTask) {
                FarmTasksView()
            }
            .sheet(isPresented: $showAddEgg) {
                // Пустой для шума
                Text("Egg Input").padding()
            }
        }
        .navigationBarHidden(true)
    }
}

// ШУМ 5: Быстрые метрики
struct QuickMetric: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.textNeutral)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.textNeutral.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.whiteCard)
        .cornerRadius(12)
    }
}


struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 44))
            Text(value)
                .font(.title3.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.textNeutral)
        }
        .frame(maxWidth: .infinity, minHeight: 130)
        .padding()
        .background(Color.whiteCard)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
    }
}

struct MiniEggChart: View {
    let eggCounts = [110, 115, 120, 127, 122, 130, 127]
    
    var body: some View {
        GeometryReader { geo in
            let maxVal = eggCounts.max() ?? 1
            let minVal = eggCounts.min() ?? 0
            let height = geo.size.height
            let width = geo.size.width
            
            Path { path in
                for index in eggCounts.indices {
                    let x = width / CGFloat(eggCounts.count - 1) * CGFloat(index)
                    let y = height - (CGFloat(eggCounts[index] - minVal) / CGFloat(maxVal - minVal)) * height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.accentOrange, lineWidth: 3)
            .shadow(color: Color.accentOrange.opacity(0.5), radius: 3, x: 0, y: 2)
        }
        .background(Color.whiteCard)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct WeatherEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var temperature: String
    var description: String
    var notes: String
}

class WeatherJournal: ObservableObject {
    @Published var entries: [WeatherEntry] = []
    
    func addEntry(_ entry: WeatherEntry) {
        entries.insert(entry, at: 0)
        save()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.setValue(data, forKey: "WeatherJournalEntries")
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "WeatherJournalEntries"),
           let saved = try? JSONDecoder().decode([WeatherEntry].self, from: data) {
            entries = saved
        }
    }
}
