import SwiftUI

struct SettingsView: View {
    @AppStorage("rippleColor") var rippleColor: Color = .yellow
    @AppStorage("rippleSize") var rippleSize: Double = 40.0

    var body: some View {
        Form {
            Section(header: Text("Ripple Settings")) {
                ColorPicker("Color", selection: $rippleColor)
                Slider(value: $rippleSize, in: 20...100) {
                    Text("Size (\(Int(rippleSize))px)")
                }
            }
        }
        .padding()
    }
}
