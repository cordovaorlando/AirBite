//
//  ViewController.swift
//  Donate
//
//  Created by Ziad TAMIM on 6/7/15.
//  Copyright (c) 2015 TAMIN LAB. All rights reserved.
//

import UIKit

class CustomPaymentViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expireDateTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    //@IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var itemName = String()
    var userEmail = String()
    var priceOfItemsInCart: [String] = []
    var receiptForm = String()

    
    @IBOutlet var textFields: [UITextField]!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // set up the total price
        var priceOfItems = Float()
        for pItem in priceOfItemsInCart {
            let price = (pItem as NSString).floatValue
            priceOfItems += price
        }
        let stringPriceItem = String(format: "%.2f", priceOfItems)
        //self.fruitPriceLabel.text = "Order Total: $\(stringPriceItem)"
        
        print(Int(priceOfItemsInCart[0]))
        amountTextField.text = "         Order Total: $\(stringPriceItem)"
        
        self.navigationItem.rightBarButtonItem?.title = (navigationItem.rightBarButtonItem?.title)! +  "  $" + stringPriceItem
        
    }

    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    
    
    // MARK: Actions
    
    @IBAction func donate(sender: AnyObject) {
        //print(itemPrice)
        
        // Initiate the card
        let stripCard = STPCard()
        
        // Split the expiration date to extract Month & Year
        if self.expireDateTextField.text!.isEmpty == false {
            let expirationDate = self.expireDateTextField.text!.componentsSeparatedByString("/")
            let expMonth = UInt(Int(expirationDate[0])!)
            let expYear = UInt(Int(expirationDate[1])!)
            
            // Send the card info to Strip to get the token
            stripCard.number = self.cardNumberTextField.text
            stripCard.cvc = self.cvcTextField.text
            stripCard.expMonth = expMonth
            stripCard.expYear = expYear
        }
        
        var underlyingError: NSError?
        do {
            try stripCard.validateCardReturningError()
        } catch let error as NSError {
            underlyingError = error
        }
        if underlyingError != nil {
            //self.spinner.stopAnimating()
            self.handleError(underlyingError!)
            return
        }
        
        STPAPIClient.sharedClient().createTokenWithCard(stripCard, completion: { (token, error) -> Void in
            
            if error != nil {
                self.handleError(error!)
                return
            }
            
            self.postStripeToken(token!)
        })
        
        navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    func handleError(error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again!!",
            message: error.localizedDescription,
            delegate: nil,
            cancelButtonTitle: "OK").show()
        
    }
    
    func postStripeToken(token: STPToken) {
        
        // set up the total price
        var priceOfItems = Float()
        for pItem in priceOfItemsInCart {
            let price = (pItem as NSString).floatValue
            priceOfItems += price
        }
        let stringPriceItem = String(format: "%.2f", priceOfItems)
        //self.fruitPriceLabel.text = "Order Total: $\(stringPriceItem)"
        
        
        
        
        
        let URL = "http://goairbite.com/donate/payment.php"
        let params : [String : AnyObject] = ["stripeToken": token.tokenId,
            "amount": stringPriceItem,
            //"amount": Int(stringPriceItem)!,
            "currency": "usd",
            "description": self.emailTextField.text!]
        userEmail = emailTextField.text!
        
        let manager = AFHTTPRequestOperationManager()
        manager.POST(URL, parameters: params, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                UIAlertView(title: response["status"],
                    message: response["message"],
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
                
                
                //Sends Emails after transaction Approved.
                let myUrl = NSURL(string: "https://api.mailgun.net/v3/sandboxcfe66167019a455aa52e6d456a203246.mailgun.org/messages");
                let request = NSMutableURLRequest(URL:myUrl!);
                //        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://api.mailgun.net/v3/sandboxcfe66167019a455aa52e6d456a203246.mailgun.org/messages")!)
                request.HTTPMethod = "POST"
                
                // Basic Authentication
                let username = "api"
                let password = "key-a64566a21584e816782a1a1e63ab91e7"
                let loginString = NSString(format: "%@:%@", username, password)
                let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
                let base64LoginString = loginData.base64EncodedStringWithOptions([])
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                
                
                
                
                let bodyStr = "from=AirBite <sales@goairbite.com>&to=Receiver name <"
                    + self.userEmail + ">&subject=We've received your order! Order # BBY01&text= Thanks for your order."
                
                // appending the data
                request.HTTPBody = bodyStr.dataUsingEncoding(NSUTF8StringEncoding);
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    // ... do other stuff here
                })
                
                task.resume()
                print("testing...")
                
                
                
            }
            
            }) { (operation, error) -> Void in
                self.handleError(error!)
        }
    }
    
    @IBAction func backButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}

