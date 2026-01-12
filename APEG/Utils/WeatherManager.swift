import Foundation
import WeatherKit
import CoreLocation

@MainActor
class WeatherManager: ObservableObject {
    @Published var temperature: String = "--"
    @Published var condition: String = "Soleado"
    @Published var symbol: String = "sun.max.fill"
    @Published var isLoading = false
    
    private let weatherService = WeatherService.shared
    
    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let weather = try await weatherService.weather(for: location)
            let current = weather.currentWeather
            
            // Format temperature
            let tempValue = current.temperature.converted(to: .celsius).value
            self.temperature = String(format: "%.0f°C", tempValue)
            
            // Condition name (in Spanish since the app is Spanish-localized)
            self.condition = translateCondition(current.condition)
            self.symbol = current.symbolName
            
        } catch {
            print("WeatherKit Error: \(error.localizedDescription)")
            // Fallback default values or handle error
        }
    }
    
    private func translateCondition(_ condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear: return "Despejado"
        case .cloudy: return "Nublado"
        case .mostlyCloudy, .partlyCloudy: return "Parcialmente Nublado"
        case .drizzle: return "Llovizna"
        case .hail: return "Granizo"
        case .heavyRain: return "Lluvia Fuerte"
        case .heavySnow: return "Nieve Fuerte"
        case .isolatedThunderstorms: return "Tormentas Aisladas"
        case .rain: return "Lluvia"
        case .scatteredThunderstorms: return "Tormentas Dispersas"
        case .snow: return "Nieve"
        case .sunShowers: return "Chubascos de Sol"
        case .thunderstorms: return "Tormentas"
        case .windy: return "Ventoso"
        case .foggy: return "Niebla"
        case .haze: return "Bruma"
        case .smoky: return "Humo"
        case .blowingDust: return "Polvo"
        default: return "Soleado"
        }
    }
}
