// CalorieTrackerApp.swift
import SwiftUI

@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CalorieTrackerView()
                //FoodSearchView()
            }
        }
    }
}

// NutritionData.swift
struct NutritionData {
    var calories: Double
    var fat: Double
    var fiber: Double
    var carbs: Double
    var protein: Double

    var calorieFillProgress: CGFloat {
        min(CGFloat(calories / 1500), 1.0)
    }
}





// Food.swift
import Foundation

struct Food: Decodable, Identifiable {
    let food_name: String
    let nf_calories: Double?
    let nf_protein: Double?
    let nf_total_fat: Double?
    let nf_total_carbohydrate: Double?
    let serving_qty: Double?
    let serving_unit: String?
    let photo: FoodPhoto?

    var id: String { food_name }
}

struct FoodPhoto: Decodable {
    let thumb: String?
}




struct InstantSearchResponse: Decodable {
    let common: [Food]
}

struct FoodResponse: Decodable {
    let foods: [Food]
}


// FoodSearchViewModel.swift
import Foundation
import Combine

class FoodSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [Food] = []
    @Published var analyzedFoods: [Food] = []
    @Published var isLoading = false
    @Published var debounceEnabled = true

    private var debounceTimer: AnyCancellable?
    private var dataTask: URLSessionDataTask?

    init() {
        debounceTimer = $query
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if self.debounceEnabled {
                    self.handleSearch(for: text)
                }
            }
    }

    func handleSearch(for text: String) {
        if text.count < 3 {
            suggestions = []
            analyzedFoods = []
            return
        }

        if isLikelySimpleQuery(text) {
            fetchSuggestions(for: text)
        } else {
            fetchNutrition(for: text)
        }
    }

    private func isLikelySimpleQuery(_ text: String) -> Bool {
        let words = text.split(separator: " ")
        return words.count <= 2
    }

    private func fetchSuggestions(for query: String) {
        isLoading = true
        dataTask?.cancel()

        guard let url = URL(string: "https://trackapi.nutritionix.com/v2/search/instant?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("95c84d80", forHTTPHeaderField: "x-app-id")
        request.addValue("117f3129dfb287891e05355dde6cfaf8", forHTTPHeaderField: "x-app-key")

        dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async { self?.isLoading = false }

            guard let data = data, error == nil else { return }

            do {
                let result = try JSONDecoder().decode(InstantSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.suggestions = result.common
                    self?.analyzedFoods = []
                }
            } catch {
                print("Suggestion decode error: \(error)")
            }
        }

        dataTask?.resume()
    }

    func fetchNutrition(for text: String) {
        isLoading = true
        dataTask?.cancel()

        guard let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("95c84d80", forHTTPHeaderField: "x-app-id")
        request.addValue("117f3129dfb287891e05355dde6cfaf8", forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["query": text])

        dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async { self?.isLoading = false }

            guard let data = data, error == nil else { return }

            do {
                let result = try JSONDecoder().decode(FoodResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.analyzedFoods = result.foods
                    self?.suggestions = []
                }
            } catch {
                print("Nutrition decode error: \(error)")
            }
        }

        dataTask?.resume()
    }
    
    func selectSuggestion(_ foodName: String) {
        debounceEnabled = false
        query = foodName
        fetchNutrition(for: foodName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.debounceEnabled = true
        }
    }}


// FoodSearchView.swift
import SwiftUI

struct FoodSearchView: View {
    @StateObject private var viewModel = FoodSearchViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Search food...", text: $viewModel.query)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding()

                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                }

                if !viewModel.suggestions.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.suggestions.prefix(10)) { food in
                                Button {
                                    viewModel.selectSuggestion(food.food_name)
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        if let imageUrl = food.photo?.thumb, let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 48, height: 48)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 48, height: 48)
                                                    .cornerRadius(8)
                                            }
                                        }

                                        VStack(alignment: .leading) {
                                            Text(food.food_name.capitalized)
                                                .font(.body)
                                                .padding(.vertical, 4)

                                            if let qty = food.serving_qty, let unit = food.serving_unit {
                                                Text("Serving: \(qty.cleanString) \(unit)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider()
                            }

                            
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .padding([.horizontal, .bottom])
                    }
                    .frame(maxHeight: 300)
                }


                if !viewModel.analyzedFoods.isEmpty {
                    List(viewModel.analyzedFoods) { food in
                        VStack(alignment: .leading) {
                            Text(food.food_name).font(.headline)
                            if let qty = food.serving_qty, let unit = food.serving_unit {
                                Text("\(qty) \(unit)").font(.subheadline)
                            }
                            if let cal = food.nf_calories {
                                Text("Calories: \(Int(cal))").font(.subheadline)
                            }
                        }
                    }
                } else if !viewModel.query.isEmpty && !viewModel.isLoading && viewModel.suggestions.isEmpty {
                    Text("No results found.")
                        .foregroundColor(.secondary)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Search Food")
        }
    }
}

extension Double {
    var cleanString: String {
        return truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", self) : String(self)
    }
}
