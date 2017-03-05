//
//  ViewController.swift
//  Calculator
//
//  Created by John Benton on 4/22/15.
//  Copyright (c) 2015 John Benton. All rights reserved.
//

import UIKit
import Darwin

let pi = M_PI
fileprivate let varList = ["X", "Y", "M"]

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyDisplay: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var historyDataStarted = false
    var decimalCount = 0
    var brain = CalculatorBrain()
    
    @IBAction func clearData(_ sender: UIButton) {
        historyDataStarted = false
        decimalCount = 0
        displayValue = 0
        historyDisplay.text = "clear"
        brain.reset()
    }
    
    func refreshDisplayValues(){
        if brain.evaluate() != nil{
            historyDisplay.text = "\(brain.description) = \(brain.evaluate()!)"
            display.text = "\(brain.evaluate()!)"
        }else{
            historyDisplay.text = "\(brain.description)"
        }
    }
    
    @IBAction func setValueOfM(_ sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        if display.text != nil{
            let variableM = display.text!
            print(brain.setValueOfM(newValue: Double(variableM)!) ?? "uh oh, not a valid number")
            
            refreshDisplayValues()
        }else{
            displayValue = nil
        }
    }
    
    @IBAction func placeValueOfM(_ sender: UIButton) {
        let variableM = sender.currentTitle!
        brain.pushOperand(variableM)
        refreshDisplayValues()
        display.text = variableM
    }
    

    @IBAction func appendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber
        {
            display.text = display.text! + digit
        }
        else
        {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber{
            enter()
        }
        if let operation = sender.currentTitle{
            if let result = brain.performOperation(operation){
                displayValue = result
                historyDisplay.text = "\(brain.description) = \(result)"
            } else{
                historyDisplay.text = "\(brain.description)"
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        
        if displayValue != nil{
            if let result = brain.pushOperand(displayValue!)
            {
                displayValue = result
            }
        } else{
            displayValue = nil
        }
        
        historyDisplay.text = brain.description
    }
    
    var displayValue: Double? {
        get
        {
            if let displayNum = NumberFormatter().number(from: display.text!)
            {
                return displayNum.doubleValue
            }
            else
            {
                return nil
            }
        }
        set
        {
            if newValue != nil{
                display.text! = "\(newValue!)"
            }
            else
            {
                if display.text! == varList[0] || display.text! == varList[1] || display.text! == varList[2] {
                    let check = brain.pushOperand(display.text!)
                    print(check ?? "")
                }
                else{
                    display.text! = "Error invalid number"
                }
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
}

