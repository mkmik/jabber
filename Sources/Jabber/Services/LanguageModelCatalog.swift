import Foundation

enum LanguageModelCatalog {
    struct Route: Identifiable {
        let modelId: String
        let isRecommended: Bool

        var id: String {
            modelId
        }
    }

    static let popularLanguageCodes: [String] = [
        "en", "es", "fr", "de", "pt", "it", "ja", "ko", "zh", "hi", "ar"
    ]

    /// Drops routes to models this Mac can't run (Apple Speech before macOS
    /// 26) and promotes the next one so the language keeps a recommendation.
    static func routes(for languageCode: String) -> [Route] {
        var routes = allRoutes(for: languageCode).filter { AppMode.modelDefinition(for: $0.modelId) != nil }
        if !routes.contains(where: \.isRecommended), let first = routes.first {
            routes[0] = .init(modelId: first.modelId, isRecommended: true)
        }
        return routes
    }

    private static func allRoutes(for languageCode: String) -> [Route] {
        if languageCode == "auto" {
            // Apple Speech leads because it covers every language Jabber
            // offers; Parakeet v3 needs the language named to pick a script.
            return [
                .init(modelId: AppMode.appleSpeechModelId, isRecommended: true),
                .init(modelId: AppMode.parakeetMultilingualModelId, isRecommended: false),
                .init(modelId: AppMode.parakeetModelId, isRecommended: false),
                .init(modelId: AppMode.nemotronModelId, isRecommended: false),
            ]
        }

        if languageCode == "en" {
            // v2 is English-only and more accurate on it than multilingual v3.
            return [
                .init(modelId: AppMode.parakeetModelId, isRecommended: true),
                .init(modelId: AppMode.parakeetMultilingualModelId, isRecommended: false),
                .init(modelId: AppMode.nemotronModelId, isRecommended: false),
                .init(modelId: AppMode.appleSpeechModelId, isRecommended: false)
            ]
        }

        if AppMode.parakeetMultilingualLanguageCodes.contains(languageCode) {
            return [
                .init(modelId: AppMode.parakeetMultilingualModelId, isRecommended: true),
                .init(modelId: AppMode.appleSpeechModelId, isRecommended: false)
            ]
        }

        if languageCode == "ja" {
            return [
                .init(modelId: AppMode.parakeetJapaneseModelId, isRecommended: true),
                .init(modelId: AppMode.appleSpeechModelId, isRecommended: false)
            ]
        }

        return [
            .init(modelId: AppMode.appleSpeechModelId, isRecommended: true)
        ]
    }

    static func recommendedModelId(for languageCode: String) -> String {
        routes(for: languageCode).first(where: { $0.isRecommended })?.modelId
            ?? AppMode.appleSpeechModelId
    }

    static func compatibleModelIds(for languageCode: String) -> [String] {
        routes(for: languageCode).map(\.modelId)
    }

    static func supportsLanguage(_ languageCode: String, modelId: String) -> Bool {
        guard let def = AppMode.modelDefinition(for: modelId) else { return false }
        guard let supported = def.supportedLanguageCodes else { return true }
        if languageCode == "auto" { return true }
        return supported.contains(languageCode)
    }

    static func popularLanguages() -> [(name: String, code: String)] {
        popularLanguageCodes.compactMap { code in
            Constants.sortedLanguages.first { $0.code == code }
        }
    }

    static func allLanguages() -> [(name: String, code: String)] {
        Constants.sortedLanguages
    }
}
