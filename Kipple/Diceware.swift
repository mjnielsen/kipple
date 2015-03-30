//
//  Dice.swift
//  Dice
//
//  Created by Michael Nielsen on 27/03/2015.
//  Copyright (c) 2015 Michael Nielsen. All rights reserved.
//

import Foundation

class Diceware {
    var wordlist: NSString!
    let special: [[String]] = [
        ["~", "!", "#", "$", "%", "^"],
        ["&", "*", "(", ")", "-", "="],
        ["+", "[", "]", "\\", "{", "}"],
        [":", ";", "\"", "'", "<", ">"],
        ["?", "/", "0", "1", "2", "3"],
        ["4", "5", "6", "7", "8", "9"]
    ]
    
    
    var err: NSError?
    
    
    init(urlForWordlistFile wUrl: NSURL) {
        self.wordlist = NSString(contentsOfURL: wUrl,
            encoding: NSUTF8StringEncoding, error: &err)
    }
    
    
    /**
    Generates a random Int between 1 and 6 inclusive using SecRandomCopyBytes.
    Uses modulo arithmetic to map the range of UInt onto the integers 1 to 6.
    
    :param: None
    
    :returns: UInt
    */
    func roll(low: Int = 1, high: Int = 6) -> Int {
        var randomBytes = UnsafeMutablePointer<UInt8>.alloc(2)
        var randomUInt = UnsafeMutablePointer<UInt16>.alloc(1)
        
        var rand: UInt16 = UInt16(pow(2.0, 16.0) - 1)
        while rand >= UInt16(pow(2.0, 16.0) - 4) {
            // Fix modulo making rolls 4, 5, or 6 slightly less likely
            SecRandomCopyBytes(kSecRandomDefault, 2, randomBytes)
            randomUInt = unsafeBitCast(randomBytes,
                UnsafeMutablePointer<UInt16>.self)
            rand = randomUInt[0]
        }
        
        randomBytes.destroy()
        randomUInt.destroy()
        
        let roll = (rand % (high - low + 1)) + low
        
        return Int(roll)
    }
    
    
    /**
    Generates a random word from the diceware word list. Will insert a random
    special character at a position based on a dice roll if passed a true Bool.
    
    :param: Bool to inicate special character (optional)
    
    :returns: A String containing the generated word
    */
    func getWord(special: Bool = false) -> String {
        var rolls: String = ""
        
        for i in 0...4 {
            rolls += String(self.roll())
        }
        
        let matchRange: NSRange! = wordlist.rangeOfString(rolls)
        let start = matchRange.location + matchRange.length + 1
        let nextRange = NSRange(location: start, length: 7)
        
        var word = wordlist.substringWithRange(nextRange)
            .componentsSeparatedByString("\n")[0]
        
        if special {
            let wordLength = countElements(word)
            var rollValue = self.roll(low: 1, high: wordLength)
            
            let specialCharacter = self.special[self.roll() - 1][self.roll() - 1]
            
            var i = 1
            var specialWord = ""
            for char in word.unicodeScalars {
                if i == rollValue { specialWord += specialCharacter }
                else { specialWord += "\(char)" }
                ++i
            }
            
            word = specialWord
        }
        
        return word
    }
    
    
    /**
    Generates a passphrase with the given number of words and with one word
    having a character replaced by a random special character if specified.
    
    :param: Int: number of words, Bool: to indicate special (optional)
    
    :returns: String: containing the passphrase
    */
    func getPassphrase(num: Int, special: Bool = false) -> String {
        var pass = ""
        
        if special {
            var rollValue = self.roll(low: 1, high: num)
            
            for i in 1...num {
                if i == rollValue { pass += getWord(special: true) }
                else { pass += getWord() }
                
                if i != (num) { pass += " "}
            }
        }
        else {
            for i in 1...num {
                pass += getWord()
                if i != (num) { pass += " "}
            }
        }
        
        return pass
    }
    
    
    /**
    Gives a good guess of the entropy for a passphrase based on the number of
    words and whether a special character is used.
    
    :param: Int: number of words, Bool: special character used
    
    :returns: Float: number of bits of entropy (kipple)
    */
    func calculateEntropy(num: Int, special: Bool) -> Float {
        return Float(num) * 12.9 + (special ? 10.0 : 0.0)
    }
    
    
    /**
    Estimates the time it would take to crack the password for an adversary
    capable of one trillion attempts per second.
    
    :param: Float: entropy
    
    :returns: Float: time in seconds
    */
    func timeToCrack(entropy: Float) -> Float {
        return (pow(entropy, 2) / 2) / 1000000000000000
    }
}