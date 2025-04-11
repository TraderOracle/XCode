import SwiftUI
import Foundation

func fetchString(from urlString: String, completion: @escaping (String?, Error?) -> Void) {
    // Create URL from string
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "InvalidURLError", code: -1, userInfo: nil))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(nil, error)
            return
        }
        guard let data = data else {
            completion(nil, NSError(domain: "NoDataError", code: -2, userInfo: nil))
            return
        }
        guard let string = String(data: data, encoding: .utf8) else {
            completion(nil, NSError(domain: "StringConversionError", code: -3, userInfo: nil))
            return
        }
        completion(string, nil)
    }
    
    task.resume()
}

struct ContentView: View {
  @State private var selectedDate = Date()
  @State private var businessDays: [Date] = []
  @State private var fetchedText: String = ""
  @State private var userText: String = ""
  @State private var url1: String = "https://tradersmarts.quantkey.com/api/v1/plan.php?lic="
  @State private var url2: String = "&root="
  @State private var url3: String = "&date="
  @State private var url4: String = "&apikey=d8d22b68-1285-4bbd-80d6-e6d5ed13dbbc"
  @State private var errorMessage: String? = nil
  @State private var titleMsg: String = "TraderSmarts"
  @State private var dateMsg: String = ""
  @State private var finalURL: String = ""
  @State private var licMsg: String = ""
  @State private var exportToMotiveWave = false
    
  private let userTextKey = "savedUserText"
  
  struct TSButtonStyle: ButtonStyle {
      func makeBody(configuration: Configuration) -> some View {
          configuration.label
              .font(.headline)
              .frame(maxWidth: .infinity, minHeight: 40)
              .padding(.horizontal, 5)
              .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
              .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      }
  }
  
    var body: some View {
        VStack(spacing: 10) {
            Text(titleMsg)
                .font(.title2)
                .fontWeight(.bold)

          VStack(spacing: 10) {
            HStack {
              DatePicker(
                "Date: ",
                selection: $selectedDate,
                displayedComponents: [.date]
              )
              .datePickerStyle(.automatic)
              .padding()
              .font(.title3)
              .cornerRadius(10)
              .onChange(of: selectedDate) { newValue in
                  print("Selection changed to: \(newValue)")
                  titleMsg = "TraderSmarts for \(dateFormatter.string(from: newValue))"
                  dateMsg = formatDate(date: selectedDate, format: "yyyyMMdd")
              }
              
              Text("License:")
                .font(.title3)
                .foregroundColor(.white)
              
              TextField("XXXXXX-XXX-XXXXXX", text: $userText)
                .cornerRadius(10)
                .padding()
                .onAppear {
                    loadSavedText()
                }
                .onChange(of: userText) {
                    licMsg = userText
                    saveText()
                }
              
              // Checkbox for "Export to MotiveWave"
              Toggle(isOn: $exportToMotiveWave) {
                  Text("Export to MotiveWave")
                      .font(.headline)
              }
              .padding()
              .cornerRadius(10)
              .toggleStyle(SwitchToggleStyle(tint: .blue))
              
            }
            .padding()
            .onAppear {
              businessDays = generateBusinessDays()
              if !businessDays.isEmpty {
                selectedDate = businessDays.first!
              }
            }
          }
          
          HStack(spacing: 15){
            Button("ES") {
              fetchTextFromURL(ticker: "ES")
            }
            .buttonStyle(TSButtonStyle())
            Button("NQ") {
              fetchTextFromURL(ticker: "NQ")
            }
            .buttonStyle(TSButtonStyle())
            Button("CL") {
              fetchTextFromURL(ticker: "CL")
            }
            .buttonStyle(TSButtonStyle())
            Button("BTC") {
              fetchTextFromURL(ticker: "BTC")
            }
            .buttonStyle(TSButtonStyle())
            Button("6E") {
              fetchTextFromURL(ticker: "6E")
            }
            .buttonStyle(TSButtonStyle())
            Button("GC") {
              fetchTextFromURL(ticker: "GC")
            }
            .buttonStyle(TSButtonStyle())
            Button("RTY") {
              fetchTextFromURL(ticker: "RTY")
            }
            .buttonStyle(TSButtonStyle())
            Button("SI") {
              fetchTextFromURL(ticker: "SI")
            }
            .buttonStyle(TSButtonStyle())
            Button("YM") {
              fetchTextFromURL(ticker: "YM")
            }
            .buttonStyle(TSButtonStyle())
          }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                  TextEditor(text: $fetchedText)
                    .font(.title3)
                }
                .frame(maxWidth: .infinity, minHeight: 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .padding()
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
  
  private func formatDate(date: Date, format: String) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = format
      return formatter.string(from: date)
  }
  
  private func saveText() {
      UserDefaults.standard.set(userText, forKey: userTextKey)
  }
  
  private func loadSavedText() {
      if let savedText = UserDefaults.standard.string(forKey: userTextKey) {
          userText = savedText
      }
  }
  
  private func generateBusinessDays() -> [Date] {
    var days: [Date] = []
    let calendar = Calendar.current
    
    let today = Date()
    guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) else {
      return days
    }
    var currentDate = oneYearAgo
    
    while currentDate <= today {
      let weekday = calendar.component(.weekday, from: currentDate)
      
      if weekday != 1 && weekday != 7 {
        days.append(currentDate)
      }
      
      if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
        currentDate = nextDay
      } else {
        break
      }
    }
    
    return days.reversed()
  }
  
  private var dateFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      return formatter
  }
  
  func fetchTextFromURL(ticker: String) {
     finalURL = url1 + licMsg + url2 + ticker + url3 + dateMsg + url4

        fetchString(from: finalURL) { (string, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let string = string {
              fetchedText = cleanHTMLTags(from: string)
                print("Fetched string: \(string)")
            }
        }
    }
    
    func cleanHTMLTags(from text: String) -> String {
        var cleanedText = text
        
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
            cleanedText = regex.stringByReplacingMatches(
                in: cleanedText,
                options: [],
                range: NSRange(location: 0, length: cleanedText.count),
                withTemplate: ""
            )
        } catch {
            print("Error removing HTML tags: \(error)")
        }
        
      cleanedText = cleanedText.replacingOccurrences(of: "Contract ", with: "\nContract ")
      cleanedText = cleanedText.replacingOccurrences(of: "TraderSmarts Numbers for", with: "\n\nTraderSmarts Numbers for")
      cleanedText = cleanedText.replacingOccurrences(of: "MTS Numbers: ", with: "\nMTS Numbers: ")
      
      cleanedText = cleanedText.replacingOccurrences(of: " FTD", with: "")
      cleanedText = cleanedText.replacingOccurrences(of: " FTU", with: "")
      cleanedText = cleanedText.replacingOccurrences(of: "Extreme Short", with: "    Extreme Short\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Highest Odds Short", with: "    Highest Odds Short\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Range Short", with: "   Range Short\n\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Line in the Sand", with: "  Line in the Sand\n\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Range Long", with: "   Range Long\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Highest Odds Long", with: "   Highest Odds Long\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Extreme Long", with: "   Extreme Long\n\n")
      
      cleanedText = cleanedText.replacingOccurrences(of: "<td style = \"text-align:right\">", with: "\n")
      cleanedText = cleanedText.replacingOccurrences(of: "&nbsp&nbsp", with: "")
      cleanedText = cleanedText.replacingOccurrences(of: "Execution/Target Zones:", with: "\n\nExecution/Target Zones:\n")
      
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

