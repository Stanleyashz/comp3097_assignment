//
//  StatsView.swift
//  SmartTask
//
//  Statistics Dashboard — iOS 14+ Compatible
//

import SwiftUI
import Combine

struct StatsView: View {

    @EnvironmentObject var taskStore: TaskStore

    // Drives the animated progress ring without using the deprecated
    // .animation() modifier.
    @State private var animatedRate: Double = 0

    var completionRate: Double {
        guard !taskStore.tasks.isEmpty else { return 0 }
        return Double(taskStore.completedCount) / Double(taskStore.tasks.count)
    }

    var highCount:   Int { taskStore.tasks.filter { $0.priority == "High"   }.count }
    var mediumCount: Int { taskStore.tasks.filter { $0.priority == "Medium" }.count }
    var lowCount:    Int { taskStore.tasks.filter { $0.priority == "Low"    }.count }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.12)
                    .edgesIgnoringSafeArea(.all)

                if taskStore.tasks.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            completionRingCard
                            summaryGrid
                            categoryCard
                            priorityCard
                        }
                        .padding()
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitle("Statistics", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Animate ring when tasks change (no deprecated modifier needed).
        .onReceive(taskStore.$tasks) { _ in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedRate = completionRate
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedRate = completionRate
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            Text("No data yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            Text("Add tasks to see your statistics here.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Completion Ring

    private var completionRingCard: some View {
        VStack(spacing: 16) {
            Text("Overall Progress")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 14)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: CGFloat(animatedRate))
                    .stroke(
                        animatedRate >= 1.0 ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)

                VStack(spacing: 4) {
                    Text("\(Int(completionRate * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("done")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Text("\(taskStore.completedCount) of \(taskStore.tasks.count) tasks completed")
                .font(.system(size: 13))
                .foregroundColor(.gray)

            if taskStore.overdueCount > 0 {
                Label(
                    "\(taskStore.overdueCount) overdue task\(taskStore.overdueCount == 1 ? "" : "s")",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(20)
    }

    // MARK: - Summary Grid

    private var summaryGrid: some View {
        let metrics: [(String, String, String, Color)] = [
            ("Total",     "\(taskStore.tasks.count)",    "list.bullet",                  .blue),
            ("Completed", "\(taskStore.completedCount)", "checkmark.circle.fill",         .green),
            ("Pending",   "\(taskStore.pendingCount)",   "clock.fill",                    .orange),
            ("Overdue",   "\(taskStore.overdueCount)",   "exclamationmark.triangle.fill", .red)
        ]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(metrics, id: \.0) { m in
                metricCard(label: m.0, value: m.1, icon: m.2, color: m.3)
            }
        }
    }

    private func metricCard(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(14)
    }

    // MARK: - Category Breakdown

    private var categoryCard: some View {
        let breakdown = taskStore.categoryBreakdown
        let maxCount  = breakdown.first?.count ?? 1

        return VStack(alignment: .leading, spacing: 14) {
            Text("By Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            ForEach(breakdown, id: \.category) { item in
                HStack(spacing: 10) {
                    Text(item.category)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(minWidth: 80, alignment: .leading)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(
                                width: max(8, CGFloat(item.count) / CGFloat(maxCount) * 140),
                                height: 8
                            )
                    }
                    .frame(maxWidth: .infinity)

                    Text("\(item.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(minWidth: 20, alignment: .trailing)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(20)
    }

    // MARK: - Priority Distribution

    private var priorityCard: some View {
        let total = max(1, taskStore.tasks.count)
        let items: [(String, Int, Color)] = [
            ("High",   highCount,   .red),
            ("Medium", mediumCount, .orange),
            ("Low",    lowCount,    .blue)
        ]

        return VStack(alignment: .leading, spacing: 14) {
            Text("By Priority")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            ForEach(items, id: \.0) { p in
                HStack(spacing: 10) {
                    Circle().fill(p.2).frame(width: 8, height: 8)

                    Text(p.0)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 56, alignment: .leading)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(p.2)
                            .frame(
                                width: max(0, CGFloat(p.1) / CGFloat(total) * 140),
                                height: 8
                            )
                    }
                    .frame(maxWidth: .infinity)

                    Text("\(p.1)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(p.2)
                        .frame(minWidth: 20, alignment: .trailing)
                }
            }

            // Stacked bar overview
            if !taskStore.tasks.isEmpty {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(items, id: \.0) { p in
                            if p.1 > 0 {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(p.2)
                                    .frame(width: geo.size.width * CGFloat(p.1) / CGFloat(total))
                            }
                        }
                    }
                }
                .frame(height: 10)
                .cornerRadius(5)
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.15, green: 0.15, blue: 0.17))
        .cornerRadius(20)
    }
}

// MARK: - Preview

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(TaskStore(persistence: .preview))
    }
}
