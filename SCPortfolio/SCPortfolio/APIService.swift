//
//  APIService.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-09.
//

import Foundation
import SwiftUI
import Combine

struct BalanceResponse: Codable {
    let status: String
    let message: String
    let result: String
}

class EthereumAPIService {
    private var apiKey: String = "YOUR_API_KEY_HERE"
    private let baseUrl: String = "https://api.etherscan.io/api"

    func getBalance(for address: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(baseUrl)?module=account&action=balance&address=\(address)&tag=latest&apikey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let balanceResponse = try? JSONDecoder().decode(BalanceResponse.self, from: data) else {
                // Handle decoding error
                return
            }
            
            completion(.success(balanceResponse.result))
        }.resume()
    }
}


class InfuraAPIService {
    private var apiKey : String
    private let baseUrl : String
    
    init(apiKey: String) {
            self.apiKey = apiKey
            self.baseUrl = "https://mainnet.infura.io/v3/\(apiKey)"
    }
    
    func hexStringToEth(_ hexString: String) -> Double? {
        guard let intValue = Int(hexString, radix: 16) else {
            print("Invalid hexadecimal string")
            return nil
        }
        let ethValue = Double(intValue) / 1_000_000_000_000_000_000
        return ethValue
    }
    
    func getBalance(for address: String, completion: @escaping (Result<Decimal, Error>) -> Void) {
        guard let url = URL(string: baseUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": [address, "latest"],
            "id": 1
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                // Handle missing data error
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? String {
                    
                    let hexBalance = result
                    let balanceInWei = Decimal(string: String(Int(hexBalance, radix: 16) ?? 0)) ?? Decimal(0)
                    let balanceInEther = balanceInWei / pow(10, 18)
                    
                    
                    DispatchQueue.main.async {
                        completion(.success(balanceInWei))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

}

struct TokenAPIView: View {
    var token: String
    var address: String
    var gradient: LinearGradient
    @State private var balance: String = "Loading..."
    private var apiService: InfuraAPIService
    
    init(token: String, address: String, gradient: LinearGradient, apiKey: String) {
        self.token = token
        self.address = address
        self.gradient = gradient
        self.apiService = InfuraAPIService(apiKey: apiKey)
    }

    var body: some View {
        VStack {
            Text(token)
                .padding()
                .foregroundColor(Color.white)
                .font(.title)
            
            Text(balance)
                .padding()
                .foregroundColor(Color.white)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
        }
        .onAppear {
            apiService.getBalance(for: address) { result in
                switch result {
                case .success(let balanceInEther):
                    let formatter = NumberFormatter()
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 8
                    formatter.numberStyle = .decimal
                    if let formattedBalance = formatter.string(for: balanceInEther) {
                        self.balance = "\(formattedBalance) ETH"
                    } else {
                        self.balance = "Error"
                    }
                case .failure:
                    self.balance = "Error"
                }
            }
        }
        .frame(width: 350, height: 200)
        .background(gradient)
        .cornerRadius(25)
    }
}


struct TokenAPIView_Previews : PreviewProvider {
    static var previews: some View {
        TokenAPIView(
            token: "ETH (BTC)", address: "0x71C7656EC7ab88b098defB751B7401B5f6d8976F", gradient: LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing), apiKey: "c3b1b4a5ddd6492cbc96105b8004e0aa"
        )
    }
}
