import Foundation

struct MealAnalysis {
    let name: String
    let calories: Int
    let category: MealCategory
}

enum GeminiError: LocalizedError {
    case networkError(String)
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "Мрежова грешка: \(msg)"
        case .invalidResponse: return "Невалиден отговор от AI"
        case .apiError(let msg): return "API грешка: \(msg)"
        }
    }
}

enum GeminiService {

    private static let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    private static let prompt = """
        Анализирай тази снимка на храна. Отговори САМО с JSON в следния формат, без допълнителен текст:
        {"name": "име на ястието на български", "calories": число, "category": "breakfast"|"lunch"|"dinner"|"snack"}

        Правила:
        - name: кратко описание на български (2-4 думи)
        - calories: приблизителна оценка за една порция в kcal
        - category: определи по типа храна (зърнена закуска→breakfast, сандвич по обяд→lunch, и т.н.)
        - Ако не можеш да разпознаеш храната, върни: {"name": "Неразпознато", "calories": 0, "category": "snack"}
        """

    static func analyzeMeal(imageData: Data) async throws -> MealAnalysis {
        var lastError: Error = GeminiError.invalidResponse

        for attempt in 0..<3 {
            if attempt > 0 {
                try await Task.sleep(nanoseconds: UInt64(attempt) * 2_000_000_000)
            }

            do {
                return try await performRequest(imageData: imageData)
            } catch let error as GeminiError {
                lastError = error
                if case .apiError(let msg) = error, msg.contains("503") || msg.contains("UNAVAILABLE") {
                    continue
                }
                throw error
            } catch {
                throw error
            }
        }

        throw lastError
    }

    private static func performRequest(imageData: Data) async throws -> MealAnalysis {
        guard var urlComponents = URLComponents(string: endpoint) else {
            throw GeminiError.invalidResponse
        }
        urlComponents.queryItems = [URLQueryItem(name: "key", value: APIKeys.gemini)]

        guard let url = urlComponents.url else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let base64Image = imageData.base64EncodedString()

        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["text": prompt],
                    ["inlineData": [
                        "mimeType": "image/jpeg",
                        "data": base64Image
                    ]]
                ]
            ]]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GeminiError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown"
            throw GeminiError.apiError("HTTP \(httpResponse.statusCode): \(errorBody)")
        }

        return try parseResponse(data)
    }

    private static func parseResponse(_ data: Data) throws -> MealAnalysis {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let textPart = parts.first?["text"] as? String else {
            throw GeminiError.invalidResponse
        }

        let cleaned = textPart
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleaned.data(using: .utf8),
              let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let name = parsed["name"] as? String else {
            throw GeminiError.invalidResponse
        }

        let calories = parsed["calories"] as? Int ?? 0
        let categoryRaw = parsed["category"] as? String ?? "snack"
        let category = MealCategory(rawValue: categoryRaw) ?? .snack

        return MealAnalysis(name: name, calories: calories, category: category)
    }
}
