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
    
    var taxOfFood = String()
    var convenienceFee = String()
    
    var subtotal = Float()
    var stringSubtotal = String()
    
    var emailBody = String()
    var emailHeader = String()
    var restaurantsName = String()
    var restaurantBody = String()
    var stringPriceItem = String()
    var stringTaxOfFood = String()
    var stringConvenienceFee = String()
    
    var convenienceFee2 = Float()
    var taxOfFood2 = Float()
    
    var priceOfItems = Float()
    
    
    var itemsInCart: [String] = []

    //hold date data for the emails sent
    var currentDate = NSDate()
    let dateFormatter = NSDateFormatter()
    var convertedDate = String()
    
    @IBOutlet var textFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var obj = PaymentViewController()
        
        // set up the total price
        var priceOfItems = Float()
        for pItem in priceOfItemsInCart {
            let price = (pItem as NSString).floatValue
            priceOfItems += price
        }
        //let stringPriceItem = String(format: "%.2f", priceOfItems)
        //self.fruitPriceLabel.text = "Order Total: $\(stringPriceItem)"
        
        let priceSummary = Float(convenienceFee)! + Float(taxOfFood)! + priceOfItems
        let stringPriceItem = String(format: "%.2f", priceSummary)

        
        print(Int(priceOfItemsInCart[0]))
        amountTextField.text = "         Order Total: $\(priceSummary)"
        
        self.navigationItem.rightBarButtonItem?.title = (navigationItem.rightBarButtonItem?.title)! +  "  $" + stringPriceItem
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        convertedDate = dateFormatter.stringFromDate(currentDate)
        convertedDate = dateFormatter.stringFromDate(currentDate)
        
        
        
        var rowData = String()
        for var index = 0; index < itemsInCart.count; ++index{
            
            rowData = "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" valign=\"top\">" + itemsInCart[index] + "</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + priceOfItemsInCart[index] + "</td></tr>" + rowData
        }
        
        
        emailBody = "&html=<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" style=\"font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; box-sizing: border-box;font-size: 14px; margin: 0;\"><head><meta name=\"viewport\" content=\"width=device-width\" /><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><title>Billing e.g. invoices and receipts</title><style type=\"text/css\">img {max-width: 100%;}body {-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6em;}body {background-color: #f6f6f6;}@media only screen and (max-width: 640px) {body {padding: 0 !important;}h1 {font-weight: 800 !important; margin: 20px 0 5px !important;}h2 {font-weight: 800 !important; margin: 20px 0 5px !important;}h3 {font-weight: 800 !important; margin: 20px 0 5px !important;}h4 {font-weight: 800 !important; margin: 20px 0 5px !important;}h1 {font-size: 22px !important;}h2 {font-size: 18px !important;}h3 {font-size: 16px !important;}.container {padding: 0 !important; width: 100% !important;}.content {padding: 0 !important;}.content-wrap {padding: 10px !important;}.invoice {width: 100% !important;}}</style></head><body itemscope itemtype=\"http://schema.org/EmailMessage\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing:border-box; font-size: 14px; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%;line-height: 1.6em; background-color: #f6f6f6; margin: 0;\" bgcolor=\"#f6f6f6\"><table class=\"body-wrap\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; background-color: #f6f6f6; margin: 0;\" bgcolor=\"#f6f6f6\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;\" valign=\"top\"></td><td class=\"container\" width=\"600\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; display: block !important; max-width: 600px !important; clear: both !important; margin: 0 auto;\" valign=\"top\"><div class=\"content\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; max-width: 600px; display: block; margin: 0 auto; padding: 20px;\"><table class=\"main\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; border-radius: 3px; background-color: #fff; margin: 0; border: 1px solid #e9e9e9;\" bgcolor=\"#fff\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-wrap aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 20px;\" align=\"center\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;\" valign=\"top\"><h1 class=\"aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,'Lucida Grande',sans-serif; box-sizing: border-box; font-size: 32px; color: #000; line-height: 1.2em; font-weight: 500; text-align: center; margin: 40px 0 0;\" align=\"center\">$" + self.stringPriceItem + " Paid</h1></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;\" valign=\"top\"><h2 class=\"aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,'Lucida Grande',sans-serif; box-sizing: border-box; font-size: 24px; color: #000; line-height: 1.2em; font-weight: 400; text-align: center; margin: 40px 0 0;\" align=\"center\">Thanks for using AirBite Inc.</h2></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\"><table class=\"invoice\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; text-align: left; width: 80%; margin: 40px auto;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 5px 0;\" valign=\"top\">" + self.restaurantsName + "<br style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\" />Invoice #12345<br style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\" />" + convertedDate + "</td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 5px 0;\" valign=\"top\"><table class=\"invoice-items\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; margin: 0;\">" + rowData +
            
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Subtotal</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + stringSubtotal + "</td></tr>" +
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Tax</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringTaxOfFood + "</td></tr>" +
            
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Fee</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringConvenienceFee + "</td></tr>" +
            
            
            
            
            "<tr class=\"total\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"alignright\" width=\"80%\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 2px; border-top-color: #333; border-top-style: solid; border-bottom-color: #333; border-bottom-width: 2px; border-bottom-style: solid; font-weight: 700; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Total</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 2px; border-top-color: #333; border-top-style: solid; border-bottom-color: #333; border-bottom-width: 2px; border-bottom-style: solid; font-weight: 700; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringPriceItem + "</td></tr>" +
            
            
        "</table></td></tr></table></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\"><a href=\"http://www.goairbite.com\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; color: #348eda; text-decoration: underline; margin: 0;\">View in browser</a></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\">AirBite Inc. 1 University Pl, Shreveport, LA 71115</td></tr></table></td></tr></table><div class=\"footer\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; clear: both; color: #999; margin: 0; padding: 20px;\"><table width=\"100%\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"aligncenter content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; vertical-align: top; color: #999; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\">Questions? Email <a href=\"mailto:\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; color: #999; text-decoration: underline; margin: 0;\">support@goairbite.com</a></td></tr></table></div></div></td><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;\" valign=\"top\"></td></tr></table></body></html>"
        
        
        subtotal = (priceOfItems - (taxOfFood2 + convenienceFee2))
        stringSubtotal = convertFloatToString(subtotal)

        
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
                

                self.sendRestaurantEmail()
                self.sendCustomerEmail()
                
                
                
            }
            
            }) { (operation, error) -> Void in
                self.handleError(error!)
        }
    }
    
    @IBAction func backButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /// converts the passed in float to a string with two precceding decimals.
    func convertFloatToString(floatToConvert: Float) -> String{
        return String(format: "%.2f", floatToConvert)
    }
    
    func sendCustomerEmail(){
        
        
        //email header
        emailHeader = "from=AirBite <sales@goairbite.com>&to=John Doe <" + userEmail + ">&subject=We've received your order! Order #12345"
        
        
        //Sends Emails after transaction Approved.
        let myUrl = NSURL(string: "https://api.mailgun.net/v3/sandboxcfe66167019a455aa52e6d456a203246.mailgun.org/messages");
        let requestEmail = NSMutableURLRequest(URL:myUrl!);
        //        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://api.mailgun.net/v3/sandboxcfe66167019a455aa52e6d456a203246.mailgun.org/messages")!)
        requestEmail.HTTPMethod = "POST"
        
        // Basic Authentication
        let username = "api"
        let password = "key-a64566a21584e816782a1a1e63ab91e7"
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
        requestEmail.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        // appending the data
        requestEmail.HTTPBody = (self.emailHeader + self.emailBody).dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestEmail, completionHandler: { (data, response, error) -> Void in
            // ... do other stuff here
        })
        
        task.resume()
        print("testing...")
        
    }
    
    func sendRestaurantEmail(){
        
        var restaurantEmailHeader = "from=AirBite <sales@goairbite.com>&to=" + self.restaurantsName  + "<restaurant@goairbite.com>&subject=Order #12345"
        
        
        //Sends Emails after transaction Approved.
        let myUrl = NSURL(string: "https://api.mailgun.net/v3/sandboxcfe66167019a455aa52e6d456a203246.mailgun.org/messages");
        let requestEmail = NSMutableURLRequest(URL:myUrl!);
        //        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://api.mailgun.net/v3/sandboxcfe66167019a455aa52e6d456a203246.mailgun.org/messages")!)
        requestEmail.HTTPMethod = "POST"
        
        // Basic Authentication
        let username = "api"
        let password = "key-a64566a21584e816782a1a1e63ab91e7"
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
        requestEmail.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        // appending the data
        requestEmail.HTTPBody = (restaurantEmailHeader + self.emailBody).dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestEmail, completionHandler: { (data, response, error) -> Void in
            // ... do other stuff here
        })
        
        task.resume()
        print("testing...")
    }
    
}

