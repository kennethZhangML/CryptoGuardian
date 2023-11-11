//
//  InfuraFetchTH.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-09.
//

import Foundation
import SwiftUI
import CoreML
import CoreML

class TransactionHistoryModel {
    
    private var apiKey : String
    private var baseURL : String
    
    init(apiKey : String) {
        self.apiKey = apiKey
        self.baseURL = "https://mainnet.infura.io/v3/\(apiKey)"
    }
    
    func traceTransaction(toAddress : String, completion: @escaping (Result<Decimal, Error>) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body : [String: Any] = [
            "jsonrpc" : "2.0",
            "method" : "trace_transaction",
            "params" : [toAddress],
            "id": 1
        ]
        
        request.httpBody = try?JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? String {
                    let transactionAddress = result
                    
                }
            }
        }
    }
}
