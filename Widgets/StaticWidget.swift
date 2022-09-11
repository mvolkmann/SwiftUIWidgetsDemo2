import CoreLocation
import SwiftUI
import WeatherKit
import WidgetKit

struct StaticProvider: TimelineProvider {
    typealias Entry = WeatherEntry

    static let mockEntry = Entry(
        date: Date(),
        city: "St. Charles",
        temperature: 62.4,
        windSpeed: 5.7
     )

    func placeholder(in context: Context) -> Entry {
        StaticProvider.mockEntry
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (WeatherEntry) -> ()
    ) {
        completion(StaticProvider.mockEntry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let weatherService = WeatherService()
        let location = CLLocation(latitude: 38.71013, longitude: -90.59503)
        Task {
            do {
                print("getting weather data")
                let weather = try await weatherService.weather(for: location)
                print("got weather data")
                let current = weather.currentWeather
                let now = Date()
                let entries: [WeatherEntry] = [
                    WeatherEntry(
                        date: now,
                        city: "Emerald Isle",
                        temperature: current.temperature.value,
                        windSpeed: current.wind.speed.value
                    )
                ]

                // iOS will likely not update more frequently than once
                // every 15 minutes.  The widget is also updated every
                // time the chart displayed in the app is updated.
                // See the updateWidgets method in HealthChartView.swift.
                let later = now.addingTimeInterval(15 * 60) // seconds
                let timeline = Timeline(entries: entries, policy: .after(later))
                completion(timeline)
            } catch {
                print("StaticProvider.getTimeline: error =", error)
            }
        }
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: Double
    let windSpeed: Double
}

struct StaticEntryView : View {
    var entry: StaticProvider.Entry

    var body: some View {
        VStack {
            Text(entry.date, style: .date)
            Text(entry.date, style: .time)
            Text(entry.city)
            Text("Temperature: \(entry.temperature.roundedString) degrees")
            Text("Wind Speed: \(entry.windSpeed.roundedString) MPH")
        }
    }
}

@main
struct StaticWidget: Widget {
    let kind: String = "StaticWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StaticProvider()
        ) { entry in
            StaticEntryView(entry: entry)
        }
        .configurationDisplayName("Static Weather")
        .description("This is a static weather widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct StaticWidget_Previews: PreviewProvider {
    static var previews: some View {
        StaticEntryView(entry: StaticProvider.mockEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
