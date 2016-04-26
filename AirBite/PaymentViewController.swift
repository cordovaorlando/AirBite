//
//  PaymentViewController.swift
//  AirBite
//
//  Created by Jose Cordova on 2/21/16.
//  Copyright © 2016 Eren Corapcioglu. All rights reserved.
//

import UIKit
import PassKit

extension PaymentViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    //Delegate function for when the user finishes authorizing the purchase
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        completion(PKPaymentAuthorizationStatus.Success)
        
        Stripe.setDefaultPublishableKey("pk_test_Nxy4IoZXCoOVppUkWdFH7eOv")  // test key
        
        STPAPIClient.sharedClient().createTokenWithPayment(payment) {
            (token, error) -> Void in
            
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            self.sendCustomerEmail()
            self.sendRestaurantEmail()
            
            
            
            
            if (error != nil) {
                print(error)
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            
            //let url = NSURL(string: "http://10.0.0.4:5000/pay")     // Local Server Address
            let url = NSURL(string: "http://73.183.220.171:5000/pay") //Remote Server Address
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            
            let body = ["stripeToken": token!.tokenId,
                "amount": 200.00,
                "description": "Sample Title"
            ]
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
            } catch let error as NSError {
                print("An error occurred: \(error)")
            }
            
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                if (error != nil) {
                    completion(PKPaymentAuthorizationStatus.Failure)
                } else {
                    completion(PKPaymentAuthorizationStatus.Success)
                }
            }
        }
    }
    
    //Delegate function for when the animations have all finished in the PKPaymentAuthorizationViewController
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol RemoveFromCartDelegate
{
    func removeFromCartResponse(removeFromCartArrayParam: [String], removePriceFromCartArrayPram: [String])
}

class PaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var fruitImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var fruitPriceLabel: UILabel!
    @IBOutlet var tableViewSummary: UITableView!

    var itemName = String()
    var itemPrice = String()
    var restaurantsName = String()
    var totalPrice = String()
    
    var itemsInCart: [String] = []
    var priceOfItemsInCart: [String] = []
    var specialRequests: [String] = []
    var intPriceItem = NSDecimalNumber()
    
    var priceOfItems = Float()
    var stringPriceItem = String()
    var stringConvenienceFee = String()
    var stringTaxOfFood = String()
    
    var convenienceFee = Float()
    var taxOfFood = Float()
    
    var delegate: RemoveFromCartDelegate?
    
    
    //variables for the emails header and body
    var emailBody = String()
    var emailHeader = String()
    
    //hold date data for the emails sent
    var currentDate = NSDate()
    let dateFormatter = NSDateFormatter()
    var convertedDate = String()
    
    var flightNumberText = String()
    var airlineFieldText = String()
    var foodOption = String()
    
    var replaced: [String] = []
    
    
    //Cards supported by ApplePay
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePayFruitsMerchantID = "merchant.com.LSUS.AirBite" // Merchant ID

    func configureView() {
        
        if (!self.isViewLoaded()) {
            return
        }
        self.title = restaurantsName
        
        
        // set up the total price
        for pItem in priceOfItemsInCart {
            let price = (pItem as NSString).floatValue
            priceOfItems += price
        }
        self.fruitPriceLabel.numberOfLines = 0
        
        convenienceFee = Float(2.00)
        taxOfFood = priceOfItems * Float(0.07)
        
        priceOfItems += convenienceFee
        priceOfItems += taxOfFood
        
        intPriceItem = NSDecimalNumber(float: priceOfItems)
        
        stringPriceItem = convertFloatToString(priceOfItems)
        stringConvenienceFee = convertFloatToString(convenienceFee)
        stringTaxOfFood = convertFloatToString(taxOfFood)
        
        print(specialRequests)

        self.fruitPriceLabel.text = "Convenience Fee: $\(stringConvenienceFee) \r\nTax: $\(stringTaxOfFood) \r\nOrder Total: $\(stringPriceItem)"
        
        self.fruitPriceLabel.font = UIFont(name: "Georgia", size: 18.0)
        
        totalPrice = stringPriceItem
        
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        convertedDate = dateFormatter.stringFromDate(currentDate)
        convertedDate = dateFormatter.stringFromDate(currentDate)
        //print(convertedDate)
        
    }
    
    /// converts the passed in float to a string with two precceding decimals.
    func convertFloatToString(floatToConvert: Float) -> String{
        return String(format: "%.2f", floatToConvert)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
       // print(itemsInCart)
        
        //print(specialRequests)
        
        
        //let str = "Swift 1.2 is the best version of Swift to learn, so if you're starting fresh you should definitely learn Swift 1.2."
        //let replaced = str.stringByReplacingOccurrencesOfString("1.2", withString: "2.0")
        
        
        for var index = 0; index < itemsInCart.count; ++index{
            replaced.append(itemsInCart[index].stringByReplacingOccurrencesOfString("&", withString: "and"))
        }
        
        print(replaced)
        
        
        print("flightNumber: " + flightNumberText)
        print("airlineName: " + airlineFieldText)
        // these next three lines of codes overrides the designed back button, and lets it be custom in order to update the cart when hitting the back button.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Add Food", style: UIBarButtonItemStyle.Bordered, target: self, action: "updateCart:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        
        // register the table view created since it's not a table view controller, just a table view inside the view controller.
        self.tableViewSummary.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableViewSummary.backgroundColor = UIColor(red: 135, green: 223, blue: 238, alpha: 0)
        
        let mainScreenSize : CGSize = UIScreen.mainScreen().bounds.size // Getting main screen size of iPhone
        
//        let imageObbj:UIImage! =   self.imageResize(UIImage(named: "BottomLogoNoClouds.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))
        
        let imageObbj:UIImage! =   self.imageResize(UIImage(named: "PlainBackground.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))
        
        self.view.backgroundColor = UIColor(patternImage:imageObbj)
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    /// returns the number of rows in the table view cell based on the number of items in the cart.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsInCart.count;
    }

    /// Populate the table view cells in the table view to have the each item and price listed in the cart.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableViewSummary.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        // set up the special request string to add to the summary of items in each cell.
        var specialRequestString = ""
        
        // only want to add a new line with special requests if there are special requests to add.
        if (specialRequests[indexPath.row] != "") {
            specialRequestString = "\r\n - \(specialRequests[indexPath.row])"
        }
        
        // we want to set the number of lines to 0 so that we can have multiple lines of text in the table cells.
        cell.textLabel?.numberOfLines = 0
        
        cell.textLabel?.text = self.itemsInCart[indexPath.row] + ": $" + self.priceOfItemsInCart[indexPath.row] + specialRequestString
        
        cell.textLabel?.font = UIFont(name: "Georgia", size: 17.0)
        
        cell.backgroundColor = UIColor(red: 135, green: 223, blue: 238, alpha: 0)
        //cell.textLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    // function to update the total price after an item has been removed from the cart.
    func updatePrice(priceToUpdate: Float) -> String {
        
        // remove all the previous prices. We are removing the priceToUpdate item, so we need to remove previous tax and conveience fee.
        priceOfItems -= priceToUpdate
        priceOfItems -= convenienceFee
        priceOfItems = priceOfItems - round(100.0 * taxOfFood) / 100.0//taxOfFood

        if (priceOfItems <= 0) {
            convenienceFee = 0
            taxOfFood = 0
            stringConvenienceFee = "0.00"
            stringTaxOfFood = "0.00"
            return "0.00"
        }
        
        // create new tax of food.
        let newTaxOfFood = priceOfItems * Float(0.07)
        
        // re add convenienceFee and newTaxOfFood to get new total
        priceOfItems += convenienceFee
        priceOfItems += newTaxOfFood

        stringTaxOfFood = convertFloatToString(newTaxOfFood)
        taxOfFood = newTaxOfFood
        
        return convertFloatToString(priceOfItems)
    }
    
    /// Create the swipe to delete functionality for the table view contaning the food items.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let priceToUpdate = Float(priceOfItemsInCart[indexPath.row])
            
            stringPriceItem = updatePrice(priceToUpdate!)
            
            self.fruitPriceLabel.text = "Convenience Fee: $\(stringConvenienceFee) \r\nTax: $\(stringTaxOfFood) \r\nOrder Total: $\(stringPriceItem)"
            
            intPriceItem = NSDecimalNumber(float: priceOfItems)
            
            itemsInCart.removeAtIndex(indexPath.row)
            priceOfItemsInCart.removeAtIndex(indexPath.row)
            tableViewSummary.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    /// this function updates the cart if necessary (i.e. items have been removed) when the back/Add Food button has been pressed before going back to the menu page.
    func updateCart(sender: UIBarButtonItem) {
        self.delegate?.removeFromCartResponse(itemsInCart, removePriceFromCartArrayPram: priceOfItemsInCart)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// set up the ability to edit each row in the table view cell.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    func sendCustomerEmail(){
        
        //variables that hold the subtotal data
        var subtotal = Float()
        var stringSubtotal = String()
        
        //creating a subtotal based on the current values. Basically subtracting the tax and convenience fee from the total price.
        subtotal = (priceOfItems - (taxOfFood + convenienceFee))
        stringSubtotal = convertFloatToString(subtotal)
        
        
        var rowData = String()
        for var index = 0; index < itemsInCart.count; ++index{
            
            rowData = "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" valign=\"top\">" + replaced[index] + "</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + priceOfItemsInCart[index] + "</td></tr>" + rowData
        }
        
        //email header
        emailHeader = "from=AirBite <sales@goairbite.com>&to=John Doe <somecustomer@goairbite.com>&subject=We've received your order! Order #12345&text= Thanks for your order!"
        
        //email body
        emailBody = "&html=<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" style=\"font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; box-sizing: border-box;font-size: 14px; margin: 0;\"><head><meta name=\"viewport\" content=\"width=device-width\" /><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><title>Billing e.g. invoices and receipts</title><style type=\"text/css\">img {max-width: 100%;}body {-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6em;}body {background-color: #f6f6f6;}@media only screen and (max-width: 640px) {body {padding: 0 !important;}h1 {font-weight: 800 !important; margin: 20px 0 5px !important;}h2 {font-weight: 800 !important; margin: 20px 0 5px !important;}h3 {font-weight: 800 !important; margin: 20px 0 5px !important;}h4 {font-weight: 800 !important; margin: 20px 0 5px !important;}h1 {font-size: 22px !important;}h2 {font-size: 18px !important;}h3 {font-size: 16px !important;}.container {padding: 0 !important; width: 100% !important;}.content {padding: 0 !important;}.content-wrap {padding: 10px !important;}.invoice {width: 100% !important;}}</style></head><body itemscope itemtype=\"http://schema.org/EmailMessage\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing:border-box; font-size: 14px; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%;line-height: 1.6em; background-color: #f6f6f6; margin: 0;\" bgcolor=\"#f6f6f6\"><table class=\"body-wrap\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; background-color: #f6f6f6; margin: 0;\" bgcolor=\"#f6f6f6\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;\" valign=\"top\"></td><td class=\"container\" width=\"600\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; display: block !important; max-width: 600px !important; clear: both !important; margin: 0 auto;\" valign=\"top\"><div class=\"content\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; max-width: 600px; display: block; margin: 0 auto; padding: 20px;\"><table class=\"main\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; border-radius: 3px; background-color: #fff; margin: 0; border: 1px solid #e9e9e9;\" bgcolor=\"#fff\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-wrap aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 20px;\" align=\"center\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;\" valign=\"top\"><h1 class=\"aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,'Lucida Grande',sans-serif; box-sizing: border-box; font-size: 32px; color: #000; line-height: 1.2em; font-weight: 500; text-align: center; margin: 40px 0 0;\" align=\"center\">$" + self.stringPriceItem + " Paid</h1></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;\" valign=\"top\"><h2 class=\"aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,'Lucida Grande',sans-serif; box-sizing: border-box; font-size: 24px; color: #000; line-height: 1.2em; font-weight: 400; text-align: center; margin: 40px 0 0;\" align=\"center\">Thanks for using AirBite Inc.</h2></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\"><table class=\"invoice\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; text-align: left; width: 80%; margin: 40px auto;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 5px 0;\" valign=\"top\">" + self.restaurantsName + "<br style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\" />Invoice #12345<br style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\" />" + convertedDate + "</td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 5px 0;\" valign=\"top\"><table class=\"invoice-items\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; margin: 0;\">" + rowData +
            
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Subtotal</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + stringSubtotal + "</td></tr>" +
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Tax</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringTaxOfFood + "</td></tr>" +
            
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Fee</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringConvenienceFee + "</td></tr>" +
            
            
            
            
            "<tr class=\"total\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"alignright\" width=\"80%\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 2px; border-top-color: #333; border-top-style: solid; border-bottom-color: #333; border-bottom-width: 2px; border-bottom-style: solid; font-weight: 700; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Total</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 2px; border-top-color: #333; border-top-style: solid; border-bottom-color: #333; border-bottom-width: 2px; border-bottom-style: solid; font-weight: 700; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringPriceItem + "</td></tr>" +
            
            
        "</table></td></tr></table></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\"><a href=\"http://www.goairbite.com\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; color: #348eda; text-decoration: underline; margin: 0;\">View in browser</a></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\">AirBite Inc. 1 University Pl, Shreveport, LA 71115</td></tr></table></td></tr></table><div class=\"footer\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; clear: both; color: #999; margin: 0; padding: 20px;\"><table width=\"100%\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"aligncenter content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; vertical-align: top; color: #999; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\">Questions? Email <a href=\"mailto:\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; color: #999; text-decoration: underline; margin: 0;\">support@goairbite.com</a></td></tr></table></div></div></td><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;\" valign=\"top\"></td></tr></table></body></html>"
        
        
        
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
        
        
        //variables that hold the subtotal data
        var subtotal = Float()
        var stringSubtotal = String()
        
        //creating a subtotal based on the current values. Basically subtracting the tax and convenience fee from the total price.
        subtotal = (priceOfItems - (taxOfFood + convenienceFee))
        stringSubtotal = convertFloatToString(subtotal)
        
        
        var rowData = String()
        for var index = 0; index < itemsInCart.count; ++index{
            
            rowData = "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" valign=\"top\">" + replaced[index] + "<br>" + specialRequests[index] + "</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + priceOfItemsInCart[index] + "</td></tr>" + rowData
        }

        
        
        
        var restaurantEmailHeader = "from=AirBite <sales@goairbite.com>&to=" + self.restaurantsName  + "<restaurant@goairbite.com>&subject=You have a new " + foodOption + "! Order #12345&text=Please see the details below!"
        
        
        
        //email body
        var restaurantEmailBody = "&html=<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" style=\"font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; box-sizing: border-box;font-size: 14px; margin: 0;\"><head><meta name=\"viewport\" content=\"width=device-width\" /><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><title>Billing e.g. invoices and receipts</title><style type=\"text/css\">img {max-width: 100%;}body {-webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%; line-height: 1.6em;}body {background-color: #f6f6f6;}@media only screen and (max-width: 640px) {body {padding: 0 !important;}h1 {font-weight: 800 !important; margin: 20px 0 5px !important;}h2 {font-weight: 800 !important; margin: 20px 0 5px !important;}h3 {font-weight: 800 !important; margin: 20px 0 5px !important;}h4 {font-weight: 800 !important; margin: 20px 0 5px !important;}h1 {font-size: 22px !important;}h2 {font-size: 18px !important;}h3 {font-size: 16px !important;}.container {padding: 0 !important; width: 100% !important;}.content {padding: 0 !important;}.content-wrap {padding: 10px !important;}.invoice {width: 100% !important;}}</style></head><body itemscope itemtype=\"http://schema.org/EmailMessage\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing:border-box; font-size: 14px; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: none; width: 100% !important; height: 100%;line-height: 1.6em; background-color: #f6f6f6; margin: 0;\" bgcolor=\"#f6f6f6\"><table class=\"body-wrap\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; background-color: #f6f6f6; margin: 0;\" bgcolor=\"#f6f6f6\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;\" valign=\"top\"></td><td class=\"container\" width=\"600\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; display: block !important; max-width: 600px !important; clear: both !important; margin: 0 auto;\" valign=\"top\"><div class=\"content\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; max-width: 600px; display: block; margin: 0 auto; padding: 20px;\"><table class=\"main\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; border-radius: 3px; background-color: #fff; margin: 0; border: 1px solid #e9e9e9;\" bgcolor=\"#fff\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-wrap aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 20px;\" align=\"center\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;\" valign=\"top\"><h1 class=\"aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,'Lucida Grande',sans-serif; box-sizing: border-box; font-size: 32px; color: #000; line-height: 1.2em; font-weight: 500; text-align: center; margin: 40px 0 0;\" align=\"center\">$" + self.stringPriceItem + " Paid<br><br>" + foodOption + "</h1></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 0 0 20px;\" valign=\"top\"><h2 class=\"aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,'Lucida Grande',sans-serif; box-sizing: border-box; font-size: 24px; color: #000; line-height: 1.2em; font-weight: 400; text-align: center; margin: 40px 0 0;\" align=\"center\">Thanks for using AirBite Inc.</h2></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\"><table class=\"invoice\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; text-align: left; width: 80%; margin: 40px auto;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 5px 0;\" valign=\"top\">" + self.restaurantsName + "<br style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\" />Invoice #12345<br style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\" />" + convertedDate + "</td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0; padding: 5px 0;\" valign=\"top\"><table class=\"invoice-items\" cellpadding=\"0\" cellspacing=\"0\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; margin: 0;\">" + rowData +
            
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Subtotal</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + stringSubtotal + "</td></tr>" +
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Tax</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringTaxOfFood + "</td></tr>" +
            
            
            "<tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Fee</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 1px; border-top-color: #eee; border-top-style: solid; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringConvenienceFee + "</td></tr>" +
            
            
            
            
            "<tr class=\"total\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"alignright\" width=\"80%\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 2px; border-top-color: #333; border-top-style: solid; border-bottom-color: #333; border-bottom-width: 2px; border-bottom-style: solid; font-weight: 700; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">Total</td><td class=\"alignright\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: right; border-top-width: 2px; border-top-color: #333; border-top-style: solid; border-bottom-color: #333; border-bottom-width: 2px; border-bottom-style: solid; font-weight: 700; margin: 0; padding: 5px 0;\" align=\"right\" valign=\"top\">$ " + self.stringPriceItem + "</td></tr>" +
            
            
        "</table></td></tr></table><h2>Delivery Instructions:</h2><p>" + "Airline Name: " + airlineFieldText + "<br>" + "Flight Number: " + flightNumberText + "</p></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\"><a href=\"http://www.goairbite.com\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; color: #348eda; text-decoration: underline; margin: 0;\">View in browser</a></td></tr><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"content-block aligncenter\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\">AirBite Inc. 1 University Pl, Shreveport, LA 71115</td></tr></table></td></tr></table><div class=\"footer\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; width: 100%; clear: both; color: #999; margin: 0; padding: 20px;\"><table width=\"100%\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><tr style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; margin: 0;\"><td class=\"aligncenter content-block\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; vertical-align: top; color: #999; text-align: center; margin: 0; padding: 0 0 20px;\" align=\"center\" valign=\"top\">Questions? Email <a href=\"mailto:\" style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 12px; color: #999; text-decoration: underline; margin: 0;\">support@goairbite.com</a></td></tr></table></div></div></td><td style=\"font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif; box-sizing: border-box; font-size: 14px; vertical-align: top; margin: 0;\" valign=\"top\"></td></tr></table></body></html>"
        
        
        
        
        
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
        requestEmail.HTTPBody = (restaurantEmailHeader + restaurantEmailBody).dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestEmail, completionHandler: { (data, response, error) -> Void in
            // ... do other stuff here
        })
        
        task.resume()
        print("testing...")
        
    }
    
    
    @IBAction func applePayPayment(sender: UIButton) {
        
        //Build the request
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayFruitsMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        //Create the summaryItems array
        var summaryItems = [PKPaymentSummaryItem]()
        summaryItems.append(PKPaymentSummaryItem(label: restaurantsName, amount: intPriceItem))
        
        //Set the paymentSummaryItems to your array
        request.paymentSummaryItems = summaryItems
        
        //Create a Apple Pay Controller and present
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        self.presentViewController(applePayController, animated: true, completion: nil)
        
        applePayController.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "customPaymentSegue") {
            let svc = segue.destinationViewController as! CustomPaymentViewController
            
            svc.priceOfItemsInCart = priceOfItemsInCart
            svc.taxOfFood = stringTaxOfFood
            svc.convenienceFee = stringConvenienceFee
            //svc.emailBody = emailBody
            //svc.emailHeader = emailHeader
            svc.restaurantsName = restaurantsName
            svc.itemsInCart = itemsInCart
            svc.stringPriceItem = stringPriceItem
            svc.stringTaxOfFood = stringTaxOfFood
            svc.stringConvenienceFee = stringConvenienceFee
            svc.priceOfItems = priceOfItems
            svc.taxOfFood2 = taxOfFood
            svc.convenienceFee2 = convenienceFee
            svc.airlineFieldText = airlineFieldText
            svc.flightNumberText = flightNumberText
            svc.specialRequests = specialRequests
            svc.foodOption = foodOption
            svc.replaced = replaced
        }
    }
}

