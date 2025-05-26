import SwiftUI

struct ContentView: View {
    @State private var calorieValue: Double = 1119
    @State private var animatedProgress: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Meal Logged Successfully!!")
                .font(.headline)
                .padding()

            HStack(alignment: .top) {
                // Silhouette on left
                SilhouetteFillView(
                    fillProgress: animatedProgress,
                    calorieValue: calorieValue
                )
                .frame(width: 200, height: 400)

                // Nutrient view on right
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CALORIES")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("11240/1500")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(1) // ✅ Prevent line break
                            .minimumScaleFactor(0.5)
                    }

                    NutrientProgressView(label: "FAT", value: 120, max: 100)
                    NutrientProgressView(label: "FIBRE", value: 220, max: 100)
                    NutrientProgressView(label: "CARBS", value: 53, max: 100)
                    NutrientProgressView(label: "PROTEIN", value: 15, max: 100)
                }
                .padding(.leading, 20)
            }

            Spacer()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.indigo, Color.cyan]), startPoint: .top, endPoint: .bottom))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedProgress = CGFloat(calorieValue / 1500)
            }
        }
    }
}

struct NutrientProgressView: View {
    let label: String
    let value: CGFloat
    let max: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 10)
                    .foregroundColor(.white.opacity(0.2))

                GeometryReader { geo in
                    let clampedRatio = min(value / max, 1.0)
                    let barWidth = geo.size.width * clampedRatio

                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: barWidth, height: 10)
                            .foregroundColor(.cyan)

                        // Show value *inside* the filled area if value > max
                        if value > max {
                            Text("\(Int(value)) g")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(.trailing, 4)
                        }
                    }
                }

                // If value is within range, show label on right end
                if value <= max {
                    HStack {
                        Spacer()
                        Text("\(Int(value)) g")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 10)
        }
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
            let maxFillRatio: CGFloat = 0.85
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

