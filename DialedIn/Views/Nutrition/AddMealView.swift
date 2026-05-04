import SwiftUI
import SwiftData

struct AddMealView: View {

    var editingMeal: Meal?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: MealCategory = .lunch
    @State private var caloriesText = ""
    @State private var note = ""
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var errorMessage: String?
    @State private var isAnalyzing = false

    private var isEditing: Bool { editingMeal != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Категория") {
                    Picker("Тип", selection: $category) {
                        ForEach(MealCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.defaultIcon).tag(cat)
                        }
                    }
                }

                Section("Описание") {
                    TextField("Напр. Пилешка салата", text: $name)
                        .textInputAutocapitalization(.sentences)
                    TextField("Калории", text: $caloriesText)
                        .keyboardType(.numberPad)
                }

                Section("Бележка") {
                    TextField("По избор", text: $note, axis: .vertical)
                        .lineLimit(3)
                }

                Section("Снимка") {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button("Премахни снимката", role: .destructive) {
                            capturedImage = nil
                        }

                        Button {
                            Task { await analyzeWithAI() }
                        } label: {
                            Label("Анализирай с AI", systemImage: "sparkles")
                        }
                        .disabled(isAnalyzing)

                        if isAnalyzing {
                            HStack {
                                ProgressView()
                                Text("Анализиране...")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        if ImagePicker.isCameraAvailable {
                            Button {
                                pickerSource = .camera
                                showCamera = true
                            } label: {
                                Label("Направи снимка", systemImage: "camera")
                            }
                        }
                        Button {
                            pickerSource = .photoLibrary
                            showCamera = true
                        } label: {
                            Label("Избери от галерия", systemImage: "photo")
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Редактиране" : "Ново хранене")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") { saveMeal() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $capturedImage, sourceType: pickerSource)
            }
            .alert("Грешка", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear { loadExistingData() }
        }
    }

    private func loadExistingData() {
        guard let m = editingMeal else { return }
        name = m.name
        category = m.category
        caloriesText = String(m.calories)
        note = m.note
        if let data = m.photoData {
            capturedImage = UIImage(data: data)
        }
    }

    private func analyzeWithAI() async {
        guard let image = capturedImage,
              let data = image.jpegData(compressionQuality: 0.8) else { return }
        isAnalyzing = true
        defer { isAnalyzing = false }
        do {
            let result = try await GeminiService.analyzeMeal(imageData: data)
            name = result.name
            caloriesText = String(result.calories)
            category = result.category
        } catch {
            errorMessage = "AI анализът не успя: \(error.localizedDescription)"
        }
    }

    private func saveMeal() {
        let calories = Int(caloriesText) ?? 0
        let photoData = capturedImage?.jpegData(compressionQuality: 0.7)

        if let m = editingMeal {
            m.name = name.trimmingCharacters(in: .whitespaces)
            m.category = category
            m.calories = calories
            m.note = note
            m.photoData = photoData
        } else {
            let meal = Meal(
                name: name.trimmingCharacters(in: .whitespaces),
                category: category,
                calories: calories,
                note: note,
                photoData: photoData
            )
            modelContext.insert(meal)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = AppError.saveFailed(error.localizedDescription).localizedDescription
        }
    }
}

#Preview {
    AddMealView()
        .modelContainer(for: Meal.self, inMemory: true)
}
