import SwiftUI

struct ContentView: View {
    @State private var fillProgress: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 40) {
            Text("Calorie Fill Level")
                .font(.title)

            SilhouetteFillView(fillProgress: fillProgress)
                .frame(width: 200, height: 400)

            VStack(spacing: 10) {
                Slider(value: $fillProgress, in: 0...1)
                    .padding()
                    .onChange(of: fillProgress) {
                        print("Slider value: \(fillProgress)")
                    }

                Text("Slider Value: \(Int(fillProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct SilhouetteFillView: View {
    var fillProgress: CGFloat // 0.0 to 1.0

    var body: some View {
        GeometryReader { geo in
            let maxFillRatio: CGFloat = 0.85 // fill only up to neck at max slider value
            let cappedFill = fillProgress * maxFillRatio

            ZStack {
                // Optional faint silhouette outline
                Image("human_silhouette")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .opacity(0.1)

                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .red]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: geo.size.height * max(cappedFill, 0.001))
                }
                .mask(
                    Image("human_silhouette")
                        .resizable()
                        .scaledToFit()
                )
            }
        }
    }
}


