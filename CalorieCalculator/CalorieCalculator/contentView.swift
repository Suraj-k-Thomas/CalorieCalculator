import SwiftUI

struct ContentView: View {
    @State private var calorieValue: Double = 750 // Start mid-point

    var body: some View {
        VStack(spacing: 40) {
            Text("Calorie Fill Level")
                .font(.title)

            // Map calories (0–1500) to fillProgress (0–1)
            SilhouetteFillView(
                fillProgress: CGFloat(calorieValue / 1500),
                calorieValue: calorieValue
            )


            VStack(spacing: 10) {
                Slider(value: $calorieValue, in: 0...1500, step: 1)
                    .padding()
                    .onChange(of: calorieValue) {
                        print("Calories: \(Int(calorieValue))")
                    }

                Text("Calories: \(Int(calorieValue)) kcal")
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
    var fillProgress: CGFloat // Normalized 0.0 to 1.0
    var calorieValue: Double

    var body: some View {
        GeometryReader { geo in
            let maxFillRatio: CGFloat = 0.95 // max fill reaches neck only
            let cappedFill = fillProgress * maxFillRatio
            let fillColor: Color = calorieValue < 1200 ? .green : .red


            ZStack {
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
                                gradient: Gradient(colors: [fillColor, fillColor]),
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

