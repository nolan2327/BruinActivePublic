import SwiftUI
import Charts

// MARK: - Trend View
struct HistoryView: View {
    @State private var selectedFacility = 2 // Default to John Wooden Center
    @State private var selectedMetric = "Population"
    @State private var trendData: [DailyTrendData] = []
    @State private var isLoading = true
    
    let metricOptions = ["Population", "Occupancy %"]
    let facilityNames = [1: "BFit", 2: "John Wooden", 3: "Kinross"]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            mainContentView
                .navigationTitle("Trend Analysis")
                .onChange(of: selectedFacility) {
                    loadTrendData()
                }
                .onAppear { loadTrendData() }
        }
    }
    
    // Main content view
    private var mainContentView: some View {
        VStack {
            ScrollView {
                facilityPicker
                metricPicker
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    trendChartView
                        .offset(x: -5)
                    zoneComparisonView
                    Spacer()
                    statsView
                }
            }
        }
    }
    
    // Facility picker component
    private var facilityPicker: some View {
        Picker("Facility", selection: $selectedFacility) {
            ForEach([1, 2, 3], id: \.self) { facilityId in
                Text(facilityNames[facilityId] ?? "Unknown")
                    .tag(facilityId)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    // Metric picker component
    private var metricPicker: some View {
        Picker("Metric", selection: $selectedMetric) {
            ForEach(metricOptions, id: \.self) { metric in
                Text(metric).tag(metric)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    // Trend chart component
    private var trendChartView: some View {
        VStack(alignment: .leading) {
            Text("Trends: Past 14 Days")
                .font(.headline)
                .padding(.horizontal)
            
            trendChart
        }
    }
    
    // Actual chart implementation
    private var trendChart: some View {
        Chart {
            ForEach(trendData, id: \.id) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value(
                        selectedMetric,
                        selectedMetric == "Population" ? Double(dataPoint.population) : dataPoint.occupancyPercentage
                    )
                )
                .foregroundStyle(Color.blue)
                .interpolationMethod(.cardinal)
                .symbol {
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .frame(width: 10, height: 10)
                }
                
                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value(
                        selectedMetric,
                        selectedMetric == "Population" ? Double(dataPoint.population) : dataPoint.occupancyPercentage
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .frame(height: 200)
        .padding()
        .chartYScale(
            domain: selectedMetric == "Population"
                ? 0...(trendData.map { Double($0.population) }.max() ?? 100)
                : 0...(trendData.map { $0.occupancyPercentage }.max() ?? 100)
        )
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic) {
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    formattedDateLabel(value)
                }
            }
        }
    }

    // Update the date label formatting
    private func formattedDateLabel(_ value: AxisValue) -> Text {
        if let dateValue = value.as(Date.self) {
            return Text(Self.dateFormatter.string(from: dateValue))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        return Text("")
    }
    
    // Zone comparison chart component
    private var zoneComparisonView: some View {
        VStack(alignment: .leading) {
            Text("Zone Comparison")
                .font(.headline)
                .padding(.horizontal)
            
            zoneChart
        }
    }
    
    // Actual zone chart implementation
    private var zoneChart: some View {
        Chart {
            ForEach(HistoryAnalyzer.getZoneTrends(trendData: trendData, selectedMetric: selectedMetric), id: \.zoneName) { zoneData in
                BarMark(
                    x: .value("Zone", zoneData.zoneName),
                    y: .value("Average", selectedMetric == "Population" ? Double(zoneData.avgPopulation) : zoneData.avgPercentage)
                )
                .foregroundStyle(Color.blue)
            }
        }
        .frame(height: 200)
        .padding()
    }
    
    // Stats summary component
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary Statistics")
                .font(.headline)
            
            statsFirstRow
            statsSecondRow
        }
        .padding()
    }
    
    // First row of stats
    private var statsFirstRow: some View {
        HStack {
            StatsCardAlt(
                title: "Busiest Day",
                value: HistoryAnalyzer.getBusiestDay(trendData: trendData, selectedMetric: selectedMetric),
                icon: "calendar.badge.clock"
            )
            
            StatsCardAlt(
                title: "Quietest Day",
                value: HistoryAnalyzer.getQuietestDay(trendData: trendData, selectedMetric: selectedMetric),
                icon: "calendar"
            )
        }
    }
    
    // Second row of stats
    private var statsSecondRow: some View {
        HStack {
            StatsCardAlt(
                title: "Avg Occupancy",
                value: "\(HistoryAnalyzer.getAverageOccupancy(trendData: trendData))%",
                icon: "person.2.fill"
            )
            
            StatsCardAlt(
                title: "Busiest Zone",
                value: HistoryAnalyzer.getMostPopulatedZone(trendData: trendData),
                icon: "dumbbell.fill"
            )
        }
    }
    
    // Fetch trend data for the selected facility
    private func loadTrendData() {
        isLoading = true
        
        // Attempt to fetch API data first
        HistoryAnalyzer.load(facilityId: selectedFacility) { apiData in
            HistoryAnalyzer.loadHistoryData(
                selectedFacility: selectedFacility,
                apiData: apiData
            ) { data in
                DispatchQueue.main.async {
                    self.trendData = data
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview Provider
struct TrendView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
