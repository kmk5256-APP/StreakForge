import SwiftUI
import SwiftData

struct HabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingEdit = false
    @State private var showingDelete = false
    @State private var showingDeleteError = false

    var body: some View {
        TimelineView(.everyMinute) { timeline in
            let calendar = Calendar.current
            let progress = habit.progress(on: timeline.date, calendar: calendar)
            ScrollView {
                VStack(spacing: 28) {
                    progressRing(progress.currentStreak)
                    Text(habit.name)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                    stats(progress)
                    history(progress.completedDays, on: timeline.date, calendar: calendar)
                }
                .frame(maxWidth: 640)
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Habit Options", systemImage: "ellipsis") {
                    Button("Edit", systemImage: "pencil") { showingEdit = true }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) { showingDelete = true }
                }
                .accessibilityIdentifier("habit.menu")
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddHabitView(habitToEdit: habit)
        }
        .alert("Delete Habit?", isPresented: $showingDelete) {
            Button("Delete", role: .destructive, action: deleteHabit)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove “\(habit.name)” and its history.")
        }
        .alert("Couldn’t Delete Habit", isPresented: $showingDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
    }

    private func progressRing(_ streak: Int) -> some View {
        let color = Color(hex: habit.colorHex)
        return ZStack {
            Circle().strokeBorder(.quaternary, lineWidth: 12)
            Circle()
                .inset(by: 6)
                .trim(from: 0, to: min(Double(streak) / 30, 1))
                .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.8), value: streak)
            VStack(spacing: 4) {
                Image(systemName: habit.icon)
                    .font(.title)
                    .foregroundStyle(color)
                Text(streak, format: .number)
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                Text("day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .minimumScaleFactor(0.65)
        }
        .frame(width: 170, height: 170)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(streak) day streak")
    }

    private func stats(_ progress: HabitProgress) -> some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            StatCard(title: "Best", value: progress.bestStreak.formatted(), icon: "trophy.fill")
            StatCard(title: "Total", value: progress.completedDays.count.formatted(), icon: "checkmark")
            StatCard(title: "Rate", value: progress.completionRate.formatted(.percent.precision(.fractionLength(0))),
                     icon: "chart.bar.fill")
        }
    }

    private func history(_ completedDays: Set<Date>, on date: Date, calendar: Calendar) -> some View {
        let today = calendar.startOfDay(for: date)
        let lastMonth = (-29...0).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        let color = Color(hex: habit.colorHex)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 days")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                ForEach(lastMonth, id: \.self) { day in
                    let isComplete = completedDays.contains(day)
                    VStack(spacing: 2) {
                        Text(day, format: .dateTime.day())
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        if isComplete {
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(isComplete ? color.opacity(0.22) : Color.secondary.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 7))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(day.formatted(.dateTime.month(.wide).day()))
                    .accessibilityValue(isComplete ? "Complete" : "Incomplete")
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func deleteHabit() {
        modelContext.delete(habit)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showingDeleteError = true
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}
