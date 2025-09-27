import SwiftUI

struct AlternativeZoneView: View {
    let zone: Zone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(zone.place_name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(zone.percentage)%")
                    .font(.subheadline)
            }
            
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 8)
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(4)
                    
                    Rectangle()
                        .frame(width: CGFloat(Double(zone.percentage) / 100.0) * UIScreen.main.bounds.width * 0.35, height: 8)
                        .foregroundColor(statusColor(percentage: Double(zone.percentage) / 100.0))
                        .cornerRadius(4)
                }
                
                Text("\(zone.population)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview Provider
struct AlternativeZoneView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Low capacity zone
            AlternativeZoneView(
                zone: Zone(place_name: "Free Weights", population: 12, percentage: 35)
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemGray6))
            .previewDisplayName("Low Capacity Zone")
            
            // Medium capacity zone
            AlternativeZoneView(
                zone: Zone(place_name: "Cardio", population: 28, percentage: 70)
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemGray6))
            .previewDisplayName("Medium Capacity Zone")
            
            // High capacity zone
            AlternativeZoneView(
                zone: Zone(place_name: "Group Class", population: 25, percentage: 95)
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemGray6))
            .previewDisplayName("High Capacity Zone")
            
            // Zero usage zone
            AlternativeZoneView(
                zone: Zone(place_name: "Functional", population: 0, percentage: 0)
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemGray6))
            .previewDisplayName("Empty Zone")
        }
    }
}
