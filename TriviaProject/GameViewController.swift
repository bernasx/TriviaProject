//
//  GameViewController.swift
//  TriviaProject


import UIKit
//structs para o JSON
struct Results: Decodable{
    
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct JsonResults: Decodable{
    
    let response_code: Int
    let results: [Results]
    
}

//permite usar .htmlDecoded para converter carateres especiais
extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil).string
        
        return decoded ?? self
    }
}



class GameViewController: UIViewController {
    var url: URL? = nil//recebe informação ao clicar no botao do ecra principal
    var gameObject: JsonResults?
    var currentQuestion: Int = 0
    var score: Int = 0
    var wrongAnswers: Int = 0
    let statsManager = StatManager()
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet var buttonCollection: [UIButton]!
    @IBOutlet weak var lblScore: ScoreLabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblDiff: ScoreLabel!
    
    //servem para guardar e enviar informacao sobre o jogo
    var correctAnswers: [String] = []
    var givenAnswers: [String] = []
    var questions: [String] = []
    
    //select buttons
    @IBAction func answerButton(_ sender: UIButton){
        deselectAllButtons()
        sender.isSelected = true
        btnNext.isEnabled = true
    }
    func deselectAllButtons(){
        for subView in view.subviews
        {
            // Set all the other buttons as normal state
            if let button = subView as? UIButton {
                button.isSelected = false
            }
        }
    }

    //botao de proxima pergunta, verifica o estado do jogo e termina depois do numero de perguntas
    @IBAction func btnNext(_ sender: UIButton) {
        self.statsManager.updateTotalAnswers()
        btnNext.isEnabled = false
        if currentQuestion < gameObject!.results.count{
            self.setScore()
            self.nextQuestion()
            self.deselectAllButtons()
        }
        else{
            self.setScore()
            let alert = UIAlertController(title: "Game Finished", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                self.statsManager.updateGamesPlayed()
                NSLog("The \"OK\" alert occured.")
                self.performSegue(withIdentifier: "gameFinished", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //mostra a proxima pergunta e mistura as respostas
    func nextQuestion(){
        lblDiff.text! = ("Difficulty: \(gameObject!.results[currentQuestion].difficulty.capitalized)")
        self.title = "" //nao apagar isto, nao funciona corretamente sem esta linha lol
        self.title = "\(currentQuestion+1)/\(gameObject!.results.count)"
        //array com todas as questoes misturadas
        var questionArray = gameObject?.results[currentQuestion].incorrect_answers
        questionArray?.append((gameObject?.results[currentQuestion].correct_answer)!)
        
        if gameObject?.results[currentQuestion].type != "boolean"{
            questionArray?.shuffle()
        }
        
        //label
        let question = gameObject?.results[currentQuestion].question.htmlDecoded
        lblQuestion.text = question
        lblQuestion.font = UIFont (name: "Arial", size: 20)
        lblQuestion.textAlignment = .center
    
        //mostra apenas a quantidade de botoes necessaria para o tipo de pergunta
        if gameObject?.results[currentQuestion].type == "boolean"{
            for i in 0...1{
                let string = questionArray![i].htmlDecoded
                buttonCollection[i].setTitle( string, for: UIControl.State.normal)
                buttonCollection[2].isHidden = true
                buttonCollection[3].isHidden = true

            }
        }else{
            for i in 0...3{
                buttonCollection[2].isHidden = false
                buttonCollection[3].isHidden = false
                let string = questionArray![i].htmlDecoded
                buttonCollection[i].setTitle( string, for: UIControl.State.normal)
            }
        }
        currentQuestion+=1
    }
    
    //adiciona um ponto e da update a label
    func setScore(){
        buttonCollection.forEach{
            button in
            if button.isSelected == true{
                print(button.titleLabel?.text )
                print(gameObject?.results[currentQuestion-1].correct_answer.htmlDecoded)
                //arrays para enviar para o ecra pos jogo
                correctAnswers.append((gameObject?.results[currentQuestion-1].correct_answer.htmlDecoded)!)
                givenAnswers.append(button.titleLabel!.text!)
                questions.append((gameObject?.results[currentQuestion-1].question.htmlDecoded)!)
                //-----------
                if button.titleLabel?.text == gameObject?.results[currentQuestion-1].correct_answer.htmlDecoded{
                    score = score + 1
                    lblScore.text = "\(score) √ | X \(wrongAnswers)"
                    self.statsManager.updateCorrectAnswers()
                }
                else{
                    wrongAnswers = wrongAnswers + 1
                    lblScore.text = "\(score) √ | X \(wrongAnswers)"

                }
            }
        }
    }
    
    //retorna um objeto do tipo JsonResults do URL
    func getQuestions(completionHandler: @escaping (_ gameObject: JsonResults?, Error?)->Void){
        
        URLSession.shared.dataTask(with: url!){
            (data,response,err) in
            guard let data = data else {return}
            
            do{
                let jsonResults = try JSONDecoder().decode(JsonResults.self, from: data)
                completionHandler(jsonResults, nil)
            }catch{
                print(error.localizedDescription)
                completionHandler(nil, error)
                self.navigationController?.popViewController(animated: true)
            }
        }.resume()
    }
    
    //oque fazer com o segue
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        if segue.identifier == "gameFinished"{
            let vc = segue.destination as! GameEndViewController
            vc.correctAnswers = self.correctAnswers
            vc.givenAnswers = self.givenAnswers
            vc.questions = self.questions
            vc.score = self.score
        }
    }
    
    //screen start
    override func viewDidLoad() {
        super.viewDidLoad()
        lblScore.text = "\(score) √ | X \(wrongAnswers)"
        btnNext.isEnabled = false
        self.buttonCollection.forEach{
            button in
            button.isHidden = true
        }

        //carrega as perguntas
        getQuestions {
            (retorno,error) in
            DispatchQueue.main.async{
                if retorno == nil{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.gameObject = retorno!
                    //verifica se existem perguntas suficientes
                    if self.gameObject?.response_code == 0{
                        self.buttonCollection.forEach{
                            button in
                            button.isHidden = false
                        }
                        self.nextQuestion()
                    }else{
                        self.title = "Not Enough Questions!"
                        
                    }
                }
            }
        }
        //----------------
    }
}
