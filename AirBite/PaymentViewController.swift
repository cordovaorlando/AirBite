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
    }
    
    //Delegate function for when the animations have all finished in the PKPaymentAuthorizationViewController
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

class PaymentViewController: UIViewController {
    
    @IBOutlet weak var fruitPriceLabel: UILabel!
    @IBOutlet weak var fruitTitleLabel: UILabel!
    @IBOutlet weak var fruitImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    
    //var menuItemsForPayment: [String] = []
    //var menuItemPricesForPayment: [AnyObject] = []
    
    var itemName = String()
    var itemPrice = String()
    
    //Set some important stuff here
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePayFruitsMerchantID = "merchant.com.mayuko.ApplePayFruit" // Fill in your merchant ID here!
    
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
        //self.fruitPriceLabel.text = "$" + (fruit.priceString as String)//
        self.fruitPriceLabel.text = "$" + itemPrice
        //self.fruitImage.image = fruit.image
        self.fruitTitleLabel.text = itemName
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

