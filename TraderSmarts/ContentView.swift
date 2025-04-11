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
  @State private var tickerMsg: String = ""
  @State private var exportToMotiveWave = false
    
  private let userTextKey = "savedUserText"
  
  @State private var selectedOption = 0
  let options = ["6E", "CL", "ES", "GC", "NQ", "RTY", "YM"]
  
  struct TSGreenButtonStyle: ButtonStyle {
      func makeBody(configuration: Configuration) -> some View {
          configuration.label
              .font(.headline)
              .frame(maxWidth: .infinity, minHeight: 40)
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
              .frame(maxWidth: .infinity, minHeight: 40)
              .padding(.horizontal, 5)
              .background(configuration.isPressed ? Color(red: 87/255, green: 178/255, blue: 247/255) : Color.blue)
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
              .datePickerStyle(.compact)
              .padding()
              .font(.title3)
              .onAppear {
                dateMsg = formatDate(date: selectedDate, format: "yyyyMMdd")
                titleMsg = "TraderSmarts for \(dateFormatter.string(from: selectedDate))"
              }
              
              .onChange(of: selectedDate) {
                  print("Selection changed to: \(selectedDate)")
                  titleMsg = "TraderSmarts for \(dateFormatter.string(from: selectedDate))"
                  dateMsg = formatDate(date: selectedDate, format: "yyyyMMdd")
              }
              
              Text("License:")
                .font(.title3)
                .foregroundColor(.white)
              
              TextField("XXXXXX-XXX-XXXXXX", text: $userText)
                .cornerRadius(10)
                .padding()
                .font(.system(size: 15))
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
              .toggleStyle(SwitchToggleStyle(tint: .green))
              
            }
            .padding()
            .onAppear {
            }
          }
          
//          Picker("", selection: $selectedOption) {
//              ForEach(0..<options.count, id: \.self) { index in
//                  Text(options[index]).tag(index)
//              }
//          }
//          .pickerStyle(.segmented)
//          .font(.title2)
//          .background(Color.blue)
//          .foregroundColor(.white)
//          .cornerRadius(3)
//          .padding()
          
          HStack(spacing: 5){
            
            Button(action: {
              fetchTextFromURL(ticker: "6E")
            }) {
                HStack {
                  //Image(systemName: "drop.halffull")
                  Text("6E")
                }
            }
            .buttonStyle(TSButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "CL")
            }) {
                HStack {
                  Image(systemName: "drop.halffull")
                  Text("Oil")
                }
            }
            .buttonStyle(TSGreenButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "ES")
            }) {
                HStack {
                  Image(systemName: "dollarsign")
                  Text("S&P 500")
                }
            }
            .buttonStyle(TSButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "GC")
            }) {
                HStack {
                  Image(systemName: "dollarsign.bank.building")
                  Text("Gold")
                }
            }
            .buttonStyle(TSGreenButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "NQ")
            }) {
                HStack {
                  Image(systemName: "desktopcomputer")
                  Text("Nasdaq")
                }
            }
            .buttonStyle(TSButtonStyle())

            Button(action: {
              fetchTextFromURL(ticker: "RTY")
            }) {
                HStack {
                  Image(systemName: "dollarsign.ring.dashed")
                  Text("RTY")
                }
            }
            .buttonStyle(TSGreenButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "YM")
            }) {
                HStack {
                  Image(systemName: "house.fill")
                  Text("Dow")
                }
            }
            .buttonStyle(TSButtonStyle())

          }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
          
          VStack(alignment: .leading) {
              TextEditor(text: $fetchedText)
                  .font(.title3)
                  .cornerRadius(8)
          }
          .frame(maxWidth: .infinity, minHeight: 1)
          .background(Color(.gray).opacity(0.5))
          .cornerRadius(12)
          
          
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
  
  private var dateFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      return formatter
  }
  
  func fetchTextFromURL(ticker: String) {
    tickerMsg = ticker.uppercased()
     finalURL = url1 + licMsg + url2 + ticker + url3 + dateMsg + url4

        fetchString(from: finalURL) { (string, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let string = string {
              fetchedText = cleanHTMLTags(from: string)
                //print("Fetched string: \(string)")
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
        
      cleanedText = cleanedText.replacingOccurrences(of: tickerMsg + " Contract Notes:", with: "\n\n" + tickerMsg + " Contract Notes:")
      cleanedText = cleanedText.replacingOccurrences(of: tickerMsg + " Macro Technical View:", with: "\n\n" + tickerMsg + " Macro Technical View:")
      cleanedText = cleanedText.replacingOccurrences(of: tickerMsg + " Execution/Target Zones:", with: "\n\n" + tickerMsg + " Execution/Target Zones:\n")
      cleanedText = cleanedText.replacingOccurrences(of: "TraderSmarts Numbers for " + tickerMsg + ":", with: "\n\nTraderSmarts Numbers for " + tickerMsg + ": ")
      
      cleanedText = cleanedText.replacingOccurrences(of: " FTD", with: "")
      cleanedText = cleanedText.replacingOccurrences(of: " FTU", with: "")
      cleanedText = cleanedText.replacingOccurrences(of: "Extreme Short", with: " Extreme Short\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Highest Odds Short", with: " Highest Odds Short\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Range Short", with: " Range Short\n\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Line in the Sand", with: " Line in the Sand\n\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Range Long", with: " Range Long\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Highest Odds Long", with: " Highest Odds Long\n")
      cleanedText = cleanedText.replacingOccurrences(of: "Extreme Long", with: " Extreme Long\n\n")
      
      cleanedText = cleanedText.replacingOccurrences(of: "<td style = \"text-align:right\">", with: "\n")
      cleanedText = cleanedText.replacingOccurrences(of: "&nbsp&nbsp", with: "")
      cleanedText = cleanedText.replacingOccurrences(of: "Contract " + tickerMsg, with: "\nContract " + tickerMsg)
      
      cleanedText = cleanedText.replacingOccurrences(of: "   ", with: " ")
      cleanedText = cleanedText.replacingOccurrences(of: "  ", with: " ")
      cleanedText = cleanedText.replacingOccurrences(of: "   ", with: " ")
      cleanedText = cleanedText.replacingOccurrences(of: "  ", with: " ")
      
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

