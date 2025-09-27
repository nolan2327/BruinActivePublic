import Foundation

struct DailyTrendData: Identifiable {
    let id: UUID
    let date: Date
    let population: Int
    let occupancyPercentage: Double
    let zoneDetails: [ZoneDetail]
}

struct ZoneDetail {
    let placeName: String
    let population: Int
    let percentage: Double
}

struct ZoneTrendData {
    let zoneName: String
    let avgPopulation: Int
    let avgPercentage: Double
}

struct HistoryAnalyzer {
    // API endpoint configuration, remove for now...
    }
    
    // Process and transform API data into trend data
    static func loadHistoryData(
        selectedFacility: Int,
        apiData: [FacilityTrendData],
        completion: @escaping ([DailyTrendData]) -> Void
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let processedData = apiData.first { $0.facilityName == facilityNames[selectedFacility] }?.dailyTrends.trends.map { trend in
            DailyTrendData(
                id: UUID(),
                date: dateFormatter.date(from: trend._id) ?? Date(),
                population: Int(trend.avgPopulation),
                occupancyPercentage: trend.avgOccupancy,
                zoneDetails: trend.zones.map { zone in
                    ZoneDetail(
                        placeName: zone.place_name,
                        population: zone.population,
                        percentage: zone.percentage
                    )
                }
            )
        } ?? []
        
        completion(processedData)
    }
    
    // Get zone trends for chart
    static func getZoneTrends(
        trendData: [DailyTrendData],
        selectedMetric: String
    ) -> [ZoneTrendData] {
        guard !trendData.isEmpty else { return [] }
        
        // Aggregate zone data across all trend data
        let zoneAggregates = trendData.flatMap { $0.zoneDetails }
        
        // Group and calculate averages
        let zoneGroups = Dictionary(grouping: zoneAggregates, by: { $0.placeName })
        
        return zoneGroups.map { zoneName, zoneDetails in
            ZoneTrendData(
                zoneName: zoneName,
                avgPopulation: Int(zoneDetails.map { Double($0.population) }.reduce(0, +) / Double(zoneDetails.count)),
                avgPercentage: zoneDetails.map { $0.percentage }.reduce(0, +) / Double(zoneDetails.count)
            )
        }
    }
    
    // Get busiest day based on selected metric
    static func getBusiestDay(
        trendData: [DailyTrendData],
        selectedMetric: String
    ) -> String {
        guard !trendData.isEmpty else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let busiestDay = selectedMetric == "Population" ?
            trendData.max(by: { $0.population < $1.population }) :
            trendData.max(by: { $0.occupancyPercentage < $1.occupancyPercentage })
        
        return dateFormatter.string(from: busiestDay?.date ?? Date())
    }
    
    // Get quietest day based on selected metric
    static func getQuietestDay(
        trendData: [DailyTrendData],
        selectedMetric: String
    ) -> String {
        guard !trendData.isEmpty else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        let quietestDay = selectedMetric == "Population" ?
            trendData.min(by: { $0.population < $1.population }) :
            trendData.min(by: { $0.occupancyPercentage < $1.occupancyPercentage })
        
        return dateFormatter.string(from: quietestDay?.date ?? Date())
    }
    
    // Get average occupancy
    static func getAverageOccupancy(trendData: [DailyTrendData]) -> Int {
        guard !trendData.isEmpty else { return 0 }
        
        let avgOccupancy = trendData.reduce(0.0) { $0 + $1.occupancyPercentage } / Double(trendData.count)
        return Int(avgOccupancy)
    }
    
    // Get most populated zone
    static func getMostPopulatedZone(trendData: [DailyTrendData]) -> String {
        guard !trendData.isEmpty else { return "N/A" }
        
        let zoneAggregates = trendData.flatMap { $0.zoneDetails }
        let zoneGroups = Dictionary(grouping: zoneAggregates, by: { $0.placeName })
        
        let zonePopulations = zoneGroups.mapValues { zones in
            zones.map { $0.population }.reduce(0, +)
        }
        
        return zonePopulations.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    // Mapping for facility names
    private static let facilityNames = [
        1: "BFit",
        2: "John Wooden Center",
        3: "Kinross"
    ]
}

// Supporting Codable structures for API response
struct FacilityTrendData: Codable {
    let facilityName: String
    let dailyTrends: DailyTrendsResponse
}

struct DailyTrendsResponse: Codable {
    let trends: [TrendData]
    let busiestDay: BusiestDay
    let quietestDay: QuietestDay
    let busiestZone: BusiestZone
}

struct TrendData: Codable {
    let _id: String
    let avgPopulation: Double
    let avgOccupancy: Double
    let zones: [ZoneData]
}

struct ZoneData: Codable {
    let place_name: String
    let population: Int
    let percentage: Double
    let _id: String
}

struct BusiestDay: Codable {
    let _id: String
    let avgPopulation: Double
    let avgOccupancy: Double
    let zones: [ZoneData]
}

struct QuietestDay: Codable {
    let _id: String
    let avgPopulation: Double
    let avgOccupancy: Double
    let zones: [ZoneData]
}

struct BusiestZone: Codable {
    let zoneName: String
    let avgPopulation: Int
}
