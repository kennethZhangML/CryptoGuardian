//
//  TokenDetailView.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-10.
//

import SwiftUI


struct TokenDetailView: View {
    @State var fromToken : String
    @State var toToken : String
    

    var body: some View {
        CryptoGraphView(fromToken: fromToken, toToken: toToken)
    }
}

struct TokenDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TokenDetailView(fromToken: "BTC", toToken: "USD")
    }
}
