import SwiftUI

struct EggData: Identifiable, Codable {
    var id = UUID()
    let date: Date
    var count: Int
}

class EggTrackerData: ObservableObject {
    @Published var eggEntries: [EggData] = []
    private let eggsKey = "eggEntries"
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: eggsKey),
           let saved = try? JSONDecoder().decode([EggData].self, from: data) {
            eggEntries = saved.sorted { $0.date > $1.date }
        } else {
            eggEntries = []
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(eggEntries) {
            UserDefaults.standard.set(data, forKey: eggsKey)
        }
    }
    
    func addEggEntry(_ entry: EggData) {
        if let index = eggEntries.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: entry.date)
        }) {
            eggEntries[index].count = entry.count
        } else {
            eggEntries.append(entry)
        }
        eggEntries.sort { $0.date > $1.date }
        save()
    }
    
    func totalEggs() -> Int {
        eggEntries.reduce(0) { $0 + $1.count }
    }
    
    func averageWeekly() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let lastWeekEntries = eggEntries.filter { $0.date >= weekAgo }
        let total = lastWeekEntries.reduce(0) { $0 + $1.count }
        return lastWeekEntries.isEmpty ? 0 : total / lastWeekEntries.count
    }
    
    func recordMonth() -> Int {
        // Максимум за последний месяц
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let lastMonthEntries = eggEntries.filter { $0.date >= monthAgo }
        return lastMonthEntries.map { $0.count }.max() ?? 0
    }
}

struct EggTrackerView: View {
    @EnvironmentObject var eggTracker: EggTrackerData
    @State private var showingAddEgg = false
    @State private var eggCount = 0
    @State private var selectedDate = Date()
    @State private var eggCountInput = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 16) {
                    StatTile(title: "Average per Week", value: "\(eggTracker.averageWeekly())")
                    StatTile(title: "Monthly Record", value: "\(eggTracker.recordMonth())")
                    StatTile(title: "Total Eggs", value: "\(eggTracker.totalEggs())")
                }
                .padding(.horizontal)
                .padding(.top)

                List {
                    ForEach(eggTracker.eggEntries) { entry in
                        HStack {
                            Text(dateToString(entry.date))
                                .foregroundColor(.textNeutral)
                            Spacer()
                            Text("\(entry.count) eggs")
                                .foregroundColor(.accentYellow)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete { offsets in
                        eggTracker.eggEntries.remove(atOffsets: offsets)
                        eggTracker.save()
                    }
                }
                .listStyle(.plain)

                Button {
                    showingAddEgg = true
                } label: {
                    Text("Add Data")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentYellow)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
                .padding(.bottom)

                Spacer()
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Egg Tracker")
            .sheet(isPresented: $showingAddEgg) {
                AddEggDataView(selectedDate: $selectedDate, eggCountInput: $eggCountInput) { date, count in
                    eggTracker.addEggEntry(EggData(date: date, count: count))
                    showingAddEgg = false
                    eggCountInput = ""
                }
            }
        }
    }

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func exportData() {
        print("Export data tapped")
    }
}

struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.accentYellow)
            Text(title)
                .font(.caption)
                .foregroundColor(.textNeutral)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding()
        .background(Color.whiteCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}
