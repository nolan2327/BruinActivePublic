import SwiftUI

struct AlternativeGymCardView: View {
    let gym: GymData
    let isExpanded: Bool
    let toggleExpanded: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card Content
            HStack(spacing: 0) {
                // Status Indicator Bar
                statusColor(percentage: Double(gym.total_percentage) / 100.0)
                    .frame(width: 4, height: 230)
                
                VStack(spacing: 12) {
                    // Top Row - Name and Time
                    HStack {
                        Text(gym.facilityName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.darkText))
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                            
                            Text(formatLastUpdated(gym.last_updated) ?? "Just now")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    // Middle Row - Stats
                    HStack(alignment: .bottom) {
                        // Current Users
                        VStack(alignment: .leading) {
                            Text("\(gym.total_population)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Current Users")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Percentage
                        VStack {
                            Text("\(gym.total_percentage)%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(decideColor(for: gym.total_percentage))
                            
                            Text("Capacity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Status
                        Text(statusLabel(percentage: Double(gym.total_percentage) / 100.0))
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(statusColor(percentage: Double(gym.total_percentage) / 100.0))
                            .cornerRadius(20)
                    }
                    
                    // Toggle Button
                    Button(action: toggleExpanded) {
                        HStack {
                            Image(systemName: "chart.bar")
                                .font(.subheadline)
                            
                            Text(isExpanded ? "Hide Zone Details" : "View Zone Details")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(Color(.darkGray))
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
                .padding(.leading, 12)
                .padding([.trailing, .top, .bottom])
            }
            .background(Color.white)
            .cornerRadius(isExpanded ? 0 : 16, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
            
            // Expandable Zone Section
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(gym.zones, id: \.place_name) { zone in
                            AlternativeZoneView(zone: zone)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
            }
        }
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview Provider
struct AlternativeGymCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleGym = GymData(
            id: "jwc",
            facility: 2,
            total_population: 87,
            time_collected: "10:15 AM",
            last_updated: "2025-03-22T10:15:00Z",
            total_percentage: 73,
            weekday: "Saturday",
            zones: [
                Zone(place_name: "Weights", population: 32, percentage: 100),
                Zone(place_name: "Cardio", population: 28, percentage: 70),
                Zone(place_name: "Studio", population: 15, percentage: 50),
                Zone(place_name: "Pool", population: 12, percentage: 45)
            ]
        )
        
        Group {
            // Preview collapsed state
            AlternativeGymCardView(
                gym: sampleGym,
                isExpanded: false,
                toggleExpanded: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Collapsed")
            
            // Preview expanded state
            AlternativeGymCardView(
                gym: sampleGym,
                isExpanded: true,
                toggleExpanded: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Expanded")
            
            // Preview with different capacity values
            AlternativeGymCardView(
                gym: GymData(
                    id: "bfit",
                    facility: 1,
                    total_population: 25,
                    time_collected: "10:10 AM",
                    last_updated: "2025-03-22T10:10:00Z",
                    total_percentage: 35,
                    weekday: "Saturday",
                    zones: [
                        Zone(place_name: "Free Weights", population: 12, percentage: 40),
                        Zone(place_name: "Machines", population: 8, percentage: 30),
                        Zone(place_name: "Cardio", population: 5, percentage: 25)
                    ]
                ),
                isExpanded: false,
                toggleExpanded: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Low Capacity")
            
            // Preview with very high capacity
            AlternativeGymCardView(
                gym: GymData(
                    id: "krec",
                    facility: 3,
                    total_population: 112,
                    time_collected: "10:18 AM",
                    last_updated: "2025-03-22T10:18:00Z",
                    total_percentage: 96,
                    weekday: "Saturday",
                    zones: [
                        Zone(place_name: "Strength", population: 45, percentage: 98),
                        Zone(place_name: "Cardio", population: 32, percentage: 95),
                        Zone(place_name: "Group Class", population: 25, percentage: 100),
                        Zone(place_name: "Stretching", population: 10, percentage: 80)
                    ]
                ),
                isExpanded: false,
                toggleExpanded: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Very High Capacity")
        }
    }
}
