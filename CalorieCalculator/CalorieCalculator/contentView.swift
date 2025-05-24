import SwiftUI
import SwiftUI

struct ContentView: View {
    @State private var fillProgress: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 40) {
            Text("Calorie Fill Level")
                .font(.title)

            SilhouetteFillView(fillProgress: fillProgress)
                .frame(width: 200, height: 400)

            Slider(value: $fillProgress, in: 0...1)
                .padding()
        }
        .padding()
    }
}



#Preview {
    ContentView()
}

import SwiftUI

struct SilhouetteFillView: View {
    var fillProgress: CGFloat // Value from 0.0 to 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background silhouette outline for context (optional)
                Image("human_silhouette")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .opacity(0.1)

                // Red fill based on progress
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .red]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: geo.size.height * fillProgress)
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height - (geo.size.height * fillProgress / 2)
                    )
                    .mask(
                        Image("human_silhouette")
                            .resizable()
                            .scaledToFit()
                    )
            }
        }
    }
}
