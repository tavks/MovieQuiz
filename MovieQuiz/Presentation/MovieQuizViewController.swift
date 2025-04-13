import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private var resultAlertPresenter: ResultAlertPresenter = ResultAlertPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageViewBorders()
        questionFactory.delegate = self
        resultAlertPresenter.delegate = self
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let nextQuestion = question else { return }
        currentQuestion = nextQuestion
        let viewModel = convert(model: nextQuestion)
        show(quiz: viewModel)
        
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
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
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {[weak self] _ in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.switchButtonState(isEnabled: true)
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(result: GameResult(correct: correctAnswers, total: 10, date: Date()))
            let viewModel = makeResultsViewModel()
            resultAlertPresenter.showResultAlert(result: viewModel, completion: { [weak self] in
                guard let self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            })
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func makeResultsViewModel() -> QuizResultsViewModel {
        let bestGame = statisticService.bestGame
        let dateString = bestGame.date.dateTimeString
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        return QuizResultsViewModel(title: "Этот раунд окончен!",
                                    text: """
                                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                                    Количество сыгранных квизов: \(statisticService.gamesCount)
                                    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateString))
                                    Средняя точность: \(accuracy)%
                                    """,
                                    buttonText: "Сыграть ещё раз")
    }
    
    private func handleAnswer(givenAnswer: Bool) {
        switchButtonState(isEnabled: false)
        if let correctAnswer = currentQuestion?.correctAnswer {
            showAnswerResult(isCorrect: givenAnswer == correctAnswer)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(givenAnswer: true)
    }
}
