
import SwiftUI


// CalorieFillView.swift
struct CalorieFillView: View {
    @State private var nutrition = NutritionData(
        calories: 1120,
        fat: 120,
        fiber: 220,
        carbs: 53,
        protein: 15
    )
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let width = geo.size.width

            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .indigo, .cyan]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: height * 0.06) // Fine-tuned top spacing

                    Text("Meal Logged Successfully!!")
                        .font(.headline)

                    Spacer().frame(height: height * 0.025) // Precise control

                    HStack(alignment: .top, spacing: width * 0.04) {
                        SilhouetteFillView(
                            fillProgress: nutrition.calorieFillProgress,
                            calorieValue: nutrition.calories
                        )
                        .frame(width: width * 0.52, height: height * 0.85)

                        VStack(alignment: .leading, spacing: height * 0.03) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("CALORIES")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))

                                Text("\(Int(nutrition.calories))/1500")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }

                            NutrientProgressView(label: "FAT", value: CGFloat(nutrition.fat), max: 100)
                            NutrientProgressView(label: "FIBRE", value: CGFloat(nutrition.fiber), max: 100)
                            NutrientProgressView(label: "CARBS", value: CGFloat(nutrition.carbs), max: 100)
                            NutrientProgressView(label: "PROTEIN", value: CGFloat(nutrition.protein), max: 100)
                        }
                        .frame(height: height * 0.85)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
    }




}




// NutrientProgressView.swift
struct NutrientProgressView: View {
    let label: String
    let value: CGFloat
    let max: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased()).font(.caption).foregroundColor(.white.opacity(0.7))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10).frame(height: 10).foregroundColor(.white.opacity(0.2))

                GeometryReader { geo in
                    let clampedRatio = min(value / max, 1.0)
                    let barWidth = geo.size.width * clampedRatio

                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 10).frame(width: barWidth, height: 10).foregroundColor(.cyan)
                        if value > max {
                            Text("\(Int(value)) g")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(.trailing, 4)
                        }
                    }
                }

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


// SilhouetteFillView.swift
struct SilhouetteFillView: View {
    var fillProgress: CGFloat
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
                        .fill(LinearGradient(gradient: Gradient(colors: [fillColor, fillColor]), startPoint: .bottom, endPoint: .top))
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


// MacroBox.swift
struct MacroBox: View {
    let title: String

    var body: some View {
        VStack {
            Text(title).bold().foregroundColor(.black)
            Text("grams").font(.caption).foregroundColor(.gray)
        }
        .padding()
        .frame(width: 80, height: 60)
        .background(Color.white.opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 2)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
//        .truncationMode(.tail)
    }
}

// ProgressCard.swift
struct ProgressCard: View {
    let title: String
    let unit: String
    let percentage: Double

    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: CGFloat(percentage))
                .stroke(Color.green, lineWidth: 6)
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .overlay(Text("\(Int(percentage * 100))%").font(.caption))

            Text(title).bold()
            Text("0 \(unit)").font(.footnote).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 2)
    }
}

// BottomTabItem.swift
struct BottomTabItem: View {
    let title: String
    let image: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .font(.title2)
                    .foregroundColor(isActive ? .green : .gray)

                Text(title)
                    .font(.caption)
                    .foregroundColor(isActive ? .green : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
