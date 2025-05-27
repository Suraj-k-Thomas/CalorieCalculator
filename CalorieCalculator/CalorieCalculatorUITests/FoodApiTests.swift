//
//  FoodApiTests.swift
//  CalorieCalculatorTests
//
//  Created by Suraj  Thomas on 27/05/25.
//

import XCTest


enum FoodLoaderError: Error, Equatable {
    case encodingFailed
    case network(Error)
    case decoding(Error)
    case partialFailure

    static func == (lhs: FoodLoaderError, rhs: FoodLoaderError) -> Bool {
        switch (lhs, rhs) {
        case (.encodingFailed, .encodingFailed),
             (.partialFailure, .partialFailure):
            return true
        case (.network, .network),
             (.decoding, .decoding):
            return true // don't compare internal errors
        default:
            return false
        }
    }
}

enum FoodLoadResult {
    case success(FoodTotals)
    case failure(FoodLoaderError)
}



struct Food: Decodable, Equatable,Encodable {
    let food_name: String
    let nf_calories: Double
    let nf_protein: Double?
    let nf_total_carbohydrate: Double?
    let nf_total_fat: Double?
    let serving_qty: Double
    let serving_unit: String
}

struct FoodResponse: Decodable,Encodable {
    let foods: [Food]
}

struct APIConfig {
    let url: URL
    let appID: String
    let appKey: String
}

protocol HTTPClient {
    func post(from url: URL, headers: [String: String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void)
}
class FoodLoader {
    private let client: HTTPClient
    private let config: APIConfig

    init(config: APIConfig, client: HTTPClient) {
        self.config = config
        self.client = client
    }

    func load(query: String, completion: @escaping (Result<[Food], FoodLoaderError>) -> Void) {
        let headers = [
            "x-app-id": config.appID,
            "x-app-key": config.appKey,
            "Content-Type": "application/json"
        ]

      //  let body = try? JSONEncoder().encode(["query": query])
        guard let body = try? JSONEncoder().encode(["query": query]) else {
            completion(.failure(.encodingFailed))
               return
           }

        client.post(from: config.url, headers: headers, body: body) { result in
            switch result {
            case let .success(data):
                do {
                    let decoded = try JSONDecoder().decode(FoodResponse.self, from: data)
                    completion(.success(decoded.foods))
                } catch {
                    completion(.failure(.decoding(error)))
                }
            case let .failure(error):
                completion(.failure(.network(error)))
            }
        }
    }

    // 👇 Optional Aggregator
    func loadAndAggregate(queries: [String], completion: @escaping (Result<FoodTotals, FoodLoaderError>) -> Void) {
        var total = FoodTotals.empty
        var completed = 0
        var errors: [Error] = []

        for query in queries {
            load(query: query) { result in
                switch result {
                case let .success(foods):
                    for food in foods {
                        total.add(food)
                    }
                case let .failure(error):
                    errors.append(error)
                }

                completed += 1
                if completed == queries.count {
                    if errors.isEmpty {
                        completion(.success(total))
                    } else {
                        if let first = errors.first as? FoodLoaderError {
                            completion(.failure(first))
                        } else {
                            completion(.failure(.partialFailure))
                        }
                    }
                }
            }
        }
    }
}

struct FoodTotals {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0

    mutating func add(_ food: Food) {
        calories += food.nf_calories
        protein += food.nf_protein ?? 0
        carbs += food.nf_total_carbohydrate ?? 0
        fat += food.nf_total_fat ?? 0
    }

    static var empty: FoodTotals {
        .init()
    }
}


final class FoodLoaderTests: XCTestCase {

    func test_load_sendsCorrectPOSTRequest() {
        let (sut, client) = makeSUT(appID: "abc", appKey: "xyz")
        sut.load(query: "1 egg") { _ in }

        let headers = client.requestedHeaders.first!
        let body = client.requestedBodies.first!

        let parsed = try! JSONSerialization.jsonObject(with: body!) as? [String: String]

        XCTAssertEqual(headers["x-app-id"], "abc")
        XCTAssertEqual(headers["x-app-key"], "xyz")
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(parsed?["query"], "1 egg")
    }

