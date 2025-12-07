import SwiftUI

struct AddEggDataView: View {
    @Binding var selectedDate: Date
    @Binding var eggCountInput: String
    var onSave: (Date, Int) -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                TextField("Eggs Count", text: Binding(
                    get: { eggCountInput },
                    set: { newValue in
                        // Оставляем только цифры
                        eggCountInput = newValue.filter { $0.isNumber }
                    }
                ))
                .keyboardType(.numberPad)
            }
            .navigationTitle("Add Egg Data")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let count = Int(eggCountInput), count >= 0 {
                            onSave(selectedDate, count)
                            dismiss()
                        } else {
                            print("Invalid egg count")
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeedStorageView: View {
    @State private var feeds: [Feed] = [
        Feed(name: "Grain", amountKg: 22),
        Feed(name: "Compound Feed", amountKg: 50),
        Feed(name: "Corn", amountKg: 14)
    ]
    @State private var showingAddFeed = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(feeds) { feed in
                        HStack {
                            Text(feed.name)
                                .foregroundColor(.textNeutral)
                                .font(.headline)
                            Spacer()
                            Text("\(feed.amountKg, specifier: "%.0f") kg")
                                .foregroundColor(.textNeutral)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 8)
                        .background(Color.whiteCard)
                        .cornerRadius(12)
                        .listRowSeparator(.hidden)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    }
                    .onDelete { indexSet in
                        feeds.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // убирает фон листа

                Button {
                    showingAddFeed = true
                } label: {
                    Text("Add Feed")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.accentOrange)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Feed Storage")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(.accentOrange)
                }
            }
            .sheet(isPresented: $showingAddFeed) {
                AddFeedView(feeds: $feeds)
            }
        }
    }
}

struct Feed: Identifiable {
    let id = UUID()
    var name: String
    var amountKg: Double
}

struct AddFeedView: View {
    @Binding var feeds: [Feed]
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var amount = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Feed")) {
                    TextField("Feed Type", text: $name)
                    TextField("Amount (kg)", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Feed")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !name.isEmpty, let amountKg = Double(amount), amountKg >= 0 else { return }
                        let newFeed = Feed(name: name, amountKg: amountKg)
                        feeds.append(newFeed)
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

struct FarmTasksView: View {
    @State private var tasks: [FarmTask] = [
        FarmTask(text: "Clean the chicken coop", done: false),
        FarmTask(text: "Check drinkers", done: false),
        FarmTask(text: "Add new feed", done: false),
    ]
    @State private var newTaskText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(tasks) { task in
                        HStack {
                            Button(action: {
                                toggleTask(task)
                            }) {
                                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.done ? .healthyGreen : .textNeutral)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Text(task.text)
                                .font(.body)
                                .foregroundColor(.textNeutral)
                                .padding(.leading, 8)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(Color.whiteCard)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // чтобы фон списка был прозрачным и показывал цвет экрана

                HStack {
                    TextField("New task", text: $newTaskText)
                        .padding(12)
                        .background(Color.whiteCard)
                        .cornerRadius(12)
                        .foregroundColor(.textNeutral)
                        .font(.body)

                    Button(action: {
                        addNewTask()
                    }) {
                        Text("Add")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(newTaskText.isEmpty ? Color.accentYellow.opacity(0.5) : Color.accentYellow)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    .disabled(newTaskText.isEmpty)
                }
                .padding()
                .background(Color.backgroundMain)
            }
            .background(Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Farm Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(.accentOrange)
                }
            }
        }
    }

    private func toggleTask(_ task: FarmTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].done.toggle()
        }
    }

    private func addNewTask() {
        let task = FarmTask(text: newTaskText, done: false)
        tasks.append(task)
        newTaskText = ""
    }

    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct FarmTask: Identifiable {
    let id = UUID()
    var text: String
    var done: Bool
}
