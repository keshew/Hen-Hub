import SwiftUI

struct JournalView: View {
    @EnvironmentObject var journal: WeatherJournal
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(journal.entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.date, style: .date)
                            .font(.headline)
                        Text("\(entry.temperature), \(entry.description)")
                            .font(.subheadline)
                        Text(entry.notes)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Weather Journal")
            .toolbar {
                Button {
                    showingAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environmentObject(journal)
            }
        }
        .onAppear {
            journal.load()
        }
    }
}

struct AddEntryView: View {
    @EnvironmentObject var journal: WeatherJournal
    @Environment(\.dismiss) var dismiss
    
    @State private var temperature = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Temperature", text: $temperature)
                TextField("Description", text: $description)
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newEntry = WeatherEntry(date: date, temperature: temperature, description: description, notes: notes)
                        journal.addEntry(newEntry)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct ChickenListView: View {
    @EnvironmentObject var farm: FarmData

    @State private var showingAddChicken = false
    @State private var filterBreed: String = "All"
    @State private var filterAge: String = "All"
    @State private var filterProductivity: String = "All"

    private var breeds: [String] {
        ["All"] + Array(Set(farm.chickens.map { $0.breed })).sorted()
    }
    private let ages = ["All", "< 6 months", "6-12 months", "> 12 months"]
    private let productivities = ["All", "Daily", "Not daily"]

    private var filteredChickens: [Chicken] {
        farm.chickens.filter { chicken in
            (filterBreed == "All" || chicken.breed == filterBreed) &&
                (filterAge == "All" || filterAgeMatch(chicken: chicken)) &&
                (filterProductivity == "All" || filterProductivityMatch(chicken: chicken))
        }
    }

    private func filterAgeMatch(chicken: Chicken) -> Bool {
        switch filterAge {
        case "< 6 months": return chicken.ageMonths < 6
        case "6-12 months": return (6...12).contains(chicken.ageMonths)
        case "> 12 months": return chicken.ageMonths > 12
        default: return true
        }
    }

    private func filterProductivityMatch(chicken: Chicken) -> Bool {
        switch filterProductivity {
        case "Daily": return chicken.laysDaily
        case "Not daily": return !chicken.laysDaily
        default: return true
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Filters row
                HStack(spacing: 12) {
                    Picker("Breed", selection: $filterBreed) {
                        ForEach(breeds, id: \.self) { breed in
                            Text(breed)
                                .tag(breed)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .clipped()

                    Picker("Age", selection: $filterAge) {
                        ForEach(ages, id: \.self) { age in
                            Text(age).tag(age)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .clipped()

                    Picker("Productivity", selection: $filterProductivity) {
                        ForEach(productivities, id: \.self) { prod in
                            Text(prod).tag(prod)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 120)
                    .clipped()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                List {
                    ForEach(filteredChickens) { chicken in
                        NavigationLink(destination: ChickenProfileView(chicken: chicken)) {
                            ChickenRowView(chicken: chicken)
                                .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteChickens)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Chicken Coop")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddChicken = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.accentOrange)
                    }
                }
            }
            .sheet(isPresented: $showingAddChicken) {
                AddChickenView()
                    .environmentObject(farm)
            }
            .background(Color.backgroundMain.ignoresSafeArea())
        }
    }

    private func deleteChickens(at offsets: IndexSet) {
        farm.chickens.remove(atOffsets: offsets)
        farm.save()
    }
}
