//
//  ViewController.swift
//  AirBite
//
//  Created by Eren Corapcioglu on 11/9/15.
//  Copyright © 2015 Eren Corapcioglu. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, NSURLConnectionDataDelegate, CLLocationManagerDelegate {
    
    // Airport Text Field created from AutoCompleteTextField.swift
    @IBOutlet weak var airportField: AutoCompleteTextField!
    // Airline Text Field
    @IBOutlet weak var airlineField: UITextField!
    // Flight Number Text Field
    @IBOutlet weak var flightField: UITextField!
    //Array that holds restaurants' names
    var restaurantsName: [String] = []
    //Array that holds restaurants' unique ids
    var restaurantsID: [String] = []
    //Array that holds the gate number
    var restaurantsGate: [String] = []
    // Creates dynamic mutable data
    private var responseData:NSMutableData?
    // Load the contents of a URL by providing a URL request object
    private var connection:NSURLConnection?
    
    private var manager = CLLocationManager()
    private var latitude = String()
    private var longitude = String()
    var airportClassification: [Int] = []
    var airportNames: [String] = []
    //var airportCodes: [String] = []
    
    //Airport API Url & Keys
    private var airportCode = ""
    private let airportAppId = "c6ac21ce"
    private let airportAppKey = "087e0cc4dfab24dde84d819bc91a3667"
    private let airportURLString = "https://api.flightstats.com/flex/airports/rest/v1/json/iata/"
    
    var deliverySelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(deliverySelected == true){
            airlineField.hidden = false
            flightField.hidden = false
        }
        
        print(deliverySelected)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        self.airportField.delegate = self;
        self.airlineField.delegate = self;
        self.flightField.delegate = self;
        configureTextField()
        handleTextFieldInterfaces()
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
        else {
            manager.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latitude = "\(manager.location!.coordinate.latitude)"
        longitude = "\(manager.location!.coordinate.longitude)"
        //label3.text = "\(manager.location!.horizontalAccuracy)"
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        let alert = UIAlertController(title: "Error", message: "Error \(error.code)", preferredStyle: .Alert)
        let actionOk = UIAlertAction(title: "Ok", style: .Default, handler: {
            action in
            //..
        })
        
        
        alert.addAction(actionOk)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    //Method for having the status bar on top with a light color, depending on our background color.
    /*
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    */
    
    
    //Dismisses the keyboard from all 3 textfields.
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        airportField.resignFirstResponder()
        airlineField.resignFirstResponder()
        flightField.resignFirstResponder()
        return true
    }
    
    //Dismisses the keyboard from All 3 TextFields.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        airportField.resignFirstResponder()
        airlineField.resignFirstResponder()
        flightField.resignFirstResponder()
        return true
    }
    
    //Configuration of the Font from the AutoComplete list in Aiport Field.
    private func configureTextField(){
        airportField.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        airportField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        airportField.autoCompleteCellHeight = 35.0
        airportField.maximumAutoCompleteCount = 20
        airportField.hidesWhenSelected = true
        airportField.hidesWhenEmpty = true
        airportField.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        airportField.autoCompleteAttributes = attributes
    }
    
    
    //Action for the Button
    @IBAction func buttonPressed(sender: AnyObject) {
        
        let userInput = airportField.text
        
        
        if(!(airportField.text?.isEmpty)! && airportField.text?.characters.count > 2){
            
        
        //Saves only the airport code of each line in airport textfield.
        let airportCode = userInput?.substringToIndex((userInput?.startIndex.advancedBy(3))!)
        
        let urlString = "https://api.locu.com/v1_0/venue/search/?has_menu=TRUE&locality=" + airportCode! + "&api_key=42c74053d1a1b2377c716af18da0b235d260be5b"
  
        //Connecting to the API
        let url = NSURL(string: (urlString as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        if url != nil{
            let urlRequest = NSURLRequest(URL: url!)
            self.connection = NSURLConnection(request: urlRequest, delegate: self)
        }
        }
        
    }
    
    
     func handleTextFieldInterfaces(){
        airportField.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if self!.connection != nil{
                    self!.connection!.cancel()
                    self!.connection = nil
                }
                
                let urlString = self!.airportURLString + text + "?appId=" + self!.airportAppId + "&appKey=" + self!.airportAppKey
        
                //Connecting to the API
                let url = NSURL(string: (urlString as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                
                if url != nil{
                    let urlRequest = NSURLRequest(URL: url!)
                    self!.connection = NSURLConnection(request: urlRequest, delegate: self)
                }
            }
        }
    }
    
    //API Connections
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        responseData = NSMutableData()
    }
    
    //API Connections
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData?.appendData(data)
    }
    
    //API Response
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if let data = responseData{
            do{
                //Extracting data from the "airports" array.
               if let result: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary{
                    
                    if let predictions = result["airports"] as? NSArray{
                        
                        //Arrays for storing the data extracted.
                        var locations = [String]()
                        var locations2 = [String]()
                        var locations3 = [String]()
                        
                        for dict in predictions as! [NSDictionary]{
                            //Extracting iata code and name of the Airport from airports dictionary.
                            locations.append(dict["fs"] as! String)
                            locations2.append(dict["name"] as! String)
                            airportClassification.append(dict["classification"] as! Int)
                        }
                        
                        //Formatting and appendng the iata code array and the name array into a new formatted one.
                        for var index = 0; index < locations.count; ++index {
                            locations3.append(locations[index] + "  " + locations2[index])
                            if(airportClassification[index] <= 3 && airportNames.count < 1){
                                airportNames.append(locations3[index])
                                
                            }
                        }
                        
                        //Returning the formatted array into the AutoCompleteStrings from the airport field.
                        self.airportField.autoCompleteStrings = locations3
                        //self.airportField.text = airportNames[0]
                        
                        
                        return
                    }
                
                    //Same as above, extracting data from the objects array or dictionary.
                    let prediction = result["objects"] as! NSArray
                    //let predictions2 = predictions!["menus"] as? NSArray
                    var locations = [String]()
                    var locations2 = [String]()
                    var locations3 = [String]()
                    
                    for dict in prediction {
                        //Extracting the name of the restaurants
                        locations.append(dict["name"] as! String)
                        locations2.append(dict["id"] as! String)
                        locations3.append(dict["street_address"] as! String)
                } // this ends predictions
                
                //Returning the result in a textview called outputLabel.
                for var index = 0; index < locations.count; ++index{
                    self.restaurantsName.append(locations[index])
                    self.restaurantsID.append(locations2[index])
                    self.restaurantsGate.append(locations3[index])
                }
                
                // intialize submit button segue here.
                self.performSegueWithIdentifier("btnSubmitSegue", sender: self)
                
                restaurantsName.removeAll()
                
                return
                }
            }
            catch let error as NSError{
                print("Error: \(error.localizedDescription)")
            }
        }
    }


    //Dismiss the keyboard from Airport Field.
    func dismissKeyboard(){
        self.airportField.resignFirstResponder()
    }
    
    
    
    
    @IBAction func locationServicePressed(sender: AnyObject) {
        
        print(latitude)
        print(longitude)
        //print(locations3)
        
        
        
        let urlString = "https://api.flightstats.com/flex/airports/rest/v1/json/withinRadius/" + longitude + "/" + latitude + "/25?appId=c6ac21ce&appKey=087e0cc4dfab24dde84d819bc91a3667"
        
        //let urlString = self.airportURLString + longitude + "/" + latitude + "/50?appId=" + self.airportAppId + "&appKey=" + self.airportAppKey
        
        //Connecting to the API
        let url = NSURL(string: (urlString as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        if url != nil{
            let urlRequest = NSURLRequest(URL: url!)
            self.connection = NSURLConnection(request: urlRequest, delegate: self)
        }
        
        
        if let data = responseData{
            do{
                //Extracting data from the "airports" array.
                if let result: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary{
                    
                    if let predictions = result["airports"] as? NSArray{
                        
                        //Arrays for storing the data extracted.
                        var locations = [String]()
                        var locations2 = [String]()
                        var locations3 = [String]()
                        
                        for dict in predictions as! [NSDictionary]{
                            //Extracting iata code and name of the Airport from airports dictionary.
                            locations.append(dict["fs"] as! String)
                            locations2.append(dict["name"] as! String)
                            airportClassification.append(dict["classification"] as! Int)
                        }
                        
                        //Formatting and appendng the iata code array and the name array into a new formatted one.
                        for var index = 0; index < locations.count; ++index {
                            locations3.append(locations[index] + "  " + locations2[index])
                            if(airportClassification[index] <= 3 && airportNames.count < 1){
                                airportNames.append(locations3[index])
                                
                            }
                        }
                        
                        //Returning the formatted array into the AutoCompleteStrings from the airport field.
                        //self.airportField.autoCompleteStrings = locations3
                        self.airportField.text = airportNames[0]
                        
                        return
                    }
                }
            }
            catch let error as NSError{
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
    //Sending the data returned in the outputLabel textview to dataPassed which is a string variable in TableViewController.swift
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "btnSubmitSegue") {
            let svc = segue.destinationViewController as! TableViewController
            svc.restaurantsName = restaurantsName
            svc.restaurantsID = restaurantsID
            svc.restaurantsGate = restaurantsGate
            airportCode = airportField.text!.substringToIndex((airportField.text!.startIndex.advancedBy(3)))
            svc.airportCode = airportCode
            airportField.text = ""
        }
    }
}
