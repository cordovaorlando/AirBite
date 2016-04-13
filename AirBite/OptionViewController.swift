//
//  OptionViewController.swift
//  AirBite
//
//  Created by Eren Corapcioglu on 11/9/15.
//  Copyright © 2015 Eren Corapcioglu. All rights reserved.
//

import UIKit

class OptionViewController: UIViewController{
    
    @IBOutlet weak var pickUpButton: UIButton!
    @IBOutlet weak var deliveryButton: UIButton!
    var deliverySelected = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    


    }
    
    @IBAction func pickUp(sender: UIButton) {
        
        
        //let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        //let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("firstView") as! ViewController
        //self.presentViewController(nextViewController, animated:true, completion:nil)
        
    }
    
    
    //Sending the data returned in the outputLabel textview to dataPassed which is a string variable in TableViewController.swift
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "pickUpSegue") {
            let svc = segue.destinationViewController as! ViewController
            //svc.deliverySelected = deliverySelected
            }
        else if(segue.identifier == "deliverySegue"){
            let svc = segue.destinationViewController as! ViewController
                deliverySelected = true
                svc.deliverySelected = deliverySelected
            
            
        }
    }
    
    

    
    
    
    
}
