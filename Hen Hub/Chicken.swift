import SwiftUI

struct Chicken: Identifiable, Codable {
    let id: UUID
    var name: String
    var breed: String
    var ageMonths: Int
    var laysDaily: Bool
    var isHealthy: Bool
}

class FarmData: ObservableObject {
    @Published var chickens: [Chicken] = []
    
    private let chickensKey = "chickens"
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: chickensKey),
           let saved = try? JSONDecoder().decode([Chicken].self, from: data) {
            chickens = saved
        } else {
            chickens = []
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(chickens) {
            UserDefaults.standard.set(data, forKey: chickensKey)
        }
    }
    
    func addChicken(_ chicken: Chicken) {
        chickens.append(chicken)
        save()
    }
}

struct ContentView: View {
    @StateObject private var farm = FarmData()
    @StateObject private var eggTracker = EggTrackerData()
    @StateObject private var weatherJournal = WeatherJournal()
    
    var body: some View {
        ZStack {
            Color.backgroundMain
                .ignoresSafeArea()
            
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
                    }
                ChickenListView()
                    .tabItem {
                        Label("Chickens", systemImage: "list.bullet")
                    }
                EggTrackerView()
                    .tabItem {
                        Label("Eggs", systemImage: "circle.hexagongrid")
                    }
                    .environmentObject(eggTracker)
                FeedStorageView()
                    .tabItem {
                        Label("Feed", systemImage: "cart.fill")
                    }
                JournalView()
                    .tabItem {
                        Label("Weather Journal", systemImage: "book.fill")
                    }
                FarmTasksView()
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle.fill")
                    }
                StatisticsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .environmentObject(farm)
            .environmentObject(weatherJournal) 
        }
    }
}
