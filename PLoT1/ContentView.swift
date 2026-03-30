import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StageView()
                .tabItem { Label("Stage", systemImage: "rectangle.and.hand.point.up.left.filled") }

            InputListView()
                .tabItem { Label("Input List", systemImage: "list.bullet") }
        }
    }
}

#Preview { ContentView() }

