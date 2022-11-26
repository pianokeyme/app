//
//  WelcomeView.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-24.
//

import SwiftUI

@available(iOS 16.0, *)
struct WelcomeView: View {
    var imageString: String
    var body: some View {
        ZStack {
            VStack {
                Image(imageString)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .padding()
                
                Text("KeyMe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                    .padding()
                
                Text("Visualize, Record, Playback")
                    .foregroundColor(Color.black.opacity(0.5))
                
                Spacer()
                
                NavigationLink(destination: SetupWifiView(), label: {
                    PrimaryButton(title: "Get Started")
                })
                .navigationTitle("Welcome")
                .navigationBarTitleDisplayMode(.inline)
            }
            .padding()
        }
    }
}

struct PrimaryButton: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 143/255, green: 0, blue: 26/255))
            .cornerRadius(50)
    }
}

@available(iOS 16.0, *)
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(imageString: "keymelogo")
    }
}
