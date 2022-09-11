import SwiftUI
import WeatherKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    let weatherService = WeatherService.shared

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        // This task will run again every time the value of the id changes.
        .task(id: locationManager.currentLocation) {
            do {
                if let location = locationManager.currentLocation {
                    let weather = try await weatherService.weather(for: location)
                    print("weather =", weather)
                }
            } catch {
                print("ContentView.body: error =", error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
