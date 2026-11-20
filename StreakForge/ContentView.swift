import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    @State private var celebratingMilestone: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Soft ambient background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.indigo.opacity(0.06),
                        Color.purple.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if habits.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(habits) { habit in
                                NavigationLink {
                                    HabitDetailView(habit: habit)
                                } label: {
                                    HabitRow(habit: habit) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                            habit.toggleToday()
                                        }
                                        if let m = habit.milestone {
                                            celebratingMilestone = m
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("StreakForge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddHabitView()
            }
            .alert("Milestone reached", isPresented: Binding(
                get: { celebratingMilestone != nil },
                set: { if !$0 { celebratingMilestone = nil } }
            )) {
                Button("Continue") { celebratingMilestone = nil }
            } message: {
                Text("Amazing — \(celebratingMilestone ?? 0) day streak. Keep the momentum.")
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                )
                .symbolEffect(.pulse, options: .repeating.speed(0.6))
            
            VStack(spacing: 8) {
                Text("Start your first streak")
                    .font(.title2.weight(.semibold))
                Text("Small daily actions create lasting change.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAdd = true
            } label: {
                Text("Add Habit")
                    .font(.headline)
                    .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.indigo)
        }
        .padding()
    }
}

struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex).opacity(0.18))
                    .frame(width: 56, height: 56)
                
                Image(systemName: habit.icon)
                    .font(.title3)
                    .foregroundStyle(Color(hex: habit.colorHex))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(habit.currentStreak) day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isCompletedToday ? Color(hex: habit.colorHex) : Color(.systemGray3))
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
