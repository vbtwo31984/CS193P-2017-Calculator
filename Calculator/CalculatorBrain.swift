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
        case nullaryOperation(() -> Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private enum InputType {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var program = [InputType]()
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
        "=": Operation.equals,
        "rnd": Operation.nullaryOperation({() in return Double(arc4random()) / Double(UInt32.max)})
    ]
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator: Double?
        var pendingBinaryOperation: PendingBinaryOperation?
        var descriptionString = ""
        var pendingDescriptionString = ""
        
        var resultIsPending: Bool {
            return pendingBinaryOperation != nil
        }
        
        func addToDescription(_ string: String, surround: Bool = false, clearIfNotPending: Bool = false) {
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
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                pendingBinaryOperation = nil
                descriptionString += " \(pendingDescriptionString)"
                pendingDescriptionString = ""
            }
        }
        
        func setOperand(operand: Double) {
            accumulator = operand
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 6
            addToDescription(formatter.string(from: NSNumber(value: operand))!,
                             surround: false,
                             clearIfNotPending: true)
        }
        
        func performOperation(_ symbol: String) {
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
                        performPendingBinaryOperation()
                        addToDescription(symbol)
                        pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                                        firstOperand: accumulator!)
                        accumulator = nil
                    }
                case .equals:
                    performPendingBinaryOperation()
                case .nullaryOperation(let function):
                    accumulator = function()
                    addToDescription(symbol, surround: false, clearIfNotPending: true)
                }
                
            }
        }
        
        for op in program {
            switch op {
            case .operand(let operand):
                setOperand(operand: operand)
            case .operation(let symbol):
                performOperation(symbol)
            case .variable(let variable):
                setOperand(operand: variables?[variable] ?? 0.0)
            }
        }
        return (result: accumulator, isPending: resultIsPending, description: "\(descriptionString) \(pendingDescriptionString)")
    }
    
    var result: Double? {
        let result = evaluate()
        return result.result
    }
    
    var resultIsPending: Bool {
        let result = evaluate()
        return result.isPending
    }
    
    var description: String {
        let result = evaluate()
        return result.description
    }
    
    mutating func performOperation(_ symbol: String) {
        program.append(InputType.operation(symbol))
    }
    
    mutating func setOperand(_ operand: Double) {
        program.append(InputType.operand(operand))
    }
    
    mutating func setVariable(_ variable: String) {
        program.append(InputType.variable(variable))
    }
    
    mutating func clear() {
        program.removeAll()
    }
}
