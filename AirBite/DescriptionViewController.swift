//
//  DescriptionViewController.swift
//  AirBite
//
//  Created by Jose Cordova on 2/21/16.
//  Copyright © 2016 Eren Corapcioglu. All rights reserved.
//

import UIKit


class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var descriptionString = String()
    var foodDescription: [String] = []
    var itemName = String()
    var itemPrice = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = descriptionString + "\r\n \r\nPrice: " + itemPrice
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "paymentSegue") {
            let svc = segue.destinationViewController as! PaymentViewController
            
            svc.itemName = itemName
            svc.itemPrice = itemPrice
            //svc.menuItemPricesForPayment = priceItem
            //svc.menuItemPrices = menuItemPrice
            
        }
        if (segue.identifier == "customPaymentSegue") {
            let svc2 = segue.destinationViewController as! CustomPaymentViewController
            
            svc2.itemName = itemName
            svc2.itemPrice = itemPrice
            //svc.menuItemPricesForPayment = priceItem
            //svc.menuItemPrices = menuItemPrice
            
        }
        
        
    }
    
    
    
    
}