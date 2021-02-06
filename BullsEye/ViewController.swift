/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ViewController: UIViewController {
  var defaults = UserDefaults.standard

  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var highestRoundLabel: UILabel!
  @IBOutlet weak var targetGuessLabel: UILabel!
  @IBOutlet weak var targetGuessField: UITextField!
  @IBOutlet weak var roundLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var languagesegmentedControl: UISegmentedControl!
  @IBOutlet weak var btnHitMe: UIButton!
  @IBOutlet weak var btnStartOver: UIButton!
  
  let game = BullsEyeGame()
  var highscore: HighScore!
  enum GameStyle: Int { case moveSlider, guessPosition }
  enum AppLang: Int { case english, french }
  let gameStyleRange = 0..<2
  var gameStyle = GameStyle.guessPosition
  var appLanguage = AppLang.english
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let defaultGameStyle = defaults.integer(forKey: "gameStyle")
    print(defaultGameStyle)
    if gameStyleRange.contains(defaultGameStyle) {
      gameStyle = GameStyle(rawValue: defaultGameStyle)!
      segmentedControl.selectedSegmentIndex = defaultGameStyle
    } else {
      gameStyle = .moveSlider
      defaults.set(0, forKey: "gameStyle")
    }
    updateView()
  }
  
  @IBAction func chooseGameStyle(_ sender: UISegmentedControl) {
    if gameStyleRange.contains(sender.selectedSegmentIndex) {
      gameStyle = GameStyle(rawValue: sender.selectedSegmentIndex)!
      updateView()
    }
    defaults.set(sender.selectedSegmentIndex, forKey: "gameStyle")
  }
  
  func updateView() {
    switch gameStyle {
    case .moveSlider:
      targetGuessLabel.text = appLanguage == .english ? "CloseAsYouCan".localizableString(loc: "en") : "CloseAsYouCan".localizableString(loc: "fr")
      targetGuessField.text = "\(game.targetValue)"
      targetGuessField.isEnabled = false
      slider.value = Float(game.startValue)
      slider.isEnabled = true
    case .guessPosition:
      targetGuessLabel.text = appLanguage == .english ? "GuessTheSlider".localizableString(loc: "en") : "GuessTheSlider".localizableString(loc: "fr")
      targetGuessField.text = ""
      targetGuessField.placeholder = "1-100"
      targetGuessField.isEnabled = true
      slider.value = Float(game.targetValue)
      slider.isEnabled = false
    }
    
    roundLabel.text = appLanguage == .english ? String(format: "round".localizableString(loc: "en") + "%d", game.round) : String(format: "round".localizableString(loc: "fr") + "%d", game.round)
    scoreLabel.text = appLanguage == .english ? String(format: "score".localizableString(loc: "en") + "%d", game.scoreTotal) : String(format: "score".localizableString(loc: "fr") + "%d", game.scoreTotal)
    
    //    will update the highscore if needed
    if game.scoreTotal >= highscore.highScore {
      highscore.highScore = game.scoreTotal
    }
    highScoreLabel.text = appLanguage == .english ? String(format: "highScore".localizableString(loc: "en") + "%d", highscore.highScore) : String(format: "highScore".localizableString(loc: "fr") + "%d", highscore.highScore)
    //highScoreLabel.text = "High Score: \(highscore.highScore)"
    if game.round > highscore.highestRound {
      highscore.highestRound = game.round
    }
    highestRoundLabel.text = appLanguage == .english ? String(format: "highestRound".localizableString(loc: "en") + "%d", highscore.highestRound) : String(format: "highestRound".localizableString(loc: "fr") + "%d", highscore.highestRound)
    //highestRoundLabel.text = "Highest Round: \(highscore.highestRound)"
  }
  
  @IBAction func checkGuess(_ sender: Any) {
    var guess: Int?
    switch gameStyle {
    case .moveSlider:
      guess = Int(lroundf(slider.value))
    case .guessPosition:
      targetGuessField.resignFirstResponder()
      guess = Int(targetGuessField.text!)
    }
    if let guess = guess {
      showScoreAlert(difference: game.check(guess: guess))
    } else {
      showNaNAlert()
    }
  }
  
  func showScoreAlert(difference: Int) {
    
    let title = appLanguage == .english ? String(format: "alertTitle".localizableString(loc: "en"), game.scoreRound) : String(format: "alertTitle".localizableString(loc: "fr"), game.scoreRound)
    let message = appLanguage == .english ? String(format: "alertMessage".localizableString(loc: "en"), game.targetValue) : String(format: "alertMessage".localizableString(loc: "fr"), game.targetValue)
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    UIView.animate(withDuration: 1.2) {
      self.view.backgroundColor = self.game.scoreRound > 50 ? .green : .red
    }
    
    let action = UIAlertAction(title: appLanguage == .english ? "ok".localizableString(loc: "en") : "ok".localizableString(loc: "fr"), style: .default, handler: { action in
      self.game.startNewRound()
      self.updateView()
    })
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  func showNaNAlert() {
    let alert = UIAlertController(title: "Not A Number",
                                  message: "Please enter a positive number",
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func startOver(_ sender: Any) {
    game.startNewGame()
    updateView()
  }
  
  //MARK: - For language changing -
  @IBAction func languageChangeClick(_ sender: UISegmentedControl) {
    if languagesegmentedControl.selectedSegmentIndex == 0{
      appLanguage = .english
      languageChange("en")
    }else{
      appLanguage = .french
      languageChange("fr")
    }
  }
 
  func languageChange(_ strLan: String){
    if gameStyle == .moveSlider{
      targetGuessLabel.text = "CloseAsYouCan".localizableString(loc: strLan)
    }else{
      targetGuessLabel.text = "GuessTheSlider".localizableString(loc: strLan)
    }
    
    btnHitMe.setTitle("hitMe".localizableString(loc: strLan), for: .normal)
    btnStartOver.setTitle("startOver".localizableString(loc: strLan), for: .normal)
    roundLabel.text = "round".localizableString(loc: strLan)
    scoreLabel.text = "score".localizableString(loc: strLan)
    segmentedControl.setTitle("slide".localizableString(loc: strLan), forSegmentAt: 0)
    segmentedControl.setTitle("type".localizableString(loc: strLan), forSegmentAt: 1)
    highScoreLabel.text = "highScore".localizableString(loc: strLan)
    highestRoundLabel.text = "highestRound".localizableString(loc: strLan)
  }
}

extension String{
  func localizableString(loc: String) -> String{
    let path = Bundle.main.path(forResource: loc, ofType: "lproj")
    let bundle = Bundle(path: path!)
    return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
  }
}
