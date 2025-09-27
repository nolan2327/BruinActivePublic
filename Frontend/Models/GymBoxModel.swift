//
//  GymBoxModel.swift
//  BruinActive
//
//  Created by Nolan Quiroz on 12/19/24.
//

import Foundation
import SwiftUI

struct GymBoxModel: Identifiable {
    let id = UUID() // Unique identifier for each instance
    var facility: Int // 1 for Wooden, 2 for BFit
    var population: Int
    var percentage: Int
    var time: TimeInterval
    var date: Date
    var subSections: [SectionBoxModel]
}




// NEW MODELS
struct GymData: Codable, Identifiable {
    let id: String
    let facility: Int // 1 for BFIT, 2 for Wooden
    let total_population: Int
    let time_collected: String
    let last_updated: String
    let total_percentage: Int
    let weekday: String
    let zones: [Zone]

    enum CodingKeys: String, CodingKey {
        case id = "_id" // Map MongoDB `_id` field
        case facility
        case total_population
        case time_collected
        case last_updated
        case total_percentage
        case weekday
        case zones
    }
    
    var facilityName: String {
            switch facility {
            case 1: return "Bruin Fitness Center"
            case 2: return "John Wooden Center"
            case 3: return "Kinross Recreation Center"
            default: return "Unknown Facility"
            }
    }
}

