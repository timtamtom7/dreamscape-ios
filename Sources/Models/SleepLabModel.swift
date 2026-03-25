import Foundation

// MARK: - R4: Enhanced Sleep Conditions

enum MattressType: String, Codable, CaseIterable, Identifiable {
    case memoryFoam = "memory_foam"
    case innerspring = "innerspring"
    case latex = "latex"
    case hybrid = "hybrid"
    case air = "air"
    case water = "water"
    case floor = "floor"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .memoryFoam: return "Memory Foam"
        case .innerspring: return "Innerspring"
        case .latex: return "Latex"
        case .hybrid: return "Hybrid"
        case .air: return "Air Mattress"
        case .water: return "Water Bed"
        case .floor: return "Floor/Futon"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .memoryFoam: return "cloud.fill"
        case .innerspring: return "circle.grid.3x3.fill"
        case .latex: return "leaf.fill"
        case .hybrid: return "square.grid.2x2.fill"
        case .air: return "wind"
        case .water: return "drop.fill"
        case .floor: return "square.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

enum RoomTemperature: Int, Codable, CaseIterable, Identifiable {
    case cold = 60
    case cool = 64
    case slightlyCool = 67
    case ideal = 68
    case slightlyWarm = 71
    case warm = 74
    case hot = 78

    var id: Int { rawValue }

    var displayName: String { "\(rawValue)°F" }

    var dreamRecallMultiplier: Double {
        switch self {
        case .ideal: return 3.0
        case .slightlyCool, .slightlyWarm: return 2.0
        case .cool, .warm: return 1.5
        case .cold, .hot: return 1.0
        }
    }

    var qualityImpact: Double {
        switch self {
        case .ideal: return 1.2
        case .slightlyCool, .slightlyWarm: return 1.1
        case .cool, .warm: return 1.0
        case .cold, .hot: return 0.8
        }
    }
}

enum SoundLevel: String, Codable, CaseIterable, Identifiable {
    case silent = "silent"
    case whiteNoise = "white_noise"
    case rain = "rain"
    case fan = "fan"
    case city = "city"
    case noisy = "noisy"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .silent: return "Silent"
        case .whiteNoise: return "White Noise"
        case .rain: return "Rain Sounds"
        case .fan: return "Fan"
        case .city: return "City Sounds"
        case .noisy: return "Noisy"
        }
    }

    var icon: String {
        switch self {
        case .silent: return "speaker.slash.fill"
        case .whiteNoise: return "waveform"
        case .rain: return "cloud.rain.fill"
        case .fan: return "fan.fill"
        case .city: return "building.2.fill"
        case .noisy: return "exclamationmark.triangle.fill"
        }
    }

    var dreamImpact: String {
        switch self {
        case .silent: return "May increase nightmare frequency"
        case .whiteNoise: return "Promotes deep, restful sleep"
        case .rain: return "Associated with vivid, emotional dreams"
        case .fan: return "Helps mask disruptions"
        case .city: return "May fragment dream continuity"
        case .noisy: return "Can reduce REM quality"
        }
    }
}

enum LightLevel: String, Codable, CaseIterable, Identifiable {
    case completeDarkness = "complete_darkness"
    case dimLight = "dim_light"
    case nightLight = "night_light"
    case streetLight = "street_light"
    case bright = "bright"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .completeDarkness: return "Complete Darkness"
        case .dimLight: return "Dim Light"
        case .nightLight: return "Night Light"
        case .streetLight: return "Street Light"
        case .bright: return "Bright"
        }
    }

    var icon: String {
        switch self {
        case .completeDarkness: return "moon.fill"
        case .dimLight: return "moon.righthalf.fill"
        case .nightLight: return "lightbulb.fill"
        case .streetLight: return "light.beacon.max.fill"
        case .bright: return "sun.max.fill"
        }
    }
}

enum FoodBeforeBed: String, Codable, CaseIterable, Identifiable {
    case none = "none"
    case lightSnack = "light_snack"
    case heavyMeal = "heavy_meal"
    case dairy = "dairy"
    case sugar = "sugar"
    case alcohol = "alcohol"
    case caffeine = "caffeine"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "Nothing"
        case .lightSnack: return "Light Snack"
        case .heavyMeal: return "Heavy Meal"
        case .dairy: return "Dairy"
        case .sugar: return "Sugar/Sweets"
        case .alcohol: return "Alcohol"
        case .caffeine: return "Caffeine"
        }
    }

    var icon: String {
        switch self {
        case .none: return "checkmark.circle.fill"
        case .lightSnack: return "leaf.fill"
        case .heavyMeal: return "fork.knife"
        case .dairy: return "cup.and.saucer.fill"
        case .sugar: return "birthday.cake.fill"
        case .alcohol: return "wineglass.fill"
        case .caffeine: return "mug.fill"
        }
    }

    var dreamEffect: String {
        switch self {
        case .none: return "Clean baseline for dream recall"
        case .lightSnack: return "Minor impact on dream vividness"
        case .heavyMeal: return "May cause vivid or disturbing dreams"
        case .dairy: return "Often linked to whimsical dreams"
        case .sugar: return "Can increase dream intensity"
        case .alcohol: return "Reduces REM, fragments recall"
        case .caffeine: return "Reduces sleep quality & recall"
        }
    }
}

// MARK: - SleepLabRecord

struct SleepLabRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date

    // Sleep environment
    var mattressType: MattressType?
    var roomTemperature: RoomTemperature?
    var soundLevel: SoundLevel?
    var lightLevel: LightLevel?
    var foodBeforeBed: FoodBeforeBed?

    // Screen time
    var screenTimeBeforeBed: Int? // minutes

    // Sleep quality (from R3)
    var quality: SleepQuality
    var hoursSlept: Double
    var notes: String?

    // Linked dream
    var linkedDreamId: UUID?

    // R4: AI-generated optimization tips
    var optimizationTips: [String]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mattressType: MattressType? = nil,
        roomTemperature: RoomTemperature? = nil,
        soundLevel: SoundLevel? = nil,
        lightLevel: LightLevel? = nil,
        foodBeforeBed: FoodBeforeBed? = nil,
        screenTimeBeforeBed: Int? = nil,
        quality: SleepQuality = .fair,
        hoursSlept: Double = 7.0,
        notes: String? = nil,
        linkedDreamId: UUID? = nil,
        optimizationTips: [String] = []
    ) {
        self.id = id
        self.date = date
        self.mattressType = mattressType
        self.roomTemperature = roomTemperature
        self.soundLevel = soundLevel
        self.lightLevel = lightLevel
        self.foodBeforeBed = foodBeforeBed
        self.screenTimeBeforeBed = screenTimeBeforeBed
        self.quality = quality
        self.hoursSlept = hoursSlept
        self.notes = notes
        self.linkedDreamId = linkedDreamId
        self.optimizationTips = optimizationTips
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Sleep Setup Tip

struct SleepSetupTip: Identifiable {
    let id = UUID()
    let category: TipCategory
    let title: String
    let description: String
    let impact: TipImpact

    enum TipCategory: String {
        case temperature = "Temperature"
        case sound = "Sound"
        case light = "Light"
        case mattress = "Mattress"
        case food = "Food"
        case screenTime = "Screen Time"
        case routine = "Routine"
    }

    enum TipImpact: String {
        case high = "High Impact"
        case medium = "Medium Impact"
        case low = "Low Impact"
    }
}
