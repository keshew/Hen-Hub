import SwiftUI

struct ChickenRowView: View {
    let chicken: Chicken

    var body: some View {
        HStack(spacing: 20) {
            Text(chicken.name)
                .font(.headline)
                .foregroundColor(.textNeutral)
                .frame(minWidth: 100, alignment: .leading)

            Text(chicken.breed)
                .foregroundColor(.textNeutral)
                .frame(minWidth: 80, alignment: .leading)

            Text("\(chicken.ageMonths) mo")
                .foregroundColor(.textNeutral)
                .frame(minWidth: 60, alignment: .leading)

            Circle()
                .fill(chicken.isHealthy ? Color.healthyGreen : Color.warningRed)
                .frame(width: 16, height: 16)
        }
        .padding(.vertical, 8)
        .background(Color.whiteCard)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddChickenView: View {
    @EnvironmentObject var farm: FarmData
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var breed = ""
    @State private var ageMonths = ""
    @State private var laysDaily = true
    @State private var isHealthy = true

    @State private var showValidationErrors = false

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !breed.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(ageMonths) != nil && Int(ageMonths)! >= 0
    }

    var body: some View {
        Form {
            Section(header: Text("Add New Chicken").foregroundColor(.textNeutral)) {
                TextField("Name", text: $name)
                    .padding(8)
                    .background(Color.whiteCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationErrors && name.isEmpty ? Color.warningRed : Color.clear, lineWidth: 2)
                    )

                if showValidationErrors && name.isEmpty {
                    Text("Please enter a name")
                        .font(.caption)
                        .foregroundColor(.warningRed)
                }

                TextField("Breed", text: $breed)
                    .padding(8)
                    .background(Color.whiteCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationErrors && breed.isEmpty ? Color.warningRed : Color.clear, lineWidth: 2)
                    )
                if showValidationErrors && breed.isEmpty {
                    Text("Please enter a breed")
                        .font(.caption)
                        .foregroundColor(.warningRed)
                }

                TextField("Age (months)", text: $ageMonths)
                    .keyboardType(.numberPad)
                    .padding(8)
                    .background(Color.whiteCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationErrors && (Int(ageMonths) == nil || Int(ageMonths)! < 0) ? Color.warningRed : Color.clear, lineWidth: 2)
                    )
                if showValidationErrors && (Int(ageMonths) == nil || Int(ageMonths)! < 0) {
                    Text("Please enter a valid non-negative age")
                        .font(.caption)
                        .foregroundColor(.warningRed)
                }

                Toggle("Lays Daily", isOn: $laysDaily)
                    .tint(.accentYellow)
                Toggle("Healthy", isOn: $isHealthy)
                    .tint(.healthyGreen)
            }

            Button(action: {
                if isFormValid {
                    let newChicken = Chicken(id: UUID(), name: name, breed: breed, ageMonths: Int(ageMonths)!, laysDaily: laysDaily, isHealthy: isHealthy)
                    farm.addChicken(newChicken)
                    dismiss()
                } else {
                    showValidationErrors = true
                }
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isFormValid ? Color.accentOrange : Color.accentOrange.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.backgroundMain)
        .navigationTitle("Add Chicken")
    }
}

struct ChickenProfileView: View {
    @EnvironmentObject var farm: FarmData
    @State var chicken: Chicken

    @State private var notes: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name: \(chicken.name)")
                    Text("Breed: \(chicken.breed)")
                    Text("Age: \(chicken.ageMonths) months")
                    Text("Health Status: \(chicken.isHealthy ? "Healthy" : "Ill")")
                    Text("Eggs per week: \(chicken.laysDaily ? "Daily" : "Less often")")
                }
                .font(.body)
                .foregroundColor(.textNeutral)
                .padding()
                .background(Color.whiteCard)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
            }
            .padding()
        }
        .background(Color.backgroundMain.ignoresSafeArea())
        .navigationTitle(chicken.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
