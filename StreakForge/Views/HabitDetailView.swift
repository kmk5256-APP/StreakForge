import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 160, height: 160)
                    Circle()
                        .trim(from: 0, to: min(Double(habit.currentStreak) / 30.0, 1.0))
                        .stroke(Color(hex: habit.colorHex), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: habit.currentStreak)
                    
                    VStack {
                        Image(systemName: habit.icon)
                            .font(.largeTitle)
                            .foregroundStyle(Color(hex: habit.colorHex))
                        Text("\(habit.currentStreak)")
                            .font(.system(size: 40, weight: .bold))
                        Text("day streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top)
                
                Text(habit.name)
                    .font(.title2.bold())
                
                Text("Completed \(habit.completions.count) times")
                    .foregroundStyle(.secondary)
                
                // Simple calendar grid for last 30 days
                VStack(alignment: .leading) {
                    Text("Last 30 Days")
                        .font(.headline)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(0..<30, id: \.self) { offset in
                            let date = Calendar.current.date(byAdding: .day, value: -29 + offset, to: Date())!
                            let completed = habit.completions.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                            RoundedRectangle(cornerRadius: 4)
                                .fill(completed ? Color(hex: habit.colorHex) : Color.gray.opacity(0.2))
                                .frame(height: 32)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
