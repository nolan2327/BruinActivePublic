//
//  FormatFunctions.swift
//  BruinActive
//
//  Created by Nolan Quiroz on 12/20/24.
//

import Foundation

// Helper function to format time
func formattedTime(_ interval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: interval)
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// Helper function to format date
func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

// Convert input of seconds to AM/PM-readable format
//  Takes value that is
func convertToAMPM(from seconds: TimeInterval) -> String {
    // Create a Date object from the TimeInterval
    let date = Date(timeIntervalSince1970: seconds)
    
    // Create a DateFormatter
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a" // AM/PM format
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    
    // Convert the Date to a formatted string
    return formatter.string(from: date)
}

/*
 Formats date from scrapers. Trims string due to occasional erroneous scraper input.
 Simple error handling.
 */
func formatLastUpdated(_ dateString: String) -> String? {
    // Remove extra spaces & newlines; needed for JWC
    // Will need to fix bug eventually, unnecessary for MVP
    let trimmedString = dateString.trimmingCharacters(in: .whitespacesAndNewlines)

    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "MM/dd/yyyy hh:mm a" // Matches input format
    inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent parsing

    if let date = inputFormatter.date(from: trimmedString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm a" // Output format
        outputFormatter.amSymbol = "am"
        outputFormatter.pmSymbol = "pm" // Lowercase AM/PM
        
        return outputFormatter.string(from: date)
    } else {
        return nil // Return nil if parsing fails
    }
}

