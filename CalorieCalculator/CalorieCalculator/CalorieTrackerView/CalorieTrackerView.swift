import SwiftUI

struct CalorieTrackerView: View {
    @ObservedObject var viewModel: CalorieTrackerViewModel

    init(viewModel: CalorieTrackerViewModel) {
        self.viewModel = viewModel
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
                Button(action: { viewModel.showDatePicker.toggle() }) {
                    Text("Your Progress").font(.title3).bold()
                }
                Spacer()
                Button(action: { viewModel.showDatePicker.toggle() }) {
                    HStack {
                        Text(viewModel.formattedDate(viewModel.selectedDate))
                        Image(systemName: "calendar")
                    }
                }
            }
            .padding(.horizontal)

            if viewModel.selectedTab == .calorie {
                List(viewModel.trackedFoods) { food in
                    HStack {
                        Text(food.food_name.capitalized).font(.headline)
                        Spacer()
                        if let calories = food.nf_calories {
                            Text("\(Int(calories)) kcal").font(.subheadline)
                        }
                    }
                }
            } else if viewModel.selectedTab == .recipe {
                Text("Recipe Screen Placeholder")
            }

            HStack(spacing: 16) {
                ProgressCard(title: "Calorie", unit: "kcal/day", percentage: viewModel.getProgressPercentage(for: "calorie"))
                ProgressCard(title: "Protein", unit: "grams", percentage: viewModel.getProgressPercentage(for: "protein"))
                ProgressCard(title: "Carbs", unit: "grams", percentage: viewModel.getProgressPercentage(for: "carbs"))
            }
            .padding(.horizontal)

            Spacer()

            ZStack {
                HStack {
                    Spacer()
                    BottomTabItem(title: "Calorie", image: "flame.fill", isActive: viewModel.selectedTab == .calorie) {
                        viewModel.toggleTab(.calorie)
                    }
                    Spacer()
                    Spacer()
                    BottomTabItem(title: "Recipe", image: "book.fill", isActive: viewModel.selectedTab == .recipe) {
                        viewModel.toggleTab(.recipe)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.white.shadow(radius: 5))

                Button(action: {
                    viewModel.showActionSheet.toggle()
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
                .actionSheet(isPresented: $viewModel.showActionSheet) {
                    ActionSheet(title: Text("What would you like to log?"), buttons: [
                        .default(Text("🍱 Food")) { viewModel.showFoodSearch = true },
                        .default(Text("🩸 Sugar")) { viewModel.logSugar() },
                        .default(Text("🏋️‍♂️ Exercise")) { viewModel.logExercise() },
                        .default(Text("⚖️ Weight")) { viewModel.logWeight() },
                        .cancel()
                    ])
                }
            }
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
        }
        .sheet(isPresented: $viewModel.showFillView) {
            CalorieFillView(nutritionData: viewModel.nutritionData)
        }
        .navigationDestination(isPresented: $viewModel.showFoodSearch) {
            FoodSearchView(viewModel: FoodSearchViewModel(calorieTrackerViewModel: viewModel))
        }
    }
}
