//
//  DescriptionViewController.swift
//  AirBite
//
//  Created by Jose Cordova on 2/21/16.
//  Copyright © 2016 Eren Corapcioglu. All rights reserved.
//

import UIKit

protocol AddToCartDelegate
{
    func addToCartResponse(addToCartArrayParam: [String], addPriceToCartArrayPram: [String])
}

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var descriptionString = String()
    var foodDescription: [String] = []
    var itemName = String()
    var itemPrice = String()
    var restaurantsName = String()
    
    var delegate: AddToCartDelegate?
    
    
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    var addToCartArray = [String]()
    var addPriceToCart = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToCartButton.addTarget(self, action: "addToCart", forControlEvents: .TouchUpInside)
        
        descriptionTextView.text = itemName + "\r\n" + "\r\n" + descriptionString + "\r\n \r\nPrice: " + itemPrice
    }
    
    func addToCart() {
        
        addToCartArray.append(itemName)
        addPriceToCart.append(itemPrice)
        
        self.delegate?.addToCartResponse(addToCartArray, addPriceToCartArrayPram: addPriceToCart)
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    
        if (segue.identifier == "paymentSegue") {
            let svc = segue.destinationViewController as! PaymentViewController
            
            svc.itemName = itemName
            svc.itemPrice = itemPrice
            
        }
        if (segue.identifier == "customPaymentSegue") {
            let svc2 = segue.destinationViewController as! CustomPaymentViewController
            
            svc2.itemName = itemName
            
        }
    }
}