//
//  PreferencesView.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-24.
//

import SwiftUI

@available(iOS 16.0, *)
struct PreferencesView: View {
    static var pianoTypes = ["Keyboard (61)", "Grand (88)"]
    static var colorSchemes = ["Default", "Rainbow", "Gradient"]

    // add save button at the top that sends everything to server and then navigates to the recording page
    @State var selectedSize = pianoTypes[0]
    @State var selectedScheme = colorSchemes[0]
    @State var selectedColor = Color(UIColor(red: 1, green: 0, blue: 0, alpha: 1))
    @State var showLibrary = false
    
    var body: some View {
        VStack {
            Form {
                Section("Select Piano Size") {
                    Picker("Piano Type", selection: $selectedSize) {
                        ForEach(PreferencesView.pianoTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                Section {
                    ColorPicker("LED Color", selection: $selectedColor, supportsOpacity: false)
                    Picker("Color Scheme", selection: $selectedScheme) {
                        ForEach(PreferencesView.colorSchemes, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            
            NavigationLink(destination: LibraryView(), isActive: $showLibrary) {
                EmptyView()
            }
            .navigationTitle("Preferences")
            .toolbar {
                Button("Save") {
                    let hex = colorToHex(selectedColor)
                    
                    let preferences = Preferences(size: selectedSize, scheme: selectedScheme, color: hex)
                    
                    ApiService.shared.savePreferences(preferences)
                    
                    showLibrary.toggle()
                }
            }
        }
    }
}

func colorToHex(_ color: Color) -> String {
    guard let components = color.cgColor?.components, components.count >= 3 else {
        return "#ff0000";
    }
    
    let r = min(Int(components[0] * 255.0), 255)
    let g = min(Int(components[1] * 255.0), 255)
    let b = min(Int(components[2] * 255.0), 255)
    
    return String(format: "#%02lX%02lX%02lX", r, g, b)
}

@available(iOS 16.0, *)
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
