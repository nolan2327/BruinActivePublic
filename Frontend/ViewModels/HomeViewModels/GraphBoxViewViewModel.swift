//
//  GraphBoxViewViewModel.swift
//  BruinActive
//
//  Created by Nolan Quiroz on 1/7/25.
//

import Foundation

struct DefaultDictionary<Key: Hashable, Value> {
    /*
     Enabled to set a default value for the hourToTimeMap. Avoids code repetition later.
     Fine to delete as long as there's a default value for time such as the empty string.
     For now, keep it to keep the code more concise. Maybe fix later for optimization?
     */
    private var dictionary: [Key: Value]
    private let defaultValue: Value

    init(defaultValue: Value, dictionary: [Key: Value] = [:]) {
        self.defaultValue = defaultValue
        self.dictionary = dictionary
    }

    subscript(key: Key) -> Value {
        get {
            return dictionary[key] ?? defaultValue
        }
        set {
            dictionary[key] = newValue
        }
    }
}

// Map to convert an input of int from 24-hour time to 12-hour time as a string
let hourToTimeMap = DefaultDictionary<Int, String>(
    defaultValue: "-1",
    dictionary: [
        0: "12am", 1: "1am", 2: "2am", 3: "3am", 4: "4am", 5: "5am",
        6: "6am", 7: "7am", 8: "8am", 9: "9am", 10: "10am", 11: "11am",
        12: "12pm", 13: "1pm", 14: "2pm", 15: "3pm", 16: "4pm", 17: "5pm",
        18: "6pm", 19: "7pm", 20: "8pm", 21: "9pm", 22: "10pm", 23: "11pm"
    ]
)

struct GymBoxModel_Temp: Identifiable {
    let id = UUID() // Unique identifier for each instance
    var facility: Int // 1 for Wooden, 2 for BFit
    var population: Int
    var percentage: Int
    var time: Int
    var timeString: String
    var weekday: String
//    var date: Date
    var subSections: [SectionBoxModel]
}

// Sample data before backend is implemented
let tempSubSections = [
    SectionBoxModel(name: "Cardio Zone", population: 20, percentage: 40),
    SectionBoxModel(name: "Weight Rooms", population: 32, percentage: 60),
    SectionBoxModel(name: ":)", population: 0, percentage: 0)
]

var data = [
    GymBoxModel_Temp(facility: 0, population: 34, percentage: 14, time: 6, timeString: hourToTimeMap[6], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 65, percentage: 34, time: 7, timeString: hourToTimeMap[7], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 105, percentage: 58, time: 8, timeString: hourToTimeMap[8], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 73, percentage: 46, time: 9, timeString: hourToTimeMap[9], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 80, percentage: 50, time: 10, timeString: hourToTimeMap[10], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 34, percentage: 14, time: 11, timeString: hourToTimeMap[11], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 65, percentage: 34, time: 12, timeString: hourToTimeMap[12], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 105, percentage: 58, time: 13, timeString: hourToTimeMap[13], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 73, percentage: 46, time: 14, timeString: hourToTimeMap[14], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 80, percentage: 50, time: 15, timeString: hourToTimeMap[15], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 34, percentage: 14, time: 16, timeString: hourToTimeMap[16], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 65, percentage: 34, time: 17, timeString: hourToTimeMap[17], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 105, percentage: 58, time: 18, timeString: hourToTimeMap[18], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 73, percentage: 46, time: 19, timeString: hourToTimeMap[19], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 80, percentage: 50, time: 20, timeString: hourToTimeMap[20], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 34, percentage: 14, time: 21, timeString: hourToTimeMap[21], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 65, percentage: 34, time: 22, timeString: hourToTimeMap[22], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 105, percentage: 58, time: 23, timeString: hourToTimeMap[23], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 73, percentage: 46, time: 0, timeString: hourToTimeMap[0], weekday: "MONDAY", subSections: tempSubSections),
    GymBoxModel_Temp(facility: 0, population: 80, percentage: 50, time: 2, timeString: hourToTimeMap[1], weekday: "MONDAY", subSections: tempSubSections)
]


func getBusiestAndLeastBusyTime(data: [GymBoxModel_Temp]) -> (busiestTime: GymBoxModel_Temp, leastBusyTime: GymBoxModel_Temp) {
    // Find the busiest time (highest count)
    let busiestTime = data.max { $0.population < $1.population }
    // Find the least busy time (lowest count)
    let leastBusyTime = data.min { $0.population < $1.population }
    
    // Unwrap the optional values (they are guaranteed to have a value because we are checking the max and min of non-empty arrays)
    if let busiest = busiestTime, let least = leastBusyTime {
        return (busiest, least)
    } else {
        print("Error: No data available")
        // Return default values if there's no data (this should never happen)
        return (busiestTime:
                GymBoxModel_Temp(facility: 0, population: 0, percentage: 0, time: 0, timeString: hourToTimeMap[0], weekday: "", subSections: tempSubSections),
        leastBusyTime:
                GymBoxModel_Temp(facility: 0, population: 0, percentage: 0, time: 0, timeString: hourToTimeMap[0], weekday: "", subSections: tempSubSections)
        )
    }
}

func fetchMongoData(completion: @escaping ([GymData]?) -> Void) {
    print("Fetching data...")
    // Fetch data, removed for now...
}

func formatTime(_ timestamp: String) -> String {
    let formatter = ISO8601DateFormatter()
    if let date = formatter.date(from: timestamp) {
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a"
        return displayFormatter.string(from: date)
    }
    return "Unknown"
}
