//
//  StatsView.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-02.
//

import SwiftUI
import CoreData
import Charts

struct StatsView: View {

    // Pull from Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)],
        animation: .default
    )
    private var all: FetchedResults<Expense>

    // UI controls
    @State private var range: RangeMode = .month
    @State private var kind: Kind = .expense

    // Tooltip selection
    @State private var selectedPoint: StatsPoint? = nil
    @State private var isInteracting: Bool = false

    // MARK: - Formatters

    private var xAxisFormat: Date.FormatStyle {
        switch range {
        case .day:
            return .dateTime.hour() // 3 PM
        case .week:
            return .dateTime.weekday(.abbreviated) // Mon, Tue
        case .month:
            return .dateTime.month().day() // Jan 3
        case .year:
            return .dateTime.month(.abbreviated) // Jan
        }
    }

    private func moneyBubble(_ value: Double) -> String {
        let sign = (kind == .income) ? "+ " : "- "
        return sign + String(format: "$%.0f", abs(value)) // use "%.2f" if you want cents
    }

    private func nearestPoint(to date: Date, in points: [StatsPoint]) -> StatsPoint? {
        guard !points.isEmpty else { return nil }
        return points.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Range selector
                    Picker("", selection: $range) {
                        ForEach(RangeMode.allCases) { r in
                            Text(r.title).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Income/Expense selector (dropdown)
                    HStack {
                        Spacer()
                        Picker("", selection: $kind) {
                            ForEach(Kind.allCases) { k in
                                Text(k.title).tag(k)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                    }

                    // Chart
                    chartSection

                    // Top list
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(kind == .expense ? "Top Spending" : "Top Income")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)

                        if filteredInRange.isEmpty {
                            Text("No data yet.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(topRows) { e in
                                    StatRow(expense: e)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 12)
                }
                .padding(.top, 10)
            }
            .navigationTitle("Statistics")
        }
        .onAppear {
            // start with last point selected so it doesn't look empty
            selectedPoint = statsPoints.last
        }
        .onChange(of: range) { _, _ in
            selectedPoint = statsPoints.last
        }
        .onChange(of: kind) { _, _ in
            selectedPoint = statsPoints.last
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        Chart {
            seriesMarks
            selectionMarks
        }
        .frame(height: 220)
        .padding(.horizontal)
        .chartYAxis { AxisMarks(position: .leading) }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: range == .day ? 6 : (range == .week ? 7 : 4))) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: xAxisFormat)
            }
        }
        .chartOverlay { proxy in
            chartOverlay(proxy: proxy)
        }
    }

    @ChartContentBuilder
    private var seriesMarks: some ChartContent {
        ForEach(statsPoints) { p in
            AreaMark(
                x: .value("Date", p.date),
                y: .value("Total", p.total)
            )

            LineMark(
                x: .value("Date", p.date),
                y: .value("Total", p.total)
            )
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Date", p.date),
                y: .value("Total", p.total)
            )
        }
    }

    @ChartContentBuilder
    private var selectionMarks: some ChartContent {
        if let s = selectedPoint {
            RuleMark(x: .value("Selected", s.date))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(.secondary)

            PointMark(
                x: .value("Selected", s.date),
                y: .value("SelectedTotal", s.total)
            )
            .symbolSize(90)
        }
    }

    // ✅ FIXED: safely unwrap plotFrame anchor before indexing geo[...]
    private func chartOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            if let plotFrameAnchor = proxy.plotFrame {
                let plotFrame = geo[plotFrameAnchor]

                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isInteracting = true

                                let x = value.location.x - plotFrame.origin.x
                                if let date: Date = proxy.value(atX: x) {
                                    selectedPoint = nearestPoint(to: date, in: statsPoints)
                                }
                            }
                            .onEnded { _ in
                                isInteracting = false
                            }
                    )
                    .overlay(alignment: .topLeading) {
                        bubbleOverlay(proxy: proxy, geo: geo)
                    }
            } else {
                // plotFrame isn't ready yet; return a valid view
                Rectangle().fill(.clear)
            }
        }
    }

    // ✅ FIXED: @ViewBuilder avoids mismatched underlying types (EmptyView vs bubble view)
    @ViewBuilder
    private func bubbleOverlay(proxy: ChartProxy, geo: GeometryProxy) -> some View {
        if let s = selectedPoint,
           let plotFrameAnchor = proxy.plotFrame,
           let xPos = proxy.position(forX: s.date),
           let yPos = proxy.position(forY: s.total) {

            let plotFrame = geo[plotFrameAnchor]

            let rawX = plotFrame.origin.x + xPos
            let rawY = plotFrame.origin.y + yPos - 30

            let leftLimit  = plotFrame.minX + 40
            let rightLimit = plotFrame.maxX - 40
            let clampedX = min(max(rawX, leftLimit), rightLimit)

            let topLimit = plotFrame.minY + 16
            let clampedY = max(rawY, topLimit)

            ValueBubble(text: moneyBubble(s.total))
                .position(x: clampedX, y: clampedY)
        }
    }



    // MARK: - Data pipeline

    private var filteredInRange: [Expense] {
        let cutoff = range.cutoffDate(from: Date())
        return all.filter { e in
            let d = e.date ?? .distantPast
            let matchesType = (kind == .income)
            ? ((e.type ?? "Expense") == "Income")
            : ((e.type ?? "Expense") == "Expense")

            return matchesType && d >= cutoff
        }
    }

    private var statsPoints: [StatsPoint] {
        let now = Date()
        let cutoff = range.cutoffDate(from: now)

        // sum totals by bucket
        var totalsByBucket: [Date: Double] = [:]
        for e in filteredInRange {
            let d = e.date ?? now
            let bucket = range.bucketStart(for: d)
            totalsByBucket[bucket, default: 0] += e.amount
        }

        // fill missing buckets with 0 so the chart has consistent x-values
        let bucketDates = range.bucketDates(from: cutoff, to: now)
        return bucketDates.map { bucketDate in
            StatsPoint(date: bucketDate, total: totalsByBucket[bucketDate] ?? 0)
        }
    }

    private var topRows: [Expense] {
        let sorted = filteredInRange.sorted { $0.amount > $1.amount }
        return Array(sorted.prefix(5))
    }
}

