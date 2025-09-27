import SwiftUI

struct GymListView: View {
    
    @State private var expandedItemID: String? = nil // Match GymData's id type
    @State private var gymData: [GymData] = []  // Store fetched data
    
    var body: some View {
        List(gymData) { item in
            VStack(alignment: .leading, spacing: 0) {
                let isExpanded = (expandedItemID == item.id)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        /*
                         The logic here is a little confusing for the text. Visually,
                         
                         Facility is equal to 1
                            True: it's BFit
                            False:
                                If the facility equal to 2
                                    True: it's JWC
                                    False: it's KREC
                         
                         */
                        
                        Text(
                            item.facility == 1 ? "Bruin Fitness Center" : (item.facility == 2 ? "John Wooden Center" : "Kinross Recreation Center"))
                            .font(.system(size: 14))
                            .bold()
                        Text(formatLastUpdated(item.last_updated) ?? "")
//                        Text("\(item.last_updated)")
//                        Text("\(item.weekday) at \(formattedTime)")
                            .font(.system(size: 10))
                    }
                    .padding()
                    .background(Color.white)
                    
                    Spacer()
                    
                    Text("\(item.total_population)") // Show total population
                        .padding(.trailing, 10)
                        .font(.system(size: 14))
                    
                    
                    Spacer()
                    
                    
                    // TODO:  PLACEHOLDER
                    Text("\(item.total_percentage)%") // Show total population
                        .foregroundColor(decideColor(for: item.total_percentage))
                        .padding(.trailing, 10)
                        .font(.system(size: 14))
                    
                    /*
                     TODO: Add What's this time?
                     Make a box so when tapped it explains the potential error
                     Use the i icon with a questionmark.circle
                     */
                    
                    
                    Button {
                        expandedItemID = (expandedItemID == item.id) ? nil : item.id
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 16))
                            .foregroundColor(Color.black)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(item.zones, id: \.place_name) { zone in
                            HStack {
                                Text(zone.place_name)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .offset(x: 25)
                                
                                Spacer()
                                
                                Text("\(zone.population)") // Show zone population
                                    .font(.system(size: 13))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color.white)
        .onAppear {
            fetchMongoData { result in
                DispatchQueue.main.async {
                    if let data = result, data.count == 3 {
                        gymData = [
                            data.first { $0.facility == 2 }!, // John Wooden Center (top)
                            data.first { $0.facility == 1 }!, // BFit (middle)
                            data.first { $0.facility == 3 }!  // Kinross (bottom)
                        ]
                    } else {
                        print("Failed to fetch data")
                    }
                }
            }
        }
    }
}

#Preview {
    GymListView()
}
