
import SwiftUI
// CalorieTrackerView.swift
struct CalorieTrackerView: View {
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var selectedTab: Tab = .calorie
    @State private var showFillView = false

    enum Tab {
        case calorie
        case recipe
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Calorie").font(.title).bold()
                Spacer()
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("5").bold()
                    }
                    .padding(8)
                    .background(LinearGradient(colors: [.green, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .clipShape(Capsule())

                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Text("Daily Calories Goal!").font(.headline).foregroundColor(.white)
                Text("kcal/day").foregroundColor(.white.opacity(0.8))

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

            HStack {
                Button(action: { showDatePicker.toggle() }) {
                    Text("Your Progress").font(.title3).bold()
                }
                Spacer()
                Button(action: { showDatePicker.toggle() }) {
                    HStack {
                        Text(formattedDate(selectedDate))
                        Image(systemName: "calendar")
                    }
                }
            }
            .padding(.horizontal)

            if selectedTab == .calorie {
                Text("Calorie Tracker Screen")
            } else if selectedTab == .recipe {
                Text("Recipe Screen Placeholder")
            }

            HStack(spacing: 16) {
                ProgressCard(title: "Calorie", unit: "kcal/day", percentage: 0)
                ProgressCard(title: "Protein", unit: "grams", percentage: 0)
                ProgressCard(title: "Carbs", unit: "grams", percentage: 0)
            }
            .padding(.horizontal)

            Spacer()

            ZStack {
                HStack {
                    Spacer()
                    BottomTabItem(title: "Calorie", image: "flame.fill", isActive: selectedTab == .calorie) {
                        selectedTab = .calorie
                    }
                    Spacer()
                    Spacer()
                    BottomTabItem(title: "Recipe", image: "book.fill", isActive: selectedTab == .recipe) {
                        selectedTab = .recipe
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.white.shadow(radius: 5))

                Button(action: { showFillView = true }) {
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
        .navigationDestination(isPresented: $showFillView) {
            CalorieFillView()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}
