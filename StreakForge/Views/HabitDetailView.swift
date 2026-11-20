import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit = false
    @State private var showingDelete = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Elegant progress ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.12), lineWidth: 12)
                        .frame(width: 170, height: 170)
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(habit.currentStreak) / 30.0, 1.0))
                        .stroke(
                            Color(hex: habit.colorHex),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.55, dampingFraction: 0.8), value: habit.currentStreak)
                    
                    VStack(spacing: 2) {
                        Image(systemName: habit.icon)
                            .font(.title)
                            .foregroundStyle(Color(hex: habit.colorHex))
                        Text("\(habit.currentStreak)")
                            .font(.system(size: 44, weight: .semibold, design: .rounded))
                        Text("day streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
                
                Text(habit.name)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                
                // Clean stats row
                HStack(spacing: 12) {
                    StatCard(title: "Best", value: "\(habit.bestStreak)", icon: "trophy.fill")
                    StatCard(title: "Total", value: "\(habit.completions.count)", icon: "checkmark")
                    StatCard(title: "Rate", value: String(format: "%.0f%%", habit.completionRate * 100), icon: "chart.bar.fill")
                }
                
                // Soft heat map
                VStack(alignment: .leading, spacing: 14) {
                    Text("Last 30 days")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                        ForEach(0..<30, id: \.self) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: -29 + offset, to: Date())!
                            let completed = habit.completions.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(completed ? Color(hex: habit.colorHex) : Color(.systemGray6))
                                .frame(height: 34)
                                .overlay(
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(completed ? .white.opacity(0.9) : .secondary)
                                )
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit", systemImage: "pencil") { showingEdit = true }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) { showingDelete = true }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddHabitView(habitToEdit: habit)
        }
        .alert("Delete this habit?", isPresented: $showingDelete) {
            Button("Delete", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All history for \"\(habit.name)\" will be removed.")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}
