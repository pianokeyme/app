//
//  SetupWifiView.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-24.
//

import SwiftUI

@available(iOS 16.0, *)
struct SetupWifiView: View {
    @State private var wifi_ssid: String = ""
    @State private var wifi_password: String = ""
    @State var showPreferences = false

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Enter your Wi-Fi Credentials")
                        .font(.title2)
                        .padding()
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                    
                    TextField("SSID", text: $wifi_ssid)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(red: 143/255, green: 0, blue: 26/255), lineWidth: 3))
                        .padding(.vertical)
                    
                    TextField("Password", text: $wifi_password)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(red: 143/255, green: 0, blue: 26/255), lineWidth: 3))
                    
                    Spacer()
                    
                    Text("Please connect to KeyMe Wi-Fi before submitting")
                        .foregroundColor(Color.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                    
                    PrimaryButton(title: "Submit")
                        .onTapGesture {
                            sendWifi(wifi_ssid: self.wifi_ssid, wifi_password: self.wifi_password)
                            showPreferences.toggle()
                        }
                        .padding(.vertical)
                        .disabled(wifi_ssid.isEmpty || wifi_password.isEmpty)
                        .opacity((wifi_ssid.isEmpty || wifi_password.isEmpty) ? 0.5 : 1.0)
                    
                    NavigationLink(destination: PreferencesView(), isActive: $showPreferences) {
                        EmptyView()
                    }
                    .navigationTitle("Connect to Arduino")
                    .navigationBarTitleDisplayMode(.inline)
                }
                Spacer()
                Divider()
                Spacer()
                NavigationLink(destination: PreferencesView(), label: {
                    Text("If you don't see RED, please CLICK HERE")
                        .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                        .padding(.vertical)
                })
            }
            .padding()
        }
    }
}

func sendWifi(wifi_ssid: String, wifi_password: String) {
    guard let url =  URL(string:"http://192.168.4.1")
    else{
        return
    }

    let body = "wifi_ssid=\(wifi_ssid)\nwifi_pass=\(wifi_password)\n#"
    let finalBody = body.data(using: .utf8)

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = finalBody

    URLSession.shared.dataTask(with: request){
        (data, response, error) in

        if let error = error {
            print("Error took place \(error)")
            return
        }

        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(dataString)")
        }

    }.resume()
}

@available(iOS 16.0, *)
struct SetupWifiView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            SetupWifiView()
        }
    }
}
