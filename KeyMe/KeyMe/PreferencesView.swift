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
    
    func sendColor(_ color: Color) {
        let hex = colorToHex(color)
        
        let preferences = Preferences(size: selectedSize, scheme: selectedScheme, color: hex)
        
        ApiService.shared.savePreferences(preferences)
    }
    
    func sendScheme(_ scheme: String) {
        let hex = colorToHex(selectedColor)
        
        let preferences = Preferences(size: selectedSize, scheme: scheme, color: hex)
        
        ApiService.shared.savePreferences(preferences)
    }

    func sendSize(_ size: String) {
        let hex = colorToHex(selectedColor)
        
        let preferences = Preferences(size: size, scheme: selectedScheme, color: hex)
        
        ApiService.shared.savePreferences(preferences)
    }
    
    func sendPreferences() {
        let hex = colorToHex(selectedColor)
        
        let preferences = Preferences(size: selectedSize, scheme: selectedScheme, color: hex)
        
        ApiService.shared.savePreferences(preferences)
    }
    
    var body: some View {
        VStack {
            Form {
                Section("Select Piano Size") {
                    Picker("Piano Type", selection: $selectedSize) {
                        ForEach(PreferencesView.pianoTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: selectedSize, perform: { newSize in
                        sendSize(newSize)
                    })
                }
                Section {
                    ColorPicker("LED Color", selection: $selectedColor, supportsOpacity: false)
                        .onChange(of: selectedColor, perform: { newColor in
                                sendColor(newColor)
                        })

                    Picker("Color Scheme", selection: $selectedScheme) {
                        ForEach(PreferencesView.colorSchemes, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: selectedScheme, perform: { newScheme in
                            sendScheme(newScheme)
                    })
                }
            }
            
            NavigationLink(destination: LibraryView(), isActive: $showLibrary) {
                EmptyView()
            }
            .navigationTitle("Preferences")
            .toolbar {
                Button("Save") {
                    sendPreferences()
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
