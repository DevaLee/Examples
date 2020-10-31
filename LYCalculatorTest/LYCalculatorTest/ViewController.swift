//
//  ViewController.swift
//  LYCalculatorTest
//
//  Created by admin on 2020/10/31.
//

import UIKit
import LYKitDemo
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//    
        LYPerson.run()
        
        let num = Calculator.add(2, 1)
        
        print(num)
        
    
    }


}

