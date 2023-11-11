//
//  TradingView.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-09.
//

import Foundation
import SwiftUI

struct TradingView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Trading Header
                    Picker("Currency", selection: .constant(1)) {
                        Text("BTC/USD").tag(1)
                        // Add other currency pairs
                    }
                    .pickerStyle(.segmented)
                    
                    // Chart
                    GeometryReader { geometry in
                        Path { path in
                            // Draw your chart here using Path APIs
                        }
                        .stroke(Color.red, lineWidth: 2)
                    }
                    .frame(height: 200)
                    
                    // Buy and Sell Buttons
                    HStack {
                        Button(action: {}) {
                            Text("Buy")
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button(action: {}) {
                            Text("Sell")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                    // Trade Value
                    HStack {
                        Text("Estimated purchase value")
                        Spacer()
                        Text("0.031")
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("Trading", displayMode: .inline)
        }
    }
}

struct TradingView_Previews : PreviewProvider {
    static var previews: some View {
        TradingView()
    }
}
