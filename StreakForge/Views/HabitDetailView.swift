import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit = false
    @State private var showingDelete = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 14)
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(habit.currentStreak) / 30.0, 1.0))
                        .stroke(
                            LinearGradient(colors: [Color(hex: habit.colorHex), Color(hex: habit.colorHex).opacity(0.6)], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: habit.currentStreak)
                    
                    VStack(spacing: 4) {
                        Image(systemName: habit.icon)
                            .font(.largeTitle)
                            .foregroundStyle(Color(hex: habit.colorHex))
                        Text("\(habit.currentStreak)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("day streak")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 12)
                
                Text(habit.name)
                    .font(.title.bold())
                
                // Stats
                HStack(spacing: 20) {
                    StatPill(title: "Best", value: "\(habit.bestStreak)", icon: "trophy.fill")
                    StatPill(title: "Total", value: "\(habit.completions.count)", icon: "checkmark.circle")
                    StatPill(title: "Rate", value: String(format: "%.0f%%", habit.completionRate * 100), icon: "chart.line.uptrend.xyaxis")
                }
                
                // Heat Map
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 30 Days")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                        ForEach(0..<30, id: \.self) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: -29 + offset, to: Date())!
                            let completed = habit.completions.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                            RoundedRectangle(cornerRadius: 5)
                                .fill(completed ? Color(hex: habit.colorHex) : Color.gray.opacity(0.15))
                                .frame(height: 36)
                                .overlay(
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(.caption2)
                                        .foregroundStyle(completed ? .white : .secondary)
                                )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit", systemImage: "pencil") { showingEdit = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { showingDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddHabitView(habitToEdit: habit)
        }
        .alert("Delete Habit?", isPresented: $showingDelete) {
            Button("Delete", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove \"\(habit.name)\" and its history.")
        }
    }
}

struct StatPill: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
