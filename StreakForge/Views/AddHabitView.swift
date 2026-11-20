import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var habitToEdit: Habit?
    
    @State private var name = ""
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColor = "#6366F1"
    
    let icons = ["flame.fill", "book.fill", "figure.run", "drop.fill", "moon.zzz.fill", "heart.fill", "brain.head.profile", "pills.fill", "leaf.fill", "star.fill", "dumbbell.fill", "bed.double.fill", "cup.and.saucer.fill", "pencil.and.outline", "sun.max.fill"]
    let colors = ["#6366F1", "#EC4899", "#10B981", "#F59E0B", "#3B82F6", "#8B5CF6", "#EF4444", "#06B6D4"]
    
    var isEditing: Bool { habitToEdit != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit name", text: $name)
                        .font(.body)
                } header: {
                    Text("Name")
                }
                
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 46, height: 46)
                                .background(
                                    selectedIcon == icon
                                    ? Color(hex: selectedColor).opacity(0.22)
                                    : Color.clear
                                )
                                .clipShape(Circle())
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        selectedIcon = icon
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Icon")
                }
                
                Section {
                    HStack(spacing: 14) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2.5)
                                        .padding(-3)
                                )
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        selectedColor = color
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Color")
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
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
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
    
    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let habit = habitToEdit {
            habit.name = trimmed
            habit.icon = selectedIcon
            habit.colorHex = selectedColor
        } else {
            let habit = Habit(name: trimmed, icon: selectedIcon, colorHex: selectedColor)
            modelContext.insert(habit)
        }
        dismiss()
    }
}
