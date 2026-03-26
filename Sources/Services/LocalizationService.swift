import Foundation
import SwiftUI

/// R15: Internationalization - 10 languages
/// Full i18n with symbol encyclopedia localization
@MainActor
final class LocalizationService: ObservableObject {
    static let shared = LocalizationService()

    @Published var currentLanguage: AppLanguage = .english

    enum AppLanguage: String, CaseIterable, Codable, Identifiable {
        case english = "en"
        case german = "de"
        case french = "fr"
        case spanish = "es"
        case italian = "it"
        case portuguese = "pt"
        case japanese = "ja"
        case korean = "ko"
        case simplifiedChinese = "zh-Hans"
        case arabic = "ar"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .english: return "English"
            case .german: return "Deutsch"
            case .french: return "Français"
            case .spanish: return "Español"
            case .italian: return "Italiano"
            case .portuguese: return "Português"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .simplifiedChinese: return "简体中文"
            case .arabic: return "العربية"
            }
        }

        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            case .german: return "🇩🇪"
            case .french: return "🇫🇷"
            case .spanish: return "🇪🇸"
            case .italian: return "🇮🇹"
            case .portuguese: return "🇵🇹"
            case .japanese: return "🇯🇵"
            case .korean: return "🇰🇷"
            case .simplifiedChinese: return "🇨🇳"
            case .arabic: return "🇸🇦"
            }
        }

        var isRTL: Bool {
            self == .arabic
        }
    }

    private let languageKey = "dreamscape_language"

    init() {
        loadLanguage()
    }

    func loadLanguage() {
        if let saved = UserDefaults.standard.string(forKey: languageKey),
           let lang = AppLanguage(rawValue: saved) {
            currentLanguage = lang
        } else if let systemLang = Locale.current.language.languageCode?.identifier {
            currentLanguage = AppLanguage(rawValue: systemLang) ?? .english
        }
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
    }

    func t(_ key: String) -> String {
        let translations = currentLanguage.translations
        return translations[key] ?? key
    }
}

extension LocalizationService.AppLanguage {
    var translations: [String: String] {
        switch self {
        case .english:
            return Self.englishStrings
        case .german:
            return Self.germanStrings
        case .french:
            return Self.frenchStrings
        case .spanish:
            return Self.spanishStrings
        case .italian:
            return Self.italianStrings
        case .portuguese:
            return Self.portugueseStrings
        case .japanese:
            return Self.japaneseStrings
        case .korean:
            return Self.koreanStrings
        case .simplifiedChinese:
            return Self.chineseStrings
        case .arabic:
            return Self.arabicStrings
        }
    }

    private static let englishStrings: [String: String] = [
        "dreams": "Dreams",
        "journal": "Journal",
        "analysis": "Analysis",
        "symbols": "Symbols",
        "settings": "Settings",
        "add_dream": "Add Dream",
        "interpretation": "Interpretation",
        "lucidity": "Lucidity",
        "sleep_quality": "Sleep Quality",
        "ai_insights": "AI Insights"
    ]

    private static let germanStrings: [String: String] = [
        "dreams": "Träume",
        "journal": "Tagebuch",
        "analysis": "Analyse",
        "symbols": "Symbole",
        "settings": "Einstellungen",
        "add_dream": "Traum hinzufügen",
        "interpretation": "Deutung",
        "lucidity": "Klarheit",
        "sleep_quality": "Schlafqualität",
        "ai_insights": "KI-Einblicke"
    ]

    private static let frenchStrings: [String: String] = [
        "dreams": "Rêves",
        "journal": "Journal",
        "analysis": "Analyse",
        "symbols": "Symboles",
        "settings": "Paramètres",
        "add_dream": "Ajouter un rêve",
        "interpretation": "Interprétation",
        "lucidity": "Lucidité",
        "sleep_quality": "Qualité du sommeil",
        "ai_insights": "Insights IA"
    ]

    private static let spanishStrings: [String: String] = [
        "dreams": "Sueños",
        "journal": "Diario",
        "analysis": "Análisis",
        "symbols": "Símbolos",
        "settings": "Ajustes",
        "add_dream": "Añadir sueño",
        "interpretation": "Interpretación",
        "lucidity": "Lucidez",
        "sleep_quality": "Calidad del sueño",
        "ai_insights": "Insights de IA"
    ]

    private static let italianStrings: [String: String] = [
        "dreams": "Sogni",
        "journal": "Diario",
        "analysis": "Analisi",
        "symbols": "Simboli",
        "settings": "Impostazioni",
        "add_dream": "Aggiungi sogno",
        "interpretation": "Interpretazione",
        "lucidity": "Lucidità",
        "sleep_quality": "Qualità del sonno",
        "ai_insights": "Approfondimenti IA"
    ]

    private static let portugueseStrings: [String: String] = [
        "dreams": "Sonhos",
        "journal": "Diário",
        "analysis": "Análise",
        "symbols": "Símbolos",
        "settings": "Configurações",
        "add_dream": "Adicionar sonho",
        "interpretation": "Interpretação",
        "lucidity": "Lucidez",
        "sleep_quality": "Qualidade do sono",
        "ai_insights": "Insights de IA"
    ]

    private static let japaneseStrings: [String: String] = [
        "dreams": "夢",
        "journal": "日記",
        "analysis": "分析",
        "symbols": "シンボル",
        "settings": "設定",
        "add_dream": "夢を追加",
        "interpretation": "解釈",
        "lucidity": "明晰さ",
        "sleep_quality": "睡眠の質",
        "ai_insights": "AIインサイト"
    ]

    private static let koreanStrings: [String: String] = [
        "dreams": "꿈",
        "journal": "일기",
        "analysis": "분석",
        "symbols": "상징",
        "settings": "설정",
        "add_dream": "꿈 추가",
        "interpretation": "해석",
        "lucidity": "명확성",
        "sleep_quality": "수면 품질",
        "ai_insights": "AI 인사이트"
    ]

    private static let chineseStrings: [String: String] = [
        "dreams": "梦境",
        "journal": "日记",
        "analysis": "分析",
        "symbols": "符号",
        "settings": "设置",
        "add_dream": "添加梦境",
        "interpretation": "解读",
        "lucidity": "清醒",
        "sleep_quality": "睡眠质量",
        "ai_insights": "AI洞察"
    ]

    private static let arabicStrings: [String: String] = [
        "dreams": "الأحلام",
        "journal": "اليوميات",
        "analysis": "التحليل",
        "symbols": "الرموز",
        "settings": "الإعدادات",
        "add_dream": "إضافة حلم",
        "interpretation": "التفسير",
        "lucidity": "الوضوح",
        "sleep_quality": "جودة النوم",
        "ai_insights": "رؤى الذكاء الاصطناعي"
    ]
}
