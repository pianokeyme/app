//
//  ContentView.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-10.
//

import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
    var body: some View {
        NavigationView {
            WelcomeView(imageString: "keymelogo")
        }
        .tint(Color(red: 143/255, green: 0, blue: 26/255))
    }
    
    //add playback rate
    // preferences automatically apply (onTap for piano type and color scheme and onChange for led color
}


@available(iOS 16.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

