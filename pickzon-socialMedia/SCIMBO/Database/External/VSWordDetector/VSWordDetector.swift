//
//  VSWordDetector.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 4/11/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit



protocol VSWordDetectorDelegate: AnyObject {
    func wordDetector(wordDetector:VSWordDetector,word:String)
}

class VSWordDetector: NSObject {
    
    var delegate:VSWordDetectorDelegate?
    
    
    //MARK:  - Initializaiton    
    override init() {
        super.init()
    }
    
    
    //MARK: - Adding Detector on view
    
    func addOnView(view:UIView){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        if let label = view as? UILabel{
            label.isUserInteractionEnabled = true
        }
    }
    
    
    
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        
        
        guard let label = sender.view as? ExpandableLabel , sender.state == .ended  else{
            return
        }
        
        guard let text = label.attributedText else { return }
        
        // Get tap location
        let location = sender.location(in: label)

        // Find character index at tap location
        if let characterIndex = label.characterIndex(at: location) {
            
            // Find range of tapped word
            var start = characterIndex
            var end = characterIndex
            
            // Find start of the word
            while start > 0 {
                let range = NSRange(location: start-1, length: 1)
                let substring = (text.string as NSString).substring(with: range)
                if substring == " " || substring == "\n" || substring == "..." || substring == ","{
                    break
                }
                start -= 1
            }
            
            // Find end of the word
            while end < text.length {
                let range = NSRange(location: end, length: 1)
                let substring = (text.string as NSString).substring(with: range)
                if substring == " " || substring == "\n" || substring == "..." || substring == "," || substring == "#" || substring == "@"{
                    break
                }
                end += 1
            }
            
            // Extract tapped word from attributed text
            let range = NSRange(location: start, length: end - start)
            let tappedWord = (text.string as NSString).substring(with: range)
            self.delegate?.wordDetector(wordDetector: self, word: tappedWord)

            // Do something with the tapped word
            print("Tapped word: \(tappedWord)")
        }else{
            self.delegate?.wordDetector(wordDetector: self, word: "")
        }
    }

    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        
        guard let label = tapGesture.view as? UILabel else{
            return
        }
        
        guard let text = label.attributedText else { return }
        // Get tap location
                let location = tapGesture.location(in: label)
                
                // Find character index at tap location
                if let characterIndex = label.characterIndex(at: location) {
                    // Find range of word containing tapped character
                    let range = (text.string.encodeEmoji() as NSString).rangeOfWord(at: characterIndex)
                    
                    // Do something with the tapped word
                    let tappedWord = (text.string.encodeEmoji() as NSString).substring(with: range)
                    self.delegate?.wordDetector(wordDetector: self, word: tappedWord)

                    print("Tapped word: \(tappedWord)")
                }
        
      /*  guard let attributedText = label.attributedText else { return }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let locationOfTouchInLabel = tapGesture.location(in: label)
        let labelSize = label.bounds.size
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if let tappedWordRange = self.getWordRange(at: indexOfCharacter, in: attributedText.string) {
            let tappedWord = (attributedText.string as NSString).substring(with: tappedWordRange)
            self.delegate?.wordDetector(wordDetector: self, word: tappedWord)
            // label.onWordTapped?(tappedWord)
        }*/
    }
    
//    private func getWordRange(at index: Int, in text: String) -> NSRange? {
//        let startIndex = text.index(text.startIndex, offsetBy: index)
//
//        if let endIndex = text.index(startIndex, offsetBy: text.length, limitedBy: text.endIndex) {
//
//            let endIndex = text.index(startIndex, until: { !CharacterSet.alphanumerics.contains($0.unicodeScalars.first!) })
//
//            let range = startIndex..<endIndex
//            return NSRange(range, in: text)
//        }
//    }
    
}



extension UILabel {
    func characterIndex(at point: CGPoint) -> Int? {
        guard let attributedText = attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        //textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = .byTruncatingTail
        
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        
//        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)
//        let characterIndexx = layoutManager.glyphIndexForCharacter(at: glyphIndex)
//
//        return characterIndexx

        
        return index
    }
}


    extension NSString {
        func rangeOfWord(at index: Int) -> NSRange {
            let stringRange = NSRange(location: 0, length: length)
            let options = NSString.EnumerationOptions.byWords.union(.reverse)
            
            var wordRange = NSRange(location: index, length: 0)
            enumerateSubstrings(in: stringRange, options: options) { (substring, substringRange, _, stop) in
                if substringRange.location + substringRange.length <= index {
                    stop.pointee = true
                } else {
                    wordRange = substringRange
                    stop.pointee = true
                }
            }
            return wordRange
        }
    }



extension String {
    func encodeEmoji() -> String {
        let data = self.data(using: .nonLossyASCII, allowLossyConversion: false)!
        return String(data: data, encoding: .utf8)!
    }

    func decodeEmoji() -> String? {
        let data = self.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
}
