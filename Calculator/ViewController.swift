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
    @IBOutlet weak var variableDisplay: UILabel!
    
    private var brain = CalculatorBrain()
    private var variables = Dictionary<String, Double>()
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
        
        evaluateAndUpdateUI()
    }
    
    @IBAction func setOperandVariable(_ sender: UIButton) {
        if let variable = sender.currentTitle {
            brain.setOperand(variable: variable)
        }
        evaluateAndUpdateUI()
    }
    
    @IBAction func setVariableValue(_ sender: UIButton) {
        if var variable = sender.currentTitle {
            variable = variable.substring(from: variable.index(after: variable.startIndex))
            variables[variable] = displayValue
            variableDisplay.text = "M = \(display.text!)"
            evaluateAndUpdateUI()
        }
    }
    
    private func evaluateAndUpdateUI() {
        let evaluationResult = brain.evaluate(using: variables)
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
        variables = Dictionary<String, Double>()
        variableDisplay.text = " "
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping {
            display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            if display.text! == "" || display.text! == "0" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        }
        else {
            brain.undo()
            evaluateAndUpdateUI()
        }
    }
}
