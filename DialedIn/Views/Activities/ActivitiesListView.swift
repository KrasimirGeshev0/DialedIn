import SwiftUI
import SwiftData

/// Main Activities tab -- shows activity types and allows starting sessions.
struct ActivitiesListView: View {

    @Query(sort: \Activity.sortOrder) private var activities: [Activity]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddActivity = false
    @State private var selectedActivity: Activity?
    @State private var timerService = LiveActivityService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if activities.isEmpty {
                        emptyState
                    } else {
                        activityGrid
                    }
                }
                .padding()
            }
            .navigationTitle("Активности")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddActivity = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView()
            }
            .sheet(item: $selectedActivity) { activity in
                StartSessionView(activity: activity)
            }
        }
    }

    // MARK: - Activity Grid

    private var activityGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(activities) { activity in
                ActivityCardView(activity: activity) {
                    if !timerService.isRunning {
                        selectedActivity = activity
                    }
                }
                .contextMenu {
                    NavigationLink(destination: SessionHistoryView(activity: activity)) {
                        Label("История", systemImage: "clock")
                    }
                    Button(role: .destructive) {
                        modelContext.delete(activity)
                    } label: {
                        Label("Изтрий", systemImage: "trash")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Няма активности")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Добавете първата си активност с бутона +")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 60)
    }
}

// MARK: - Activity Card

struct ActivityCardView: View {
    let activity: Activity
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: activity.icon)
                .font(.system(size: 32))
                .foregroundStyle(Color(hex: activity.colorHex))

            Text(activity.name)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("\(activity.totalSessions) сесии")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                onStart()
            } label: {
                Text("Старт")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(hex: activity.colorHex), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ActivitiesListView()
        .modelContainer(for: [Activity.self, ActivitySession.self], inMemory: true)
}
