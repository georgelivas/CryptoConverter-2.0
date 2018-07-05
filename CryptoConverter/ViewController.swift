//
//  ViewController.swift
//  CryptoConverter
//
//  Created by George Livas on 05/07/2018.
//  Copyright © 2018 George Livas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var currencyInput: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyImg: UIImageView!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var btcPriceLabel: UILabel!
    
    @IBOutlet weak var currencySelector: UISegmentedControl!
    
    
    let urlString = URL(string: "https://api.cryptonator.com/api/ticker/btc-usd")
    var oldPrice: Double = 0.0
    var btcPrice: Double? = nil
    
    func makeGetCallWithAlamofire() {
        let todoEndpoint: String = "https://api.cryptonator.com/api/ticker/btc-usd"
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                guard response.result.error == nil else {
                    print("error calling GET")
                    print(response.result.error!)
                    return
                }

                guard let json = response.result.value! as? [String: Any] else {
                    print("didn't get price object as JSON from API")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    return
                }
                self.btcPrice = Double(JSON(json)["ticker"]["price"].string!)!
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updatePrice()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let rates : [String: Double] = [
        "usd": 0.00015,
        "eur": 0.00017,
        "gbp": 0.00020
    ]
    
    var currency = "usd"
    
    func calculate() {
        guard let billAmountText = self.currencyInput.text,
            let billAmount = Double(billAmountText) else {
                return
        }
        let rate = rates[currency]
        
        outputLabel.text = String(billAmount * rate!)
    }
    
    @IBAction func changeAmount(_ sender: UITextField) {
        calculate()
    }
    
    func updatePrice() {
        makeGetCallWithAlamofire()
        if btcPrice != nil {
            oldPrice = btcPrice!
            
            makeGetCallWithAlamofire()
            btcPrice != nil ? btcPriceLabel.text = String(btcPrice!) : print("loading...")
            if btcPrice! >= oldPrice {
                btcPriceLabel.textColor = UIColor.green
            }  else {
                btcPriceLabel.textColor = UIColor.red
            }
        }
    }
    @IBAction func currencyChanged(_ sender: UISegmentedControl) {
        
        switch currencySelector.selectedSegmentIndex {
        case 0:
            currency = "usd"
            currencyLabel.text = "USD"
            currencyInput.placeholder = "$0.00"
            currencyImg.image = UIImage(named: "usd")
            
            calculate()
        case 1:
            currency = "eur"
            currencyLabel.text = "EUR"
            currencyInput.placeholder = "€0.00"
            currencyImg.image = UIImage(named: "eur")
            updatePrice()
            calculate()
        case 2:
            currency = "gbp"
            currencyLabel.text = "GBP"
            currencyInput.placeholder = "£0.00"
            currencyImg.image = UIImage(named: "gbp")
            
            calculate()
        default:
            currency = "usd"
            currencyLabel.text = "USD"
            currencyInput.placeholder = "$0.00"
            currencyImg.image = UIImage(named: "usd")
            
            calculate()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        updatePrice()
    }
}
