//
//  MainView.swift
//  BruinActive
//
//  Created by Nolan Quiroz on 3/23/25.
//

import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            GymTrackerView()
                .tabItem {
                    Label("Gyms", systemImage: "dumbbell")
                }
            
            PredictionView()
                .tabItem {
                    Label("Predictions", systemImage: "sparkles")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.xyaxis.line")
                }
    
        }
        .accentColor(.blue)
    }
}
