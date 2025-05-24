import SwiftUI

struct CalorieTrackerView: View {
    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    var body: some View {
        VStack(spacing: 16) {
            
            // Top Bar
            HStack {
                Text("Calorie")
                    .font(.title)
                    .bold()
                Spacer()
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("5")
                            .bold()
                    }
                    .padding(8)
                    .background(LinearGradient(colors: [.green, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    
                    Button(action: {
                        // Settings tapped
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal)

            // Green Card
            VStack(spacing: 12) {
                Text("Daily Calories Goal!")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("kcal/day")
                    .foregroundColor(.white.opacity(0.8))

                HStack(spacing: 20) {
                    MacroBox(title: "Carbs")
                    MacroBox(title: "Protein")
                    MacroBox(title: "Fat")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .cornerRadius(25)
            .padding(.horizontal)

            // Progress Section
            HStack {
                Button(action: {
                    showDatePicker.toggle()
                }) {
                    Text("Your Progress")
                        .font(.title3)
                        .bold()
                }

                Spacer()

                Button(action: {
                    showDatePicker.toggle()
                }) {
                    HStack {
                        Text(formattedDate(selectedDate))
                        Image(systemName: "calendar")
                    }
                }
            }
            .padding(.horizontal)

            // Placeholder Progress Cards
            HStack(spacing: 16) {
                ProgressCard(title: "Calorie", unit: "kcal/day", percentage: 0)
                ProgressCard(title: "Protein", unit: "grams", percentage: 0)
                ProgressCard(title: "Carbs", unit: "grams", percentage: 0)
            }
            .padding(.horizontal)

            Spacer()

            // Floating Button
            ZStack {
                HStack {
                    Spacer()
                    BottomTabItem(title: "Calorie", image: "flame.fill", isActive: true)
                    Spacer()
                    Spacer()
                    BottomTabItem(title: "Recipe", image: "bell", isActive: false)
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.white.shadow(radius: 5))
                
                Button(action: {
                    // Open add entry sheet
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .offset(y: -20)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Components

struct MacroBox: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .bold()
                .foregroundColor(.black)
            Text("grams")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
    }
}

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

            Text(title)
                .bold()
            Text("0 \(unit)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 2)
    }
}

struct BottomTabItem: View {
    let title: String
    let image: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: image)
                .font(.title2)
                .foregroundColor(isActive ? .green : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? .green : .gray)
        }
    }
}

