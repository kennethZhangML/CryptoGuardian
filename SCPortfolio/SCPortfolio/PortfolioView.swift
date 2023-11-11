//
//  PortfolioView.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-09.
//

import Foundation
import SwiftUI

struct TokenView: View {
    var toToken : String
    var fromToken : String
    var balance: String
    
    var gradient: LinearGradient
    
    var onTokenSelect: ((String, String) -> Void)?
    
    var body: some View {
        NavigationLink(destination: TokenDetailView(fromToken: fromToken, toToken: toToken)) {
            VStack {
                Text("\(fromToken)-\(toToken)")
                    .foregroundColor(Color.black)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(balance)
                    .foregroundColor(Color.black)
                    .font(.largeTitle)
            }
            .onTapGesture {
                            onTokenSelect?(fromToken, toToken)
                        }
            .frame(width: 350, height: 200)
            .background(gradient)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
        }
    }
}

struct ContractView: View {
    var contractName: String
    var details: String
    var gradient: LinearGradient
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(gradient)
            .frame(width: .infinity, height: 100, alignment: .center)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            .overlay(
                VStack(alignment: .leading) {
                    Text(contractName).bold().foregroundColor(Color.black)
                    Text(details).foregroundColor(Color.gray)
                }
                .padding()
            )
            .padding()
    }
}


struct PortfolioView: View {
    
    @State private var selectedFromToken: String = ""
    @State private var selectedToToken: String = ""
    @ObservedObject var api = InfuraAPI()
    @State private var ethereumAddress: String = ""
    
    let tokens = [
        ("BTC", "USD", "$12,800.49"),
        ("ETH", "USD","$2,500.32"),
        ("MATIC", "USD", "$2,826.97"),
        ("GETH", "USD", "$5,789.99")
    ]
    
    let gradients = [
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]), startPoint: .leading, endPoint: .trailing),
        LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.5), Color.yellow.opacity(0.5)]), startPoint: .leading, endPoint: .trailing),
        LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.5), Color.yellow.opacity(0.5)]), startPoint: .leading, endPoint: .trailing),
        LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.pink.opacity(0.5)]), startPoint: .leading, endPoint: .trailing)
    ]
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    
                    
                    Text("Wallet Portfolio")
                        .foregroundColor(Color.black)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(0..<tokens.count, id: \.self) { index in
                                TokenView(toToken: tokens[index].1,
                                          fromToken: tokens[index].0,
                                          balance: api.balance,
                                          gradient: gradients[index % gradients.count])
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                    
                    Spacer(minLength: 40)
                    
                    Text("Contract Portfolio")
                        .foregroundColor(Color.black)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    VStack {
                        ForEach(0..<5) { index in
                            ContractView(
                                contractName: "Contract \(index)",
                                details: "Details for contract \(index)",
                                gradient: LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.pink.opacity(0.5)]), startPoint: .leading, endPoint: .trailing)
                            )
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .background(gradients[0])
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}

