//
// Aurora
// File created by Lea Baumgart on 07.04.21.
//
// Licensed under the MIT License
// Copyright © 2020 Lea Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import ConfettiSwiftUI
import LocalAuthentication
import SwiftKeychainWrapper
import SwiftUI

struct SettingsView: View {
    @ObservedObject var controller: SettingsController
    @State var versionEasterEggCountdown = -5
    var showCake: Bool = (0 ... 10).randomElement()! == 0

    var body: some View {
        Group {
            if controller.isLoadingInformation {
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            } else {
                List {
                    Section(header: Text("Security")) {
                        Toggle(isOn: $controller.biometicAuthEnabled) {
                            SettingsSideIcon(image: Image(systemName: "faceid"), text: "Biometrics")
                        }.padding(4).disabled(!controller.biometricAuthAllowed)
                    }

                    Section(header: Text("Developer"), footer: Text("Enabling this option will prevent any network activity and load sample data stored within the app (Good for testing)")) {
                        Toggle(isOn: $controller.developerModeEnabled) {
                            SettingsSideIcon(image: Image(systemName: "staroflife.circle"), text: "Developer mode")
                        }.padding(4).alert(isPresented: $controller.developerModeSuccessNotice) {
                            Alert(title: Text("Done!"), message: Text("You'll have to restart the app for the change to take effect."), dismissButton: .cancel())
                        }
                    }

                    Section(header: Text("Legal")) {
                        
                        SettingsExternalLinkButton(url: URL(string: "https://go.abmgrt.dev/IsaHi8")!) {
                            SettingsSideIcon(image: Image(systemName: "lock"), text: "Privacy Policy")
                        }
                        
                        NavigationLink(destination: LegalNoticeView()) {
                            SettingsSideIcon(image: Image(systemName: "briefcase"), text: "Legal Notice")
                        }
                    }

                    Section(header: Text("Other")) {
                        NavigationLink(destination: UsedLibrariesView()) {
                            SettingsSideIcon(image: Image(systemName: "tray"), text: "Used Libraries")
                        }
                        
                        SettingsExternalLinkButton(url: URL(string: "https://git.abmgrt.dev/exc_bad_access/aurora")!) {
                            SettingsSideIcon(image: Image(systemName: "chevron.left.slash.chevron.right"), text: "Code")
                        }
                        
                        SettingsExternalLinkButton(url: URL(string: "mailto:lea@abmgrt.dev")!) {
                            SettingsSideIcon(image: Image(systemName: "envelope"), text: "Contact")
                        }

                        SettingsExternalLinkButton(url: URL(string: "https://twitter.com/leabmgrt")!) {
                            SettingsSideIcon(image: Image("twitter"), text: "Twitter")
                        }
                    }

                    Section(header: Text("About"), footer: showCake ? Text("Thank you for using the app! (✿◠‿◠)\n\n") + Text("The cake is a lie").foregroundColor(.secondary).italic().font(.footnote) : Text("Thank you for using the app! (✿◠‿◠)")) {
                        ZStack {
                            Text("\(controller.versionText)").foregroundColor(.secondary).font(.footnote).onTapGesture {
                                versionEasterEggCountdown += 1
                            }
                            if versionEasterEggCountdown > 0 {
                                ConfettiCannon(counter: $versionEasterEggCountdown, radius: 120, repetitions: 5, repetitionInterval: 0.3)
                            }
                        }
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

struct SettingsExternalLinkButton<Content: View>: View {
    var url: URL!
    
    let content: Content
    
    init(url: URL, @ViewBuilder content: @escaping () -> Content) {
        self.url = url
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
        }, label: {
            content
        })
    }
}

class SettingsController: ObservableObject {
    @Published var biometicAuthEnabled: Bool = false {
        didSet {
            if !isLoadingInformation {
                if biometicAuthEnabled == false {
                    KeychainWrapper.standard.set(biometicAuthEnabled, forKey: "biometricAuthEnabled")
                } else {
                    let authContext = LAContext()
                    var authError: NSError?

                    if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                        KeychainWrapper.standard.set(biometicAuthEnabled, forKey: "biometricAuthEnabled")
                    } else {
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
        } else {
            biometricAuthAllowed = false
        }

        developerModeEnabled = UserDefaults.standard.bool(forKey: "devmodeEnabled")

        isLoadingInformation = false
    }
}

struct SettingsSideIcon: View {
    var image: Image
    var text: String
    var colorOverride: Color? = nil
    var isButton: Bool = false

    var body: some View {
        HStack {
            image.resizable().aspectRatio(contentMode: .fit).frame(width: 22, height: 22, alignment: .leading)
            Text(text).font(.callout)
        }.foregroundColor(isButton ? colorOverride ?? .accentColor : .accentColor)
    }
}
