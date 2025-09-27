//
//  CardViewViewModel.swift
//  BruinActive
//
//  Created by Nolan Quiroz on 3/22/25.
//

import Foundation
import SwiftUI

func statusColor(percentage: Double) -> Color {
    if percentage < 0.5 {
        return .green
    } else if percentage < 0.8 {
        return .orange
    } else {
        return .red
    }
}

func statusLabel(percentage: Double) -> String {
    if percentage < 0.5 {
        return "Not Busy"
    } else if percentage < 0.8 {
        return "Moderately Busy"
    } else {
        return "Very Busy"
    }
}

// Calculates total population of persons
func calculateAndSaveTotalPopulation(from gyms: [GymBoxModel]) -> Int {
    var totalPopulation = 0

    for gym in gyms {
        totalPopulation += gym.population
    }

    return totalPopulation
}

// Decides color of percentages for main section and subsections
//      RED:     85% or greater
//      YELLOW:  65% or greater
//      GREEN:   64% or less

func decideColor(for percentage: Int) -> Color {
    if percentage >= 85 {
        return Color.red
    }
    else if percentage >= 65 {
        return Color.yellow
    }
    else {
        return Color.green
    }
}

// Decide facility name
func facilityName(for facility: Int) -> String {
    switch facility {
    case 1:
        return "Bruin Fitness Center"
    case 2:
        return "John Wooden Center"
    case 3:
        return "Kinross Recreation Center"
    default:
        return "Unknown Facility"
    }
}
