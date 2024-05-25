//
//  ContentView.swift
//  JSONPropertyPicker
//
//  Created by Thilina Chamath Hewagama on 2024-03-27.
//

import SwiftUI

struct ContentView: View {
    @State private var inputJson: String = ""
    @State private var propertyToSearch: String = ""
    @State private var propertyValues: [String] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Paste the JSON here: ")
            TextEditor(text: $inputJson)
                .border(Color.gray, width: 1)
                .frame(maxHeight: .infinity)

            HStack {
                TextField("Enter JSON property", text: $propertyToSearch)
                Button("Process") {
                    processJson()
                }
            }.padding()

            TextEditor(text: .constant(propertyValues.joined(separator: "\n")))
                .border(Color.gray, width: 1)
                .frame(maxHeight: .infinity)
        }
        .padding()
    }

    private func processJson() {
        guard let data = inputJson.data(using: .utf8) else { return }
        propertyValues = extractValues(from: data, for: propertyToSearch)
    }

    private func extractValues(from data: Data, for key: String) -> [String] {
        var extractedValues: [String] = []
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any] {
                extractValues(from: dictionary, forKey: key, into: &extractedValues)
            } else if let array = json as? [Any] {
                for item in array {
                    if let dictionary = item as? [String: Any] {
                        extractValues(from: dictionary, forKey: key, into: &extractedValues)
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        return extractedValues
    }

    private func extractValues(from dictionary: [String: Any], forKey key: String, into extractedValues: inout [String]) {
        if let value = dictionary[key] as? String {
            extractedValues.append(value)
        } else {
            for (_, value) in dictionary {
                if let subDictionary = value as? [String: Any] {
                    extractValues(from: subDictionary, forKey: key, into: &extractedValues)
                } else if let array = value as? [Any] {
                    for item in array {
                        if let subDictionary = item as? [String: Any] {
                            extractValues(from: subDictionary, forKey: key, into: &extractedValues)
                        }
                    }
                }
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
}
