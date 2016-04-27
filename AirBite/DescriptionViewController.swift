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
    func addToCartResponse(addToCartArrayParam: [String], addPriceToCartArrayPram: [String], addSpecialRequestArrayParam: [String])
}

class DescriptionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var descriptionString = String()
    var foodDescription: [String] = []
    var itemName = String()
    var itemPrice = String()
    var restaurantsName = String()
    
    var delegate: AddToCartDelegate?
    
    @IBOutlet weak var specialRequest: UITextView!
    
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    var addToCartArray = [String]()
    var addPriceToCart = [String]()
    
    var specialRequestArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.specialRequest.delegate = self;
        addToCartButton.addTarget(self, action: "addToCart", forControlEvents: .TouchUpInside)
        
        descriptionTextView.text = itemName + "\r\n" + "\r\n" + descriptionString + "\r\n \r\nPrice: " + itemPrice
        
        descriptionTextView.font = UIFont(name: "Georgia", size: 14.0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        let mainScreenSize : CGSize = UIScreen.mainScreen().bounds.size // Getting main screen size of iPhone
        
        let imageObbj:UIImage! =   self.imageResize(UIImage(named: "PlainBackground.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))
        
        self.view.backgroundColor = UIColor(patternImage:imageObbj)
        
        addToCartButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    //Dismisses the keyboard
    func textViewShouldEndEditing(textField: UITextView) -> Bool {
        specialRequest.resignFirstResponder()
        return true
    }
    
    //Dismisses the keyboard 
    func textViewShouldReturn(textField: UITextView) -> Bool {
        self.view.endEditing(true)
        //specialRequest.resignFirstResponder()
        return false
    }

    
    //Dismisses the keyboard
    func dismissKeyboard(){
        self.specialRequest.resignFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            specialRequest.resignFirstResponder()
            return false
        }
        return true
    }
    
    func addSpecialRequest(){
        for var index = 0; index < specialRequestArray.count; ++index{
            specialRequestArray[index] = specialRequest.text
        }
    }
    
    func addToCart() {
        
        addToCartArray.append(itemName)
        addPriceToCart.append(itemPrice)
        specialRequestArray.append(specialRequest.text)
        
        self.delegate?.addToCartResponse(addToCartArray, addPriceToCartArrayPram: addPriceToCart, addSpecialRequestArrayParam: specialRequestArray)
        
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