    func test_load_deliversDecodedFoodOnSuccess() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for load")

        let expected = Food(food_name: "Egg", nf_calories: 72, nf_protein: 6.3, nf_total_carbohydrate: 0.4, nf_total_fat: 4.8, serving_qty: 1, serving_unit: "large")
        let response = FoodResponse(foods: [expected])
        let data = try! JSONEncoder().encode(response)

        sut.load(query: "1 egg") { result in
            switch result {
            case .success(let foods):
                XCTAssertEqual(foods, [expected])
            default:
                XCTFail("Expected success, got \(result)")
            }
            exp.fulfill()
        }

        client.complete(withStatusCode: 200, data: data)
        wait(for: [exp], timeout: 1.0)
    }

    func test_load_failsOnClientError() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for load")

        sut.load(query: "1 egg") { result in
            switch result {
            case .failure(let error):
                if case .network = error {
                    // Success: we got a network error
                } else {
                    XCTFail("Expected network error, got \(error)")
                }
            default:
                XCTFail("Expected failure, got \(result)")
            }
            exp.fulfill()
        }

        client.complete(with: NSError(domain: "Test", code: 1))
        wait(for: [exp], timeout: 1.0)
    }


    func test_loadAndAggregate_sumsNutritionCorrectly() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for load")

        let egg = Food(food_name: "Egg", nf_calories: 70, nf_protein: 6, nf_total_carbohydrate: 0.5, nf_total_fat: 5, serving_qty: 1, serving_unit: "large")
        let milk = Food(food_name: "Milk", nf_calories: 100, nf_protein: 8, nf_total_carbohydrate: 12, nf_total_fat: 2.5, serving_qty: 1, serving_unit: "cup")

        var resultTotal: FoodTotals?
        let data1 = try! JSONEncoder().encode(FoodResponse(foods: [egg]))
        let data2 = try! JSONEncoder().encode(FoodResponse(foods: [milk]))

        sut.loadAndAggregate(queries: ["1 egg", "1 cup milk"]) { result in
            if case let .success(totals) = result {
                resultTotal = totals
            }
            exp.fulfill()
        }

        client.complete(withStatusCode: 200, data: data1, at: 0)
        client.complete(withStatusCode: 200, data: data2, at: 1)

        wait(for: [exp], timeout: 3.0)

        XCTAssertEqual(resultTotal?.calories, 170)
        XCTAssertEqual(resultTotal?.protein, 14)
        XCTAssertEqual(resultTotal?.carbs, 12.5)
        XCTAssertEqual(resultTotal?.fat, 7.5)
    }

    func test_loadAndAggregate_failsIfAnyFails() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wait for load")
       // exp.expectedFulfillmentCount = 2

        var receivedError: Error?

        sut.loadAndAggregate(queries: ["egg", "milk"]) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
            exp.fulfill()
        }

        client.complete(with: NSError(domain: "fail", code: 0), at: 0)
        client.complete(withStatusCode: 200, data: Data(), at: 1)

        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }
}

func makeSUT(
    url: URL = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients")!,
    appID: String = "test-id",
    appKey: String = "test-key"
) -> (sut: FoodLoader, client: HTTPClientSpy) {
    let config = APIConfig(url: url, appID: appID, appKey: appKey)
    let client = HTTPClientSpy()
    let sut = FoodLoader(config: config, client: client)
    return (sut, client)
}

class HTTPClientSpy: HTTPClient {
    var messages: [(url: URL, headers: [String: String], body: Data?, completion: (Result<Data, Error>) -> Void)] = []

    var requestedURLs: [URL] { messages.map { $0.url } }
    var requestedHeaders: [[String: String]] { messages.map { $0.headers } }
    var requestedBodies: [Data?] { messages.map { $0.body } }

    func post(from url: URL, headers: [String: String], body: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        messages.append((url, headers, body, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
