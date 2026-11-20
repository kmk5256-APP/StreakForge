import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingAdd = false
    @State private var showingSaveError = false
    @State private var celebratingMilestone: Int?
    @State private var referenceDate = Date.now

    var body: some View {
        NavigationStack {
            ScrollView {
                if habits.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.linearGradient(colors: [.orange, .red.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                            .symbolEffect(.pulse, options: .repeating.speed(0.6), isActive: !reduceMotion)
                            .accessibilityHidden(true)

                        VStack(spacing: 8) {
                            Text("Start your first streak")
                                .font(.title2.weight(.semibold))
                            Text("Small daily actions create lasting change.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(habits) { habit in
                            HabitRow(habit: habit, referenceDate: referenceDate) {
                                logCompletion(for: habit)
                            }
                        }
                    }
                    .frame(maxWidth: 640)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                }
            }
            .background {
                LinearGradient(
                    colors: [Color(.systemBackground), .indigo.opacity(0.06), .purple.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .navigationTitle("StreakForge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Habit", systemImage: "plus") { showingAdd = true }
                        .accessibilityIdentifier("habit.add")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu("About StreakForge", systemImage: "info.circle") {
                        Link("Support", destination: URL(string: "https://ai2life.org/support/streakforge")!)
                        Link("Privacy Policy", destination: URL(string: "https://ai2life.org/streakforge/privacy")!)
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
                Text("You reached a \(celebratingMilestone ?? 0)-day streak.")
            }
            .alert("Couldn’t Save Completion", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please try again.")
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { referenceDate = .now }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            referenceDate = .now
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
            referenceDate = .now
        }
    }

    private func logCompletion(for habit: Habit) {
        let now = Date.now
        withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.75)) {
            referenceDate = now
            let didComplete = habit.toggleToday(on: now)
            do {
                try modelContext.save()
                if didComplete {
                    celebratingMilestone = habit.progress(on: now).milestone
                }
            } catch {
                modelContext.rollback()
                showingSaveError = true
            }
        }
    }
}

struct HabitRow: View {
    let habit: Habit
    let referenceDate: Date
    let onToggle: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let progress = habit.progress(on: referenceDate)
        let color = Color(hex: habit.colorHex)

        HStack(spacing: 12) {
            NavigationLink {
                HabitDetailView(habit: habit)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: habit.icon)
                        .font(.title3)
                        .foregroundStyle(color)
                        .frame(width: 56, height: 56)
                        .background(color.opacity(0.18), in: Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(habit.name)
                            .font(.body.weight(.medium))
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .accessibilityHidden(true)
                            Text("\(progress.currentStreak) day streak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("habit.details")

            Button(action: onToggle) {
                Image(systemName: progress.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(progress.isCompletedToday ? color : Color.secondary)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(progress.isCompletedToday ? "Undo completion for \(habit.name)" : "Complete \(habit.name)")
            .accessibilityIdentifier("habit.toggle")
            .sensoryFeedback(.success, trigger: progress.isCompletedToday) { _, completed in completed }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let int = UInt64(hex, radix: 16) ?? 0
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
