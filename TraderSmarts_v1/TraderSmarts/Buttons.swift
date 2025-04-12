
import SwiftUI
import Foundation

struct TSGrayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color(red: 115/255, green: 98/255, blue: 83/255).opacity(0.8) : Color(red: 115/255, green: 98/255, blue: 83/255))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TSPurpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color(red: 117/255, green: 36/255, blue: 179/255).opacity(0.8) : Color(red: 117/255, green: 36/255, blue: 179/255))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TSRedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color(red: 156/255, green: 25/255, blue: 25/255).opacity(0.8) : Color(red: 156/255, green: 25/255, blue: 25/255))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TSWildButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color(red: 73/255, green: 58/255, blue: 214/255).opacity(0.8) : Color(red: 73/255, green: 58/255, blue: 214/255))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TSYellowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color(red: 201/255, green: 161/255, blue: 28/255).opacity(0.8) : Color(red: 201/255, green: 161/255, blue: 28/255))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TSGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color.green.opacity(0.8) : Color(red: 33/255, green: 127/255, blue: 110/255))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TSButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 30)
            .padding(.horizontal, 5)
            .background(configuration.isPressed ? Color(red: 87/255, green: 178/255, blue: 247/255) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

private func exportToCSV(date: Date) {
    // Create a date formatter for CSV export (YYYY-MM-DD format)
    let exportFormatter = DateFormatter()
    exportFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = exportFormatter.string(from: date)
    
    // Create CSV content
    let csvContent = "Date\n\(dateString)"
    
    // Get the documents directory
    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        // Create the file URL
        let fileURL = documentsDirectory.appendingPathComponent("MotiveWave.csv")
        
        do {
            // Write to file
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Successfully exported to \(fileURL.path)")
        } catch {
            print("Failed to export CSV: \(error.localizedDescription)")
        }
    }
}




