/// Copyright (c) 2020 Razeware LLC
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


//don't foget to use the NSCoding protocol
class HighScore: NSObject, NSCoding {
  
  
  func encode(with coder: NSCoder) {
    coder.encode(highScore, forKey: "highScore")
    coder.encode(highestRound, forKey: "highestRound")
  }
  
  required init?(coder: NSCoder) {
    highScore = coder.decodeInteger(forKey: "highScore")
    highestRound = coder.decodeInteger(forKey: "highestRound")
  }
  var highScore: Int = 0
  var highestRound: Int = 0
  // get highscoreURL using a closure
  var highScoreURL: URL = {
    let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = documentsDirectories.first!
    return documentDirectory.appendingPathComponent("score.archive")
  }()
  
  // overriding the default init() so That I can unarchive a highscore object and grab its properties. this will only happen if there is a class to save
  override init() {
    if let archivedScores = NSKeyedUnarchiver.unarchiveObject(withFile: highScoreURL.path) as? HighScore {
      highScore = archivedScores.highScore
      highestRound = archivedScores.highestRound
    }
    super.init()
  }
  
  // encode method to make sure all information you want save is saved

  
  // required init(), so all information is loaded when the class is loaded

  
  // save method. I'm giving this one to you because it is a little different then what i tought in class same concept but it need a highscore object as an argument so it knows what to save
  func saveChanges(_ highScoreObject: HighScore) -> Bool{
    print("Saving items to \(highScoreURL.path)")
    return NSKeyedArchiver.archiveRootObject(highScoreObject, toFile: highScoreURL.path)
  }
  
  
}
