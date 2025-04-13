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
  @State private var statusMsg: String = ""
  @State private var exportToMotiveWave = false
  @State private var selectedFontSize: Int = 16
  @State private var isExpanded: Bool = false
  @State private var isButtonHovered = false
  @State private var showDatePicker = false
  
  private let userTextKey = "savedUserText"
  private let fontSizes = Array(5...46)

    var body: some View {
        VStack(spacing: 2) {

            Text(titleMsg)
                .font(.title)
                .fontWeight(.bold)
                .headerProminence(.increased)
                .foregroundColor(Color.cyan)
          
          VStack() {
            HStack() {
              VStack() {
                          Button {
                              withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                  showDatePicker.toggle()
                              }
                          } label: {
                              HStack {
                                  Text(dateFormatter.string(from: selectedDate))
                                      .font(.headline)
                                      .foregroundColor(.primary)
                                  
                                  Spacer()
                                  
                                  Image(systemName: "calendar")
                                      .font(.headline)
                                      .foregroundColor(.white)
                                      .rotationEffect(.degrees(showDatePicker ? 180 : 0))
                                      .animation(.spring(response: 0.3), value: showDatePicker)
                              }
                              .padding()
                              .background(
                                  RoundedRectangle(cornerRadius: 8)
                                      .fill(Color(.blue))
                                      .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                              )
                          }
                          .buttonStyle(TSButtonStyle())
                          
                          // Expandable date picker
                          if showDatePicker {
                              VStack {
                                  DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                      .datePickerStyle(.graphical)
                                      .tint(.blue)
                                      .padding(.horizontal, 8)
                                      .onAppear {
                                        dateMsg = formatDate(date: selectedDate, format: "yyyyMMdd")
                                        titleMsg = "TraderSmarts for \(dateFormatter.string(from: selectedDate))"
                                      }
                                      .onChange(of: selectedDate) {
                                          print("Selection changed to: \(selectedDate)")
                                          titleMsg = "TraderSmarts for \(dateFormatter.string(from: selectedDate))"
                                          dateMsg = formatDate(date: selectedDate, format: "yyyyMMdd")
                                      }
                                  
                                  Button {
                                      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                          showDatePicker = false
                                      }
                                  } label: {
                                      Text("Confirm")
                                          .font(.headline)
                                          .foregroundColor(.white)
                                          .frame(height: 20)
                                          .frame(maxWidth: .infinity)
                                          .padding(.horizontal, 8)
                                          .padding(.bottom, 8)
                                          .buttonStyle(TSButtonStyle())
                                  }
                              }
                              .background(
                                  RoundedRectangle(cornerRadius: 12)
                                      .fill(Color(.blue))
                                      .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                              )
                              .transition(.scale(scale: 0.95).combined(with: .opacity))
                          }
                      }
                      .padding()
              
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
              
              Picker("Font Size", selection: $selectedFontSize) {
                  ForEach(fontSizes, id: \.self) { size in
                      Text("\(size) pt").tag(size)
                  }
              }
              .pickerStyle(MenuPickerStyle())
              .padding()
            }
            .padding()
          }
          
          HStack(spacing: 5){
            
            Button(action: {
              fetchTextFromURL(ticker: "6E")
            }) {
                HStack {
                  //Image(systemName: "drop.halffull")
                  Text("6E")
                }
            }
            .buttonStyle(TSWildButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "CL")
            }) {
                HStack {
                  Image(systemName: "drop.halffull")
                  Text("Oil")
                }
            }
            .buttonStyle(TSGrayButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "ES")
            }) {
                HStack {
                  Image(systemName: "dollarsign")
                  Text("S&P 500")
                }
            }
            .buttonStyle(TSRedButtonStyle())
            
            Button(action: {
              fetchTextFromURL(ticker: "GC")
            }) {
                HStack {
                  Image(systemName: "dollarsign.bank.building")
                  Text("Gold")
                }
            }
            .buttonStyle(TSYellowButtonStyle())
            
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
            .buttonStyle(TSPurpleButtonStyle())

          }.padding()
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
          
          VStack(alignment: .leading) {
              TextEditor(text: $fetchedText)
                  .font(.system(size: CGFloat(selectedFontSize)))
                  .cornerRadius(8)
                  .foregroundColor(.white)
          }
          .frame(maxWidth: .infinity, minHeight: 1)
          .background(Color(.gray).opacity(0.5))
          .cornerRadius(12)
        
          HStack(spacing: 1){
            
            Link(destination: URL(string: "https://tradersmarts.net/")!) {
              HStack {
                Image(systemName: "link.circle.fill")
                Text(userText.isEmpty ? "Sign up for a Plan" : "Visit our website")
              }
              .padding(.vertical, 6)
              .padding(.horizontal, 24)
              .background(
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.cyan.opacity(0.8))
                  .overlay(
                    RoundedRectangle(cornerRadius: 10)
                      .stroke(Color.black, lineWidth: 1)
                      .scaleEffect(isButtonHovered ? 1.13 : 1.0)
                      .opacity(isButtonHovered ? 0.8 : 0.0)
                  )
              )
              .foregroundColor(.white)
              .font(.headline)
              .shadow(radius: isButtonHovered ? 0 : 4)
              .scaleEffect(isButtonHovered ? 1.13 : 1.0)
              .onHover { hovering in
                withAnimation(.spring()) {
                  isButtonHovered = hovering
                }
              }
            } // link
            
            

          }.padding(.vertical) // hstack
          
        }
        .padding()// main window
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

    print("URL: \(finalURL)")
    
        fetchString(from: finalURL) { (string, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let string = string {
              fetchedText = cleanHTMLTags(from: string)
              if (fetchedText == "")
              {
                fetchedText = "No results found.  Check the following: \n\n1. Is your license key entered correctly? \n2. Is the date you selected, a trading date?\n\nIf you continue having issues, please contact tony@tradersmarts.net"
              }
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


