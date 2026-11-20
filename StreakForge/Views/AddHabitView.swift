import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var habitToEdit: Habit?
    
    @State private var name = ""
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColor = "#6366F1"
    
    let icons = ["flame.fill", "book.fill", "figure.run", "drop.fill", "moon.zzz.fill", "heart.fill", "brain.head.profile", "pills.fill", "leaf.fill", "star.fill", "dumbbell.fill", "bed.double.fill", "cup.and.saucer.fill", "pencil.and.outline"]
    let colors = ["#6366F1", "#EC4899", "#10B981", "#F59E0B", "#3B82F6", "#8B5CF6", "#EF4444", "#06B6D4"]
    
    var isEditing: Bool { habitToEdit != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Name") {
                    TextField("Drink water, Read, Workout...", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.25) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Color") {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture { selectedColor = color }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        if let habit = habitToEdit {
                            habit.name = name
                            habit.icon = selectedIcon
                            habit.colorHex = selectedColor
                        } else {
                            let habit = Habit(name: name, icon: selectedIcon, colorHex: selectedColor)
                            modelContext.insert(habit)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let habit = habitToEdit {
                    name = habit.name
                    selectedIcon = habit.icon
                    selectedColor = habit.colorHex
                }
            }
        }
    }
}
