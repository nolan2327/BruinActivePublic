import SwiftUI

// MARK: - Gym Tracker View
struct GymTrackerView: View {
    @State private var expandedItemID: String? = nil
    @State private var gymData: [GymData] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if gymData.isEmpty {
                        // Loading state
                        ProgressView()
                            .padding()
                    } else {
                        ForEach(gymData) { gym in
                            AlternativeGymCardView(
                                gym: gym,
                                isExpanded: expandedItemID == gym.id,
                                toggleExpanded: {
                                    withAnimation {
                                        if expandedItemID == gym.id {
                                            expandedItemID = nil
                                        } else {
                                            expandedItemID = gym.id
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    // Summary Footer
                    HStack {
                        Spacer()
                        
                        Text("Monitoring \(gymData.count) locations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
//                        Button(action: {
//                            // Action for detailed analytics
//                        }) {
//                            HStack {
//                                Text("View detailed analytics")
//                                    .font(.subheadline)
//                                    .fontWeight(.medium)
//                                
//                                Image(systemName: "arrow.right")
//                                    .font(.caption)
//                            }
//                            .foregroundColor(.blue)
//                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Bruin Active")
            .background(Color(.systemGray6))
            .onAppear {
                loadData()
            }
        }
    }
    
    func loadData() {
        // Simulate data fetch from MongoDB
        fetchMongoData { result in
            DispatchQueue.main.async {
                if let data = result, data.count == 3 {
                    // Sort data in specific order
                    gymData = [
                        data.first { $0.facility == 2 }!, // John Wooden Center (top)
                        data.first { $0.facility == 1 }!, // BFit (middle)
                        data.first { $0.facility == 3 }!  // Kinross (bottom)
                    ]
                } else {
                    // Fallback to sample data if fetch fails
                    gymData = sampleGymData
                }
            }
        }
    }
    
    // Sample data for preview and fallback
    var sampleGymData: [GymData] = [
        GymData(
            id: "jwc",
            facility: 2,
            total_population: 87,
            time_collected: "10:15 AM",
            last_updated: "2025-03-22T10:15:00Z",
            total_percentage: 73,
            weekday: "Saturday",
            zones: [
                Zone(place_name: "Weights", population: 32, percentage: 80),
                Zone(place_name: "Cardio", population: 28, percentage: 80),
                Zone(place_name: "Studio", population: 15, percentage: 60),
                Zone(place_name: "Pool", population: 12, percentage: 60)
            ]
        ),
        GymData(
            id: "bfit",
            facility: 1,
            total_population: 54,
            time_collected: "10:10 AM",
            last_updated: "2025-03-22T10:10:00Z",
            total_percentage: 54,
            weekday: "Saturday",
            zones: [
                Zone(place_name: "Free Weights", population: 22, percentage: 73),
                Zone(place_name: "Machines", population: 18, percentage: 60),
                Zone(place_name: "Cardio", population: 14, percentage: 56),
                Zone(place_name: "Functional", population: 0, percentage: 0)
            ]
        ),
        GymData(
            id: "krec",
            facility: 3,
            total_population: 112,
            time_collected: "10:18 AM",
            last_updated: "2025-03-22T10:18:00Z",
            total_percentage: 86,
            weekday: "Saturday",
            zones: [
                Zone(place_name: "Strength", population: 45, percentage: 90),
                Zone(place_name: "Cardio", population: 32, percentage: 91),
                Zone(place_name: "Group Class", population: 25, percentage: 100),
                Zone(place_name: "Stretching", population: 10, percentage: 50)
            ]
        )
    ]
}

// MARK: - Helper Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
