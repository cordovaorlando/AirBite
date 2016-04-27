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
    
    @IBOutlet weak var orLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
 
        let mainScreenSize : CGSize = UIScreen.mainScreen().bounds.size // Getting main screen size of iPhone
        
//        let imageObbj:UIImage! =   self.imageResize(UIImage(named: "CloudsAndLogoBackground.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))

        let imageObbj:UIImage! =   self.imageResize(UIImage(named: "LeftTopPlainLogo.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))
        
        
        
        self.view.backgroundColor = UIColor(patternImage:imageObbj)
        pickUpButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        deliveryButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        orLabel.textColor = UIColor.blackColor()
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
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
