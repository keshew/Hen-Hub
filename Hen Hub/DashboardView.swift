import SwiftUI

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

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Dashboard")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textNeutral)
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.accentYellow)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                HStack(spacing: 16) {
                    NavigationLink(destination: ChickenListView()) {
                        StatCard(title: "Chickens", value: "\(chickensCount) birds", icon: "🐔", color: .accentOrange)
                    }
                    NavigationLink(destination: EggTrackerView()) {
                        StatCard(title: "Eggs Collected", value: "\(eggsCollectedToday) today", icon: "🥚", color: .accentYellow)
                    }
                    NavigationLink(destination: FeedStorageView()) {
                        StatCard(title: "Feed Left", value: "\(feedRemainingKg) kg", icon: "🌾", color: .healthyGreen)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
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
                .padding(.horizontal)

                MiniEggChart()
                    .frame(height: 90)
                    .padding(.horizontal)

                Spacer()

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
                .padding(.horizontal)
                .padding(.bottom, 32)
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
        }
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
