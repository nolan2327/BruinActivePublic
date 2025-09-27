//
//  SubBoxModel.swift
//  BruinActive
//
//  Created by Nolan Quiroz on 1/6/25.
//

import Foundation

struct SectionBoxModel: Identifiable {
    let id = UUID()
    let name: String
    var population: Int
    var percentage: Int
}


// Define a model for zones inside GymData
struct Zone: Codable {
    let place_name: String
    let population: Int
    let percentage: Int
}
