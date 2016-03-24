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

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var fruitPriceLabel: UILabel!
    //@IBOutlet weak var fruitTitleLabel: UILabel!
    @IBOutlet weak var fruitImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    
    
    
    //@IBOutlet weak var indvPriceItemLabel: UILabel!
    
    
    @IBOutlet weak var fruitTitleLabel: UILabel!
    
    //var menuItemsForPayment: [String] = []
    //var menuItemPricesForPayment: [AnyObject] = []
    
    var itemName = String()
    var itemPrice = String()
    
    var itemsInCart: [String] = []
    var priceOfItemsInCart: [String] = []
    
    //Set some important stuff here
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePayFruitsMerchantID = "merchant.com.LSUS.AirBite" // Fill in your merchant ID here!
    
    /*var fruit: Fruit! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }*/
    
    func configureView() {
        
        if (!self.isViewLoaded()) {
            return
        }
        
        //self.title = fruit.title
        self.title = "Mister G's Restaurant"
        //self.fruitImage.image = fruit.image
        
        // set up the label that holds the details for each indiviudual item in teh cart
        var cartItems = ""
        for var i = 0; i <= itemsInCart.count - 1; i++ {
            let individualItem = "\(itemsInCart[i]): $\(priceOfItemsInCart[i]) \r\n \r\n"
            cartItems += individualItem
        }
        self.fruitTitleLabel.text = cartItems
        
        // set up the total price
        var priceOfItems = Float()
        for pItem in priceOfItemsInCart {
            let price = (pItem as NSString).floatValue
            priceOfItems += price
        }
        let stringPriceItem = String(format: "%.2f", priceOfItems)
        self.fruitPriceLabel.text = "Order Total: $\(stringPriceItem)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
    }
    
    @IBAction func purchase(sender: UIButton) {
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
        summaryItems.append(PKPaymentSummaryItem(label: itemName, amount: 20))
        //summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: fruit.shippingPrice))
        summaryItems.append(PKPaymentSummaryItem(label: "Mister G Restaurant", amount: 20))
        
        //Set the paymentSummaryItems to your array
        request.paymentSummaryItems = summaryItems
        
        //Create a Apple Pay Controller and present
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        self.presentViewController(applePayController, animated: true, completion: nil)
        
        //And dont forget this! :)
        applePayController.delegate = self
    }
    
       
    
}

