//
//  ViewController.swift
//  Calculator
//
//  Created by Vladimir Burmistrovich on 2/14/17.
//  Copyright © 2017 Vladimir Burmistrovich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    private var brain = CalculatorBrain()
    var userIsInTheMiddleOfTyping = false
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6
            display.text = formatter.string(from: NSNumber(value: newValue))
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || !textCurrentlyInDisplay.contains(".") {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else {
            if digit == "." {
                display.text = "0."
            }
            else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        let evaluationResult = brain.evaluate()
        if let result = evaluationResult.result {
            displayValue = result
        }
        
        let description = evaluationResult.description
        if evaluationResult.isPending {
            descriptionDisplay.text = description + " ..."
        }
        else {
            descriptionDisplay.text = description + " ="
        }
    }
    
    @IBAction func clear() {
        brain.clear()
        displayValue = 0
        descriptionDisplay.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping {
            display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            if display.text! == "" || display.text! == "0" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        }
    }
}
