//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by John Benton on 5/2/15.
//  Copyright (c) 2015 John Benton. All rights reserved.
//

import Foundation


class CalculatorBrain
{
    fileprivate enum Op
    {
        case operand(Double?)
        case symbols(String)
        case unaryOperation(String, (Double) -> Double?)
        case binaryOperation(String, Int, (Double, Double) -> Double?)
        
        fileprivate var description:String{
            get{
                switch self {
                    
                case .operand(let operand):
                    return "\(operand!)"
                    
                case .symbols(let symbol):
                    return symbol
                    
                case .unaryOperation(let symbol, _):
                    return symbol
                    
                case .binaryOperation(let symbol, _, _):
                    return symbol
                }
                
            }
        }

    }
    
    var description: String{
        get{
            var descriptionReturn = ""
            var opsReturn = opStack
            
            repeat{
                let (additionalDesc, additionalOps) = describe(opsReturn)
                descriptionReturn = descriptionReturn.isEmpty ? additionalDesc : additionalDesc+", "+descriptionReturn
                opsReturn = additionalOps
            } while !opsReturn.isEmpty
            
            return descriptionReturn
        }
    }
    
    
    fileprivate var opStack = [Op]()
    fileprivate var knownOps = [String:Op]()
    fileprivate var wantToChangeVariable = false
    fileprivate var variableValue = [String: Double?]()
    
    init()
    {
        knownOps["×"] = Op.binaryOperation("×", 3, *)
        knownOps["÷"] = Op.binaryOperation("÷", 2){$1 / $0}
        knownOps["−"] = Op.binaryOperation("−", 2){$1 - $0}
        knownOps["+"] = Op.binaryOperation("+", 3, +)
        
        knownOps["√"] = Op.unaryOperation("√", sqrt)
        knownOps["π"] = Op.unaryOperation("π"){_ in return pi}
        knownOps["sin"] = Op.unaryOperation("sin", sin)
        knownOps["cos"] = Op.unaryOperation("cos", cos)
    }
    
    private func describe(_ currentOps: [Op], currentOpPrecedence: Int = 0) -> (description: String, remainingOps: [Op]) {
        var currentOps = currentOps
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op  {
            case .operand:
                return (op.description, currentOps)
            case .symbols:
                return (op.description, currentOps)
            case .unaryOperation:
                let (operandDesc, remainingOps) = describe(currentOps)
                return ( op.description+"("+operandDesc+")", remainingOps)
            case .binaryOperation(_, let precedence, _):
                let (operandDesc1, remainingOps1) = describe(currentOps, currentOpPrecedence: precedence)
                let (operandDesc2, remainingOps2) = describe(remainingOps1, currentOpPrecedence: precedence)
                if precedence < currentOpPrecedence {
                    return ("("+operandDesc2+op.description+operandDesc1+")", remainingOps2)
                } else {
                    return (operandDesc2+op.description+operandDesc1, remainingOps2)
                }
            }
        }
        return ("?", currentOps)
    }
    
    fileprivate func evaluate (_ ops: [Op]) -> (result: Double?,remainingOps: [Op])
    {
        if !ops.isEmpty
        {
            var remainingOps = ops
            let op = remainingOps.removeLast()

            switch op
            {
                case .operand(let operand):


                    let operand = Double(operand!)
                    return (operand, remainingOps)
                    
                case .symbols(let symbol):
                    let operand = variableValue[symbol]
                    if operand == nil && evaluate(remainingOps).result != nil{
                        variableValue[symbol] = evaluate(remainingOps).result
                        return( variableValue[symbol]!, remainingOps)
                    }else if operand == nil && evaluate(remainingOps).result != nil{
                        return( nil, remainingOps)
                    }
                    return (operand!, remainingOps)
                
                case .unaryOperation(_, let operation):
                    let operandEvalute = evaluate(remainingOps)
                    if let operand = operandEvalute.result {
                        return(operation(operand), operandEvalute.remainingOps)
                    }
                case .binaryOperation(_, _, let operation):
                    let op1Evalution = evaluate(remainingOps)
                    if let operand1 = op1Evalution.result
                    {
                        let op2Evalution = evaluate(op1Evalution.remainingOps)
                        if let operand2 = op2Evalution.result{
                            return(operation(operand1, operand2), op2Evalution.remainingOps)
                        }
                    }
            }
         }
        return(nil, ops)
    }
    
    func reset(){
        opStack = [Op]()
    }
    
    func evaluate() -> Double?
    {
        let (result, _) = evaluate(opStack)
        return  result
    }
    
    func pushOperand(_ varName: String) -> Double?
    {
        opStack.append(Op.symbols(varName))
        return evaluate()
    }
    
    
    func pushOperand(_ operand: Double) -> Double?
    {
        opStack.append(Op.operand(operand))
        return evaluate()
    }
    
    func performOperation(_ symbol: String) -> Double?
    {
        if let operation = knownOps[symbol]
        {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func performDescription(_ symbol: String) -> Double?
    {
        if let operation = knownOps[symbol]
        {
            opStack.append(operation)
        }
        return evaluate()
    }

    
}
