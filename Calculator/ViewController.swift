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
        
        if historyDataStarted
        {
            historyDisplay.text =  historyDisplay.text! + ", " + sender.currentTitle!
        }
        else
        {
            historyDisplay.text = sender.currentTitle!
            historyDataStarted = true
        }
        
        if userIsInTheMiddleOfTypingANumber{
            enter()
        }
        if let operation = sender.currentTitle{
            if let result = brain.performOperation(operation){
               displayValue = result
            } else{
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        decimalCount = 0
        
        if historyDataStarted
        {
         historyDisplay.text =  historyDisplay.text! + ", " + display.text!
        }
        else
        {
            historyDisplay.text = display.text!
            historyDataStarted = true
        }
        if displayValue != nil{
            if let result = brain.pushOperand(displayValue!)
            {
                displayValue = result
            }
        } else{
            displayValue = nil
        }

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
                if display.text! == "X" || display.text! == "Y" {
                    brain.pushOperand(display.text!)
                }
                else{
                    display.text! = "Error invalid number"
                }
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
}

