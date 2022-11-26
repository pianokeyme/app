//
//  PreferencesView.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-24.
//

import SwiftUI

@available(iOS 16.0, *)
struct PreferencesView: View {
    // add save button at the top that sends everything to server and then navigates to the recording page
    @State var selectedSize = ""
    @State var selectedScheme = ""
    @State var selectedColor = Color.red
    @State var showLibrary = false

    var pianoTypes = ["Keyboard (61)", "Grand (88)"]
    var colorSchemes = ["Default", "Rainbow", "Gradient"]
    
    var body: some View {
        VStack {
            Form {
                Section("Select Piano Size") {
                    Picker("Piano Type", selection: $selectedSize) {
                        ForEach(pianoTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                Section {
                    ColorPicker("LED Color", selection: $selectedColor, supportsOpacity: false)
                    Picker("Color Scheme", selection: $selectedScheme) {
                        ForEach(colorSchemes, id: \.self) {
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
                    // send values to server
                    showLibrary.toggle()
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
