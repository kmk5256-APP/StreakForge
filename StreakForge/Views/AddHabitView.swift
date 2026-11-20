import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var habitToEdit: Habit?

    @State private var name = ""
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColor = "#6366F1"
    @State private var showingSaveError = false

    private struct Choice: Identifiable {
        let id: String
        let name: String
    }

    private let icons = [
        Choice(id: "flame.fill", name: "Flame"),
        Choice(id: "book.fill", name: "Book"),
        Choice(id: "figure.run", name: "Run"),
        Choice(id: "drop.fill", name: "Water"),
        Choice(id: "moon.zzz.fill", name: "Moon"),
        Choice(id: "heart.fill", name: "Heart"),
        Choice(id: "brain.head.profile", name: "Mind"),
        Choice(id: "pills.fill", name: "Pills"),
        Choice(id: "leaf.fill", name: "Leaf"),
        Choice(id: "star.fill", name: "Star"),
        Choice(id: "dumbbell.fill", name: "Dumbbell"),
        Choice(id: "bed.double.fill", name: "Bed"),
        Choice(id: "cup.and.saucer.fill", name: "Cup"),
        Choice(id: "pencil.and.outline", name: "Pencil"),
        Choice(id: "sun.max.fill", name: "Sun"),
    ]
    private let colors = [
        Choice(id: "#6366F1", name: "Indigo"),
        Choice(id: "#EC4899", name: "Pink"),
        Choice(id: "#10B981", name: "Green"),
        Choice(id: "#F59E0B", name: "Amber"),
        Choice(id: "#3B82F6", name: "Blue"),
        Choice(id: "#8B5CF6", name: "Purple"),
        Choice(id: "#EF4444", name: "Red"),
        Choice(id: "#06B6D4", name: "Cyan"),
    ]
    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 8)]
    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Habit name", text: $name)
                        .accessibilityIdentifier("habit.name")
                }

                Section("Icon") {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(icons) { icon in
                            Button {
                                selectedIcon = icon.id
                            } label: {
                                Image(systemName: icon.id)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon.id ? Color(hex: selectedColor).opacity(0.22) : .clear, in: Circle())
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(icon.name)
                            .accessibilityAddTraits(selectedIcon == icon.id ? .isSelected : [])
                        }
                    }
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: selectedIcon)
                }

                Section("Color") {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(colors) { color in
                            Button {
                                selectedColor = color.id
                            } label: {
                                Circle()
                                    .fill(Color(hex: color.id))
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        if selectedColor == color.id {
                                            Circle().strokeBorder(.primary, lineWidth: 2)
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(color.name)
                            .accessibilityAddTraits(selectedColor == color.id ? .isSelected : [])
                        }
                    }
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: selectedColor)
                }
            }
            .navigationTitle(habitToEdit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(habitToEdit == nil ? "Add" : "Save", action: saveHabit)
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty)
                        .accessibilityIdentifier("habit.save")
                }
            }
            .onAppear {
                if let habit = habitToEdit {
                    name = habit.name
                    selectedIcon = habit.icon
                    selectedColor = habit.colorHex
                }
            }
            .alert("Couldn’t Save Habit", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please try again.")
            }
        }
    }

    private func saveHabit() {
        if let habit = habitToEdit {
            habit.name = trimmedName
            habit.icon = selectedIcon
            habit.colorHex = selectedColor
        } else {
            modelContext.insert(Habit(name: trimmedName, icon: selectedIcon, colorHex: selectedColor))
        }
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showingSaveError = true
        }
    }
}
