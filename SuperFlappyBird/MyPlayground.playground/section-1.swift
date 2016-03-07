// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

extension String {
    var wordList:[String] {
        return "".join(componentsSeparatedByCharactersInSet(NSCharacterSet.punctuationCharacterSet())).componentsSeparatedByString(" ")
    }
}

let myWordList = "don't fall off the screen".wordList


for word in myWordList {
    println(word)
}
