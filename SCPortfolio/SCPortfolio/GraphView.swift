//
//  GraphView.swift
//  SCPortfolio
//
//  Created by Kenneth Zhang on 2023-11-10.
//


import Foundation
import SwiftUI
import Combine

struct NeumorphicTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white.opacity(0.4))
            .cornerRadius(20)
            .shadow(color: .white, radius: 3, x: -5, y: -5)
            .shadow(color: .black.opacity(0.2), radius: 3, x: 5, y: 5)
            .padding(.horizontal)
    }
}

struct CryptoPrice: Codable {
    let price: String
    let time: String
}

struct CryptoData: Codable {
    let base: String
    let currency: String
    let prices: [CryptoPrice]
}

struct HistoricPrices: Decodable {
    let data: PriceData
}

struct PriceData: Decodable {
    let base: String
    let currency: String
    let prices: [Price]
}

struct Price: Decodable {
    let price: String
    let time: String
}

class CryptoGraphViewModel: ObservableObject {
    @Published var graphPoints: [CGPoint] = []
    @Published var cryptoData: CryptoData?
    
    @Published var movingAverages: [CGPoint] = []
    @Published var touchLocation: CGPoint?
    @Published var selectedPrice: CryptoPrice? = nil
    @Published var topCryptos: [CryptoPrice] = []
    
    private var fromToken : String
    private var toToken : String
    @Published private var tokenPair : String
    
    init() {
            self.fromToken = "BTC"  // Default value
            self.toToken = "USD"    // Default value
            self.tokenPair = "\(fromToken)-\(toToken)"
        }
    
    func setFromToken(_ token: String) {
            self.fromToken = token
            updateTokenPair()
        }

    func setToToken(_ token: String) {
        self.toToken = token
        updateTokenPair()
    }

    private func updateTokenPair() {
        self.tokenPair = "\(fromToken)-\(toToken)"
        fetchHistoricPrices()
    }

    func fetchHistoricPrices() {
        self.tokenPair = "\(fromToken)-\(toToken)"
        guard let url = URL(string: "https://api.coinbase.com/v2/prices/\(tokenPair)/historic") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let historicPrices = try decoder.decode(HistoricPrices.self, from: data)
                let cryptoPrices = historicPrices.data.prices.map { CryptoPrice(price: $0.price, time: $0.time) }
                let cryptoData = CryptoData(base: historicPrices.data.base, currency: historicPrices.data.currency, prices: cryptoPrices)
                
                DispatchQueue.main.async {
                    self?.cryptoData = cryptoData
                    self?.processData()
                }
            } catch {
                print("Error parsing data: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    func processData() {
        guard let prices = self.cryptoData?.prices else { return }
        
        let priceValues = prices.compactMap { Double($0.price) }
        let maxPrice = priceValues.max() ?? 0
        let minPrice = priceValues.min() ?? 0
        
        let normalizedPrices = priceValues.map { ($0 - minPrice) / (maxPrice - minPrice) }
        self.graphPoints = normalizedPrices.enumerated().map { index, normalizedPrice in
            let xPosition = CGFloat(index) / CGFloat(normalizedPrices.count - 1)
            let yPosition = 1.0 - CGFloat(normalizedPrice)
            return CGPoint(x: xPosition, y: yPosition)
        }
    }
    
    func valueForLocation(_ location: CGPoint, frame: CGRect) {
        guard let prices = self.cryptoData?.prices, !prices.isEmpty else { return }
        
        let step = frame.width / CGFloat(prices.count - 1)
        let index = max(0, min(prices.count - 1, Int((location.x / step).rounded())))
        selectedPrice = prices[index]
        
        touchLocation = CGPoint(x: CGFloat(index) * step, y: location.y)
    }
}


extension CryptoGraphViewModel {
    func calculateMovingAverage(period: Int = 5) -> [CGPoint] {
        guard period > 0, graphPoints.count >= period else { return [] }

        var movingAverages: [CGPoint] = []
        for index in 0..<(graphPoints.count - period) {
            let subset = graphPoints[index..<(index + period)]
            let averageY = subset.map { $0.y }.reduce(0, +) / CGFloat(period)
            let averageX = subset.map { $0.x }.reduce(0, +) / CGFloat(period)
            movingAverages.append(CGPoint(x: averageX, y: averageY))
        }

        return movingAverages
    }
}

struct CryptoGraphView: View {
    @StateObject private var viewModel = CryptoGraphViewModel()
    @State private var frame: CGRect = .zero
    
    @State var fromToken: String = "BTC"  // Default value
    @State var toToken: String = "USD"    // Default value
    
    var body: some View {
        ZStack {
            NeumorphicBackground()
            
            VStack {
                Text("\(fromToken)-\(toToken) Conversion")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                HStack {
                    TextField("From Token", text: $fromToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    TextField("To Token", text: $toToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }

                GeometryReader { geometry in
                    if !viewModel.graphPoints.isEmpty {
                        ZStack {
                            NeumorphicBackground()
                                .frame(width: .infinity, height: .infinity)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 5, y: 5)
                                .padding()

                            LineGraph(points: viewModel.graphPoints)
                                .trim(to: 1)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                .padding()
                                .background(Color.white.opacity(0.3).cornerRadius(10))
                                .shadow(radius: 5)
                                .padding()

                            LineGraph(points: viewModel.calculateMovingAverage())
                                .trim(to: 1)
                                .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                .padding()
                        }
                        .onAppear {
                            frame = geometry.frame(in: .local)
                        }
                    } else {
                        Text("No data available.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.setFromToken(fromToken)
            viewModel.setToToken(toToken)
        }
        .onChange(of: fromToken) { newValue in
            viewModel.setFromToken(newValue)
        }
        .onChange(of: toToken) { newValue in
            viewModel.setToToken(newValue)
        }
    }
}


struct NeumorphicBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

struct LineGraph: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }

        let scaleFactor = CGSize(width: rect.width, height: rect.height)
        let scaledPoints = points.map { CGPoint(x: $0.x * scaleFactor.width, y: $0.y * scaleFactor.height) }

        path.move(to: scaledPoints.first!)
        for point in scaledPoints.dropFirst() {
            path.addLine(to: point)
        }

        return path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }
}

struct TooltipView: View {
    let location: CGPoint
    let value: String

    var body: some View {
        Text(value)
            .font(.caption)
            .padding(5)
            .background(Color.white)
            .cornerRadius(5)
            .shadow(radius: 5)
            .position(location)
    }
}

extension View {
    func addNeumorphism() -> some View {
        self
            .shadow(color: Color.white.opacity(0.8), radius: 10, x: -5, y: -5)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
    }
}

struct CryptoGraphView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoGraphView(fromToken: "BTC", toToken: "USD")
    }
}
