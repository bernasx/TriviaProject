//
//  GameEndViewController.swift
//  TriviaProject


import UIKit

class GameEndViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var correctAnswers: [String] = []
    var givenAnswers: [String] = []
    var questions: [String] = []
    var selectedQuestion: Int?
    var score: Int = 0
    @IBOutlet weak var finalScoreLabel: UILabel!
    
    //funçoes do tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return correctAnswers.count
    }
    
    //Constroi as cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameEndCell" , for: indexPath)
        cell.selectionStyle = .none
        //tableview design
        tableView.separatorStyle = .none
        tableView.layer.borderWidth = 2
        tableView.layer.borderColor = UIColor.lightGray .cgColor
        tableView.layer.cornerRadius = 8
        //------------
        let label  = cell.viewWithTag(1000) as! UILabel;
        //define as cores 
        if correctAnswers[indexPath.row] == givenAnswers[indexPath.row]{
            label.backgroundColor = UIColor(red: 126/255, green: 233/255, blue: 126/255, alpha: 1.0)
        }else{
            label.backgroundColor = UIColor(red: 247/255, green: 100/255, blue: 100/255, alpha: 1.0)
        }
        label.text = questions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuestion = indexPath.row
        self.performSegue(withIdentifier: "questionSegue", sender: self)
    }
    @IBOutlet weak var answersTableView: UITableView!
    //-------------
    
    //oque fazer com o segue
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        if segue.identifier == "questionSegue"{
            let vc = segue.destination as! QuestionViewController
            vc.questions = self.questions
            vc.givenAnswers = self.givenAnswers
            vc.correctAnswers = self.correctAnswers
            vc.selectedQuestion = self.selectedQuestion!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate para o tableview saber onde estao as suas funçoes
        answersTableView.delegate = self
        answersTableView.dataSource = self
        fillLabels()
    }
    
    func fillLabels(){
        finalScoreLabel.text = "Final score: \(score)/\(givenAnswers.count)"
    }

}
