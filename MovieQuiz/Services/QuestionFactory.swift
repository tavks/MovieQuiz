import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    //    private let questions: [QuizQuestion] = [
    //        QuizQuestion(image: "The Godfather", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Dark Knight", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Kill Bill", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Avengers", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Deadpool", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "The Green Knight", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    //        QuizQuestion(image: "Old", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "Tesla", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    //        QuizQuestion(image: "Vivarium", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    //    ]
    
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    
    private var movies: [MostPopularMovie] = []
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        question: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
