//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 07.04.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI
import LocalAuthentication
import SwiftKeychainWrapper

struct SettingsView: View {
    
    @ObservedObject var controller: SettingsController
    
    var body: some View {
        Group {
            if controller.isLoadingInformation {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            }
            else {
                List {
                    Section(header: Text("Security")) {
                        Toggle(isOn: $controller.biometicAuthEnabled) {
                            SettingsSideIcon(image: "faceid", text: "Biometrics")
                        }.padding(4).disabled(!controller.biometricAuthAllowed)
                    }
                    
                    Section(header: Text("Developer"), footer: Text("Enabling this option will prevent any network activity and load sample data stored within the app (Good for testing)")) {
                        Toggle(isOn: $controller.developerModeEnabled) {
                            SettingsSideIcon(image: "staroflife.circle", text: "Developer mode")
                        }.padding(4).alert(isPresented: $controller.developerModeSuccessNotice) {
                            Alert(title: Text("Done!"), message: Text("You'll have to restart the app for the change to take effect."), dismissButton: .cancel())
                        }
                    }
                    
                    Section(header: Text("Legal")) {
                        Button {
                            let url = URL(string: "https://example.com")!
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            SettingsSideIcon(image: "lock", text: "Privacy policy")
                        }
                        NavigationLink(destination: LegalNoticeView()) {
                            SettingsSideIcon(image: "briefcase", text: "Legal notice")
                        }
                    }
                    
                    Section(header: Text("Other")) {
                        NavigationLink(destination: Text("used libraries")) {
                            SettingsSideIcon(image: "tray", text: "Used libraries")
                        }
                        Button {
                            let url = URL(string: "https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios")!
                            if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
                        } label: {
                            SettingsSideIcon(image: "chevron.left.slash.chevron.right", text: "Code")
                        }
                        
                        Button {
                            let url = URL(string: "mailto:adrian@abmgrt.dev")!
                            if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
                        } label: {
                            SettingsSideIcon(image: "envelope", text: "Contact")
                        }

                    }
                    
                    Section(header: Text("About")) {
                        Text("\(controller.versionText)").foregroundColor(.secondary).font(.footnote)
                        Text("© 2021, Adrian Baumgart").foregroundColor(.secondary).font(.footnote)
                    }
                }.listStyle(InsetGroupedListStyle())
            }
        }.navigationBarTitle(Text("Settings")).onAppear {
            controller.loadData()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(controller: .init())
    }
}

class SettingsController: ObservableObject {
    @Published var biometicAuthEnabled: Bool = false {
        didSet {
            if !isLoadingInformation {
                if biometicAuthEnabled == false {
                    KeychainWrapper.standard.set(biometicAuthEnabled, forKey: "biometricAuthEnabled")
                }
                else {
                    let authContext = LAContext()
                    var authError: NSError?
                    
                    if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                        KeychainWrapper.standard.set(biometicAuthEnabled, forKey: "biometricAuthEnabled")
                    }
                    else {
                        DispatchQueue.main.async {
                            self.isLoadingInformation = true
                            self.biometicAuthEnabled = false
                            self.isLoadingInformation = false
                        }
                        KeychainWrapper.standard.set(false, forKey: "biometricAuthEnabled")
                        EZAlertController.alert("Device error", message: "Biometric authentication is not enabled on your device. Please verify that it's enabled in the device settings")
                    }
                }
            }
        }
    }
    
    @Published var biometricAuthAllowed: Bool = false
    
    @Published var developerModeEnabled: Bool = false {
        didSet {
            if !isLoadingInformation {
                UserDefaults.standard.set(developerModeEnabled, forKey: "devmodeEnabled")
                developerModeSuccessNotice = true
            }
        }
    }
    
    @Published var developerModeSuccessNotice: Bool = false
    
    
    @Published var versionText: String = ""
    
    @Published var isLoadingInformation = false
    
    func loadData() {
        isLoadingInformation = true
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        versionText = "Version \(version) Build \(build)"
        
        let authContext = LAContext()
        var authError: NSError?
        
        biometicAuthEnabled = KeychainWrapper.standard.bool(forKey: "biometricAuthEnabled") ?? false
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            biometricAuthAllowed = true
        }
        else {
            biometricAuthAllowed = false
        }
        
        developerModeEnabled = UserDefaults.standard.bool(forKey: "devmodeEnabled")
        
        isLoadingInformation = false
    }
}

struct SettingsSideIcon: View {
     var image: String
     var text: String
     var colorOverride: Color? = nil
     var isButton: Bool = false
     
     var body: some View {
         HStack {
             Image(systemName: image).resizable().aspectRatio(contentMode: .fit).frame(width: 22, height: 22, alignment: .leading)
             Text(text).font(.callout)
         }.foregroundColor(isButton ? colorOverride ?? .accentColor : .accentColor)
     }
 }