// MARK: - Bubble UI

private struct ValueBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.background)
                    .shadow(radius: 2)
            )
    }
}

// MARK: - Types

private struct StatsPoint: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double
}

private enum Kind: String, CaseIterable, Identifiable {
    case expense
    case income
    var id: String { rawValue }
    var title: String { self == .expense ? "Expense" : "Income" }
}

private enum RangeMode: String, CaseIterable, Identifiable {
    case day, week, month, year
    var id: String { rawValue }

    var title: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    func cutoffDate(from now: Date) -> Date {
        let cal = Calendar.current

        switch self {
        case .day:
            let end = cal.date(bySetting: .minute, value: 0, of: now) ?? now
            return cal.date(byAdding: .hour, value: -23, to: end) ?? end

        case .week:
            let end = cal.startOfDay(for: now)
            return cal.date(byAdding: .day, value: -6, to: end) ?? end

        case .month:
            let end = cal.startOfDay(for: now)
            return cal.date(byAdding: .day, value: -29, to: end) ?? end

        case .year:
            let endComps = cal.dateComponents([.year, .month], from: now)
            let end = cal.date(from: endComps) ?? now
            return cal.date(byAdding: .month, value: -11, to: end) ?? end
        }
    }

    func bucketDates(from cutoff: Date, to now: Date) -> [Date] {
        let cal = Calendar.current

        switch self {
        case .day:
            let end = cal.date(bySetting: .minute, value: 0, of: now) ?? now
            let start = cal.date(byAdding: .hour, value: -23, to: end) ?? end
            return (0..<24).compactMap { cal.date(byAdding: .hour, value: $0, to: start) }

        case .week:
            let end = cal.startOfDay(for: now)
            let start = cal.date(byAdding: .day, value: -6, to: end) ?? end
            return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }

        case .month:
            let end = cal.startOfDay(for: now)
            let start = cal.date(byAdding: .day, value: -29, to: end) ?? end
            return (0..<30).compactMap { cal.date(byAdding: .day, value: $0, to: start) }

        case .year:
            let endComps = cal.dateComponents([.year, .month], from: now)
            let end = cal.date(from: endComps) ?? now
            let start = cal.date(byAdding: .month, value: -11, to: end) ?? end
            return (0..<12).compactMap { cal.date(byAdding: .month, value: $0, to: start) }
        }
    }

    func bucketStart(for date: Date) -> Date {
        let cal = Calendar.current

        switch self {
        case .day:
            let comps = cal.dateComponents([.year, .month, .day, .hour], from: date)
            return cal.date(from: comps) ?? date

        case .week, .month:
            return cal.startOfDay(for: date)

        case .year:
            let comps = cal.dateComponents([.year, .month], from: date)
            return cal.date(from: comps) ?? date
        }
    }
}

// MARK: - Row UI

private struct StatRow: View {
    let expense: Expense

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(expense.name ?? "Untitled")
                    .font(.headline)

                Text(dateText(expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(signedMoney(expense))
                .font(.headline)
                .foregroundColor((expense.type ?? "Expense") == "Income" ? .green : .red)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func dateText(_ d: Date?) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: d ?? Date())
    }

    private func signedMoney(_ e: Expense) -> String {
        let isIncome = (e.type ?? "Expense") == "Income"
        let sign = isIncome ? "+ " : "- "
        return sign + String(format: "$%.2f", abs(e.amount))
    }
}
