//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vladimir Burmistrovich on 2/14/17.
//  Copyright © 2017 Vladimir Burmistrovich. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var accumulator: Double?
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "±": Operation.unaryOperation({ -$0 }),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "+": Operation.binaryOperation(+),
        "−": Operation.binaryOperation(-),
        "=": Operation.equals
    ]
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var descriptionString = ""
    private var pendingDescriptionString = ""
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var description: String {
        return "\(descriptionString) \(pendingDescriptionString)"
    }
    
    private mutating func addToDescription(_ string: String, surround: Bool = false, clearIfNotPending: Bool = false) {
        if clearIfNotPending && !resultIsPending {
            descriptionString = ""
        }
        var workingDescriptionString = pendingBinaryOperation == nil ? descriptionString : pendingDescriptionString
        if surround {
            workingDescriptionString = "\(string)(\(workingDescriptionString))"
        }
        else {
            workingDescriptionString += " \(string)"
        }
        workingDescriptionString = workingDescriptionString.trimmingCharacters(in: CharacterSet.whitespaces)
        if pendingBinaryOperation == nil {
            descriptionString = workingDescriptionString
        }
        else {
            pendingDescriptionString = workingDescriptionString
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                addToDescription(symbol, surround:false, clearIfNotPending: true)
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    addToDescription(symbol, surround: true)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    addToDescription(symbol)
                    pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                                    firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
                descriptionString += " \(pendingDescriptionString)"
                pendingDescriptionString = ""
            }
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        addToDescription(formatter.string(from: NSNumber(value: operand))!,
                         surround: false,
                         clearIfNotPending: true)
    }
    
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptionString = ""
        pendingDescriptionString = ""
    }
}
