import Foundation

final class StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.BestGame.correct)
            let total = storage.integer(forKey: Keys.BestGame.total)
            let date = storage.object(forKey: Keys.BestGame.date) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.BestGame.correct)
            storage.set(newValue.total, forKey: Keys.BestGame.total)
            storage.set(newValue.date, forKey: Keys.BestGame.date)
        }
    }
    
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0 }
        let totalQuestions = gamesCount * 10
        return (Double(correctAnswers) / (Double(totalQuestions))) * 100
    }
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case gamesCount
        
        enum BestGame {
            static let correct = "bestGame.correct"
            static let total = "bestGame.total"
            static let date = "bestGame.date"
        }
    }
    
    func store(result: GameResult) {
        gamesCount += 1
        correctAnswers += result.correct
        if result.isBetterThan(bestGame) {
            bestGame = result
        }
    }
}
