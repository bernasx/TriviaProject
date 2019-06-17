//
//  ViewController.swift
//  TriviaProject

import UIKit
class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var difficultyTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var totalGamesLbl: UILabel!
    @IBOutlet weak var totalAnswersLbl: UILabel!
    @IBOutlet weak var correctAnswersLbl: UILabel!
    @IBOutlet weak var percentageAnswersLbl: UILabel!
    @IBOutlet weak var mostPlayedCatLbl: UILabel!
    
    var selectedTextFieldValues: [UITextField?: Int] = [:] // guarda os ultimos valores selecionados
    var optionTypes: [String] = []
    var selectedTextField : UITextField?
    var gameConfig: gameConfigArrs? = nil // objeto que contem todos os arrays e dicts para construir os pickers
    let statsManager = StatManager()

    //textField e Button vents
    @IBAction func onDifficultyClick(_ sender: UITextField) {
        selectedTextField = sender
        optionTypes = gameConfig!.difficultyArray
        createPickerView()
    }
    @IBAction func onTypeClick(_ sender: UITextField) {
        selectedTextField = sender
        optionTypes = gameConfig!.typeArray
        createPickerView()
    }
    @IBAction func onCategoryClick(_ sender: UITextField) {
        //array so com nomes para dar display no picker
        selectedTextField = sender
        optionTypes = gameConfig!.categoryArray
        createPickerView()
    }
    @IBAction func onStartClick(_ sender: UIButton) {
        let category = categoryTextField.text!
            //tem q se mudar para nao crashar
            print(category)
            statsManager.updateCategory(category: category)
        
        verifyAmount()
        performSegue(withIdentifier: "gameSegue", sender: self)//faz um segue com o identifier gamesegue
        
    }
    //se os valores inseridos forem maiores que 50 ou menores que 10, corrige
    @IBAction func amountVerify(_ sender: UITextField) {
        verifyAmount()
    }
    
    func verifyAmount(){
        guard var value = Int(amountTextField.text!) else {return}
        value = value < 10 ? 10 : value
        value = value > 50 ? 50 : value
        amountTextField.text! = String(value)
        print(value)
    }
    //--------------
    
    //protocol functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if optionTypes[row] == nil{
            return
        }else{
            selectedTextField?.text = optionTypes[row]
            selectedTextFieldValues[selectedTextField] = row //guard no dict o ultimo valor do picker do ultimo text field aberto
        }
       
    }
    //------------
    
    //cria e apaga o pickerview
    func createPickerView(){
        let pickerView = UIPickerView()
        pickerView.delegate = self
        selectedTextField!.inputView = pickerView
        //seleciona a ultima opcao do picker
        pickerView.selectRow(selectedTextFieldValues[selectedTextField]!, inComponent: 0, animated: true)
        //toolbar do pickerview
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        selectedTextField!.inputAccessoryView = toolbar
        //permite clicar fora para fechar
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard (){
        view.endEditing(true)
        selectedTextField = nil
    }
    //---------------
    
    //le os arrays com informaçao de um ficheiro e passa-os para os atributos da classe
    struct gameConfigArrs: Codable{
        var categoryArray: [String] = []
        var categoryDict: [String:String?] = [:]
        var typeArray: [String] = []
        var typeDict: [String:String?] = [:]
        var difficultyArray: [String] = []
        var difficultyDict: [String:String?] = [:]
    }
    
    //le e retorna objeto de arrays e dicts da gameconfig.plist
    func reader(){
        if  let path = Bundle.main.path(forResource: "GameConfig", ofType: "plist"),
            let xml  = FileManager.default.contents(atPath: path),
            let gameConfigArrays = try? PropertyListDecoder().decode(gameConfigArrs.self, from: xml){
            gameConfig = gameConfigArrays
        }
    }
    //----------
    
    //constroi o URL com as escolhas do utilizador
    func buildURL() -> URL{
        let amount = amountTextField.text!
        let category = gameConfig?.categoryDict[categoryTextField.text!]
        let difficulty = gameConfig?.difficultyDict[difficultyTextField.text!]
        let type = gameConfig?.typeDict[typeTextField.text!]
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opentdb.com"
        components.path = "/api.php"
        components.queryItems = [URLQueryItem(name:"amount", value:amount)]
        
        if(category != ""){
            components.queryItems?.append(URLQueryItem(name:"category",value:category!))
        }
        if(difficulty != ""){
            components.queryItems?.append(URLQueryItem(name:"difficulty",value:difficulty!))
        }
        if(type != ""){
            components.queryItems?.append(URLQueryItem(name:"type",value:type!))
        }
        return components.url!
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        if segue.identifier == "gameSegue"{
            var vc = segue.destination as! GameViewController
            vc.url = buildURL()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reader()
        selectedTextFieldValues = [difficultyTextField: 0,typeTextField: 0,categoryTextField: 0]
        navigationItem.hidesBackButton = true
        updateStats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateStats()
    }
    
    //vai buscar informaçoes atualizadas a base de dados
    func updateStats(){
        var percentageCorrectAnswers: Float = 0.00
        var totals: Float = 0.00
        var corrects: Float = 0.00
        //get username
        statsManager.displayUsername(completionHandler: { (username, error) in
            let welcome: NSMutableAttributedString = NSMutableAttributedString(string: "Welcome to TriviApp " + username)
            welcome.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray , range: NSRange(location: 20, length: username.count))
            self.welcomeLbl.attributedText = welcome
//            self.welcomeLbl.attributedText = "Welcome to TriviApp \(username)"
            
        })
        //get games played
        statsManager.getGamesPlayed(completionHandler: { (gamesPlayed, error) in
            let gamesP: NSMutableAttributedString = NSMutableAttributedString(string: "Games Played: " + gamesPlayed)
            gamesP.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray , range: NSRange(location: 14, length: gamesPlayed.count))
            self.totalGamesLbl.attributedText = gamesP
//            self.totalGamesLbl.attributedText = "Games Played: \(gamesPlayed)"
            
        })
        
        statsManager.getTotalAnswers(completionHandler: { (totalAnswers, error) in
            let totalA: NSMutableAttributedString = NSMutableAttributedString(string:"Total Answers: " + totalAnswers)
            totalA.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location:15, length: totalAnswers.count))
            self.totalAnswersLbl.attributedText = totalA
            totals = Float(totalAnswers)!
        })
        
        statsManager.getCorrectAnswers(completionHandler: { (correctAnswers, error) in
            let correctA: NSMutableAttributedString = NSMutableAttributedString(string:"Correct Answers: " + correctAnswers)
            correctA.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location:17, length: correctAnswers.count))
            self.correctAnswersLbl.attributedText = correctA
            corrects = Float(correctAnswers)!
            
            //percentage label
            if totals > 0.0{
                percentageCorrectAnswers = corrects / totals
                let twoDecimalPlaces = String(format: "%.2f", percentageCorrectAnswers)
                let tempString = "\(twoDecimalPlaces)%"
                let percentageA: NSMutableAttributedString = NSMutableAttributedString(string:"Correct Ratio: " + tempString)
                percentageA.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 15 ,length: tempString.count))
                self.percentageAnswersLbl.attributedText = percentageA
            }else{
                let tempString = "0%"
                let percentageA: NSMutableAttributedString = NSMutableAttributedString(string:"Correct Ratio: " + tempString)
                percentageA.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 15 ,length: tempString.count))
                self.percentageAnswersLbl.attributedText = percentageA
            }
        })
        
        statsManager.getFavoriteCategory { (favoriteCategory, error) in
            let favoriteC: NSMutableAttributedString = NSMutableAttributedString(string: "Favorite Category: " + favoriteCategory)
            favoriteC.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 19, length: favoriteCategory.count))
            self.mostPlayedCatLbl.attributedText = favoriteC
        }
    }
}
