//
//  ContentView.swift
//  HandGestureDetector
//
//  Created by Course on 23/10/2024.
//

import SwiftUI

struct ContentView: View {
    private let sessionHandler = SessionHandler()
    
    var body: some View {
        ARViewContainer(sessionHandler: sessionHandler)
            .edgesIgnoringSafeArea(.all)
    }
}
