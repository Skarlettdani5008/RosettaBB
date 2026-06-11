import SwiftUI

@main
struct RosettaBBApp: App {
    var body: some Scene {
        WindowGroup("RosettaBB") {
            ContentView()
                .frame(minWidth: 640, minHeight: 480)
        }
        .windowResizability(.contentMinSize)
    }
}
