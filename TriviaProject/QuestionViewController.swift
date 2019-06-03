//
//  QuestionViewController.swift
//  TriviaProject


import UIKit

class QuestionViewController: UIViewController {

    var correctAnswers: [String] = []
    var givenAnswers: [String] = []
    var questions: [String] = []
    var selectedQuestion : Int = 0
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblGivenAnswer: UILabel!
    @IBOutlet weak var lblCorrectAnswer: UILabel!
    
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    
    @IBAction func leftArrowPressed(_ sender: Any?) {
        selectedQuestion -= 1
        configureLabels()
        configureArrows()
    }
    @IBAction func rightArrowPressed(_ sender: Any?) {
        selectedQuestion += 1
        configureLabels()
        configureArrows()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLabels()
        configureArrows()
        // Do any additional setup after loading the view.
    }
    
    func configureLabels(){
        
        lblQuestion.text! = questions[selectedQuestion]
        lblGivenAnswer.text! = givenAnswers[selectedQuestion]
        lblCorrectAnswer.text! = correctAnswers[selectedQuestion]
    }
    
    func configureArrows(){
        if selectedQuestion == 0{
            leftArrow.isEnabled = false
            leftArrow.alpha = 0.2
        }else{
            leftArrow.isEnabled = true
            leftArrow.alpha = 1
        }
        
        if selectedQuestion == givenAnswers.count-1{
            rightArrow.isEnabled = false
            rightArrow.alpha = 0.2
        }else{
            rightArrow.isEnabled = true
            rightArrow.alpha = 1
        }
    }
    
}
