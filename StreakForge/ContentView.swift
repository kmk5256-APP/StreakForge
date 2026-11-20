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
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color.indigo.opacity(0.12),
                        Color.purple.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if habits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                            )
                            .symbolEffect(.bounce, options: .repeating)
                        
                        Text("Forge Your First Streak")
                            .font(.title2.bold())
                        
                        Text("Small actions. Unstoppable momentum.")
                            .foregroundStyle(.secondary)
                        
                        Button("Add Habit") { showingAdd = true }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(habits) { habit in
                                NavigationLink {
                                    HabitDetailView(habit: habit)
                                } label: {
                                    HabitRow(habit: habit, onToggle: {
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                                            habit.toggleToday()
                                        }
                                        if let milestone = habit.milestone {
                                            celebratingMilestone = milestone
                                        }
                                    })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("StreakForge")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolEffect(.pulse)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddHabitView()
            }
            .alert("Milestone!", isPresented: Binding(
                get: { celebratingMilestone != nil },
                set: { if !$0 { celebratingMilestone = nil } }
            )) {
                Button("Awesome") { celebratingMilestone = nil }
            } message: {
                Text("You've hit a \(celebratingMilestone ?? 0)-day streak! Keep forging.")
            }
        }
    }
}

struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: habit.colorHex).opacity(0.3), Color(hex: habit.colorHex).opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: habit.colorHex))
                    .symbolEffect(.bounce, value: habit.isCompletedToday)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Label("\(habit.currentStreak)", systemImage: "flame.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    
                    if habit.bestStreak > habit.currentStreak {
                        Text("Best \(habit.bestStreak)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(habit.isCompletedToday ? Color(hex: habit.colorHex) : .secondary)
                    .symbolEffect(.bounce, value: habit.isCompletedToday)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(hex: habit.colorHex).opacity(0.15), radius: 12, y: 6)
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
