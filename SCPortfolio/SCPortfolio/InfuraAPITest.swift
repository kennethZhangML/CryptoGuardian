//
//  InfuraAPITest.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-09.
//

import Foundation
import SwiftUI

extension String {
    func stripPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}


//func hexToDecimal(hexString: String) -> Int {
//    var formattedHexString = hexString
//    if formattedHexString.hasPrefix("0x") {
//        formattedHexString = String(formattedHexString.dropFirst(2))
//    }
//
//    let hexDigits = Array(formattedHexString)
//    var decimalValue = 0
//    var base: Int = 1
//
//    for digit in hexDigits.reversed() {
//        if let decimalDigit = digit.hexDigitValue {
//            decimalValue += decimalDigit * base
//            base *= 16
//        } else {
//            print("Invalid hexadecimal character found: \(digit)")
//            return 0
//        }
//    }
//
//    return decimalValue
//}


class InfuraAPI: ObservableObject {
    @Published var balance: String = "Fetching..."
    
    func getEtherBalance(address: String) {
        let url = URL(string: "https://mainnet.infura.io/v3/c3b1b4a5ddd6492cbc96105b8004e0aa")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": ["\(address)", "latest"],
            "id": 1
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData
                
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.balance = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? String {
                
                let weiBalanceBigInt = NSDecimalNumber(string: result)
                let etherDivisor = NSDecimalNumber(string: "1000000000000000000")
                let etherBalance = weiBalanceBigInt.dividing(by: etherDivisor)
                DispatchQueue.main.async {
                    _ = "\(etherBalance)"
                    print("Ether Balance: \(result)")
                    self?.balance = "\(result) ETH"
                }
            } else {
                DispatchQueue.main.async {
                    self?.balance = "Error fetching balance"
                }
            }

        }
        
        task.resume()
    }
}

struct EthereumBalanceView: View {
    @ObservedObject var api = InfuraAPI()
    
    
    var body: some View {
        Text(api.balance)
            .onAppear {
                api.getEtherBalance(address: "0x71C7656EC7ab88b098defB751B7401B5f6d8976F")
            }
    }
}

struct EthereumBalanceView_Previews: PreviewProvider {
    static var previews: some View {
        EthereumBalanceView()
    }
}

