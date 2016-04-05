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
        // 1
        //let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
        
        // 2
        Stripe.setDefaultPublishableKey("pk_test_Nxy4IoZXCoOVppUkWdFH7eOv")  // Replace With Your Own Key!
        
        // 3
        STPAPIClient.sharedClient().createTokenWithPayment(payment) {
            (token, error) -> Void in
            
            self.navigationController?.popToRootViewControllerAnimated(true)
            
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
            
            
            
            
            let bodyStr = "from=AirBite <sales@goairbite.com>&to=Receiver name <cordovaorlando@hotmail.com>&subject=We've received your order! Order # BBY01&text= Thanks for your order."
            
            // appending the data
            requestEmail.HTTPBody = bodyStr.dataUsingEncoding(NSUTF8StringEncoding);
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(requestEmail, completionHandler: { (data, response, error) -> Void in
                // ... do other stuff here
            })
            
            task.resume()
            print("testing...")
            
            
            
            
            if (error != nil) {
                print(error)
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            
            // 4
            //let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
            
            // 5
            //let url = NSURL(string: "http://10.0.0.4:5000/pay")  // Replace with computers local IP Address!
            let url = NSURL(string: "http://73.183.220.171:5000/pay")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // 6
            
            
            let body = ["stripeToken": token!.tokenId,
                "amount": 200.00,
                "description": "Sample Title"//,
                //"shipping": [
                //  "city": shippingAddress.City!,
                //"state": shippingAddress.State!,
                // "zip": shippingAddress.Zip!,
                //"firstName": shippingAddress.FirstName!,
                // "lastName": shippingAddress.LastName!]
                
                //decimalNumberByMultiplyingBy(NSDecimalNumber(string: "100"))
            ]
            
            // var error: NSError?
            //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(), error: &error)
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
            } catch let error as NSError {
                print("An error occurred: \(error)")
            }
            
            
            
            // 7
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
    var intPriceItem = NSDecimalNumber()
    
    var priceOfItems = Float()
    var stringPriceItem = String()
    var stringConvenienceFee = String()
    var stringTaxOfFood = String()
    
    var convenienceFee = Float()
    var taxOfFood = Float()
    
    var delegate: RemoveFromCartDelegate?
    
    //Set some important stuff here
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePayFruitsMerchantID = "merchant.com.LSUS.AirBite" // Fill in your merchant ID here!

    func configureView() {
        
        if (!self.isViewLoaded()) {
            return
        }
        
        //self.title = fruit.title
        self.title = restaurantsName
        //self.fruitImage.image = fruit.image
        
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

        self.fruitPriceLabel.text = "Convenience Fee: $\(stringConvenienceFee) \r\nTax: $\(stringTaxOfFood) \r\nOrder Total: $\(stringPriceItem)"
        totalPrice = stringPriceItem
    }
    
    /// converts the passed in float to a string with two precceding decimals.
    func convertFloatToString(floatToConvert: Float) -> String{
        return String(format: "%.2f", floatToConvert)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // these next three lines of codes overrides the designed back button, and lets it be custom in order to update the cart when hitting the back button.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Add Food", style: UIBarButtonItemStyle.Bordered, target: self, action: "updateCart:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        
        // register the table view created since it's not a table view controller, just a table view inside the view controller.
        self.tableViewSummary.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    /// returns the number of rows in the table view cell based on the number of items in the cart.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsInCart.count;
    }

    /// Populate the table view cells in the table view to have the each item and price listed in the cart.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableViewSummary.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.itemsInCart[indexPath.row] + ": $" + self.priceOfItemsInCart[indexPath.row]
        
        return cell
    }
    
    // function to update the total price after an item has been removed from the cart.
    func updatePrice(priceToUpdate: Float) -> String {
        
        // remove all the previous prices. We are removing the priceToUpdate item, so we need to remove previous tax and conveience fee.
        priceOfItems -= priceToUpdate
        priceOfItems -= convenienceFee
        priceOfItems -= taxOfFood
        
        // create new tax of food.
        let newTaxOfFood = priceOfItems * Float(0.07)
        
        // re add convenienceFee and newTaxOfFood to get new total
        priceOfItems += convenienceFee
        priceOfItems += newTaxOfFood
        
        stringTaxOfFood = convertFloatToString(newTaxOfFood)
        
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
    
    @IBAction func applePayPayment(sender: UIButton) {
        
        //Build the request
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayFruitsMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        //Shipping
        //request.requiredShippingAddressFields = PKAddressField.PostalAddress | PKAddressField.Phone
        
        //Create the summaryItems array
        
        var summaryItems = [PKPaymentSummaryItem]()
        summaryItems.append(PKPaymentSummaryItem(label: restaurantsName, amount: intPriceItem))
        
        //Set the paymentSummaryItems to your array
        request.paymentSummaryItems = summaryItems
        
        //Create a Apple Pay Controller and present
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        self.presentViewController(applePayController, animated: true, completion: nil)
        
        //And dont forget this! :)
        applePayController.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "customPaymentSegue") {
            let svc = segue.destinationViewController as! CustomPaymentViewController
            
            svc.priceOfItemsInCart = priceOfItemsInCart
            svc.taxOfFood = stringTaxOfFood
            svc.convenienceFee = stringConvenienceFee
        }
    }
}

