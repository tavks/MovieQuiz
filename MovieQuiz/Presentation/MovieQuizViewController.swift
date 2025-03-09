import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageViewBorders()
        let nextQuestion = convert(model: questions[currentQuestionIndex])
        show(quiz: nextQuestion)
    }
    
    private func setupImageViewBorders() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    private func switchButtonState(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        yesButton.alpha = isEnabled ? 1.0 : 0.5
        noButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.question,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.convert(model: questions[self.currentQuestionIndex])
            self.show(quiz: firstQuestion)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        let borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderColor = borderColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.switchButtonState(isEnabled: true)
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                 text: "Ваш результат \(correctAnswers)/\(questions.count)",
                                                 buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func handleAnswer(givenAnswer: Bool) {
        switchButtonState(isEnabled: false)
        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        showAnswerResult(isCorrect: givenAnswer == correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: true)
    }
}

private struct QuizQuestion {
    let image: String
    let question: String
    let correctAnswer: Bool
}

private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

private let questions: [QuizQuestion] = [
    QuizQuestion(image: "The Godfather", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Dark Knight", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Kill Bill", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Avengers", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Deadpool", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Green Knight", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Old", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "The Ice Age Adventures of Buck Wild", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Tesla", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Vivarium", question: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
]
