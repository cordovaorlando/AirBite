//
//  TableViewController.swift
//  AirBite
//
//  Created by Jose Cordova on 2/1/16.
//  Copyright © 2016 Eren Corapcioglu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    //Array that holds the food description without null values
    var foodDescription: [String] = []
    //Array that holds the restaurants' name
    var restaurantsName: [String] = []
    //Array that holds the gate number
    var restaurantsGate: [String] = []
    //Array that holds the restaurants' id
    var restaurantsID: [String] = []
    //String variable that holds one restaurant id
    var selectedRestaurantID = String()
    //Array that holds section names from restaurant's menu
    var menuItemType: [AnyObject!] = []
    //Array that holds a dictionary from the API
    var wholeMenuArray: [AnyObject!] = []
    //Array that holds the food description with null values
    var descriptionsArray: [AnyObject!] = []
    // Creates dynamic mutable data
    private var responseData:NSMutableData?
    // Load the contents of a URL by providing a URL request object
    private var connection:NSURLConnection?
    
    var airportCode = String()
    
    var flightNumberText = String()
    var airlineFieldText = String()
    var foodOption = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = airportCode
        
        
        print("flightNumber: " + flightNumberText)
        print("airlineName: " + airlineFieldText)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    /// This function returns the number of rows to be present in each table section (the number of sections
    /// is set in numberOfSectionInTableView function.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // we want to return the number of rows based on how many values are in the restaurants array.
        return restaurantsName.count
    }
    
    // This returns the title of the section
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Restaurants"
    }
    
    //This returns the name of the restaurants
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("labelCell", forIndexPath: indexPath)

        // Configure the cell...
        // return a value for each cell (text value) based on the values in the restuarnts array.
        cell.textLabel?.text = restaurantsName[indexPath.row] + "  (" + restaurantsGate[indexPath.row] + ")"
        
        cell.textLabel?.font = UIFont(name: "Georgia-Bold", size: 15.0)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let title = UILabel()
        title.font = UIFont(name: "Georgia-BoldItalic", size: 19.0)
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = title.font
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let blogIndex = tableView.indexPathForSelectedRow?.row
        selectedRestaurantID = restaurantsID[blogIndex!]
        restaurantAPI()
        print("Testing")
        
    }
    
    private func restaurantAPI(){
        
        let urlString = "https://api.locu.com/v1_0/venue/" + selectedRestaurantID + "/?has_menu=TRUE&locality=DFW&api_key=42c74053d1a1b2377c716af18da0b235d260be5b"
        
        //Connecting to the API
        let url = NSURL(string: (urlString as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        if url != nil{
            let urlRequest = NSURLRequest(URL: url!)
            self.connection = NSURLConnection(request: urlRequest, delegate: self)
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
                    
                    //Extracting data from the objects array or dictionary.
                    let prediction = result["objects"] as! NSArray
                    
                    for dict in prediction {
                        
                        let predictions2 = dict["menus"] as! NSArray
                        
                        for dict2 in predictions2{
                            
                            let predictions3 = dict2["sections"] as! NSArray
                            
                            for dict3 in predictions3{
                                let predictions4 = dict3["subsections"] as! NSArray
                                let menuType = dict3["section_name"]
                                
                                menuItemType.append(menuType)
                                wholeMenuArray.append(dict3)
                                
                                
                                /// this is used to pull just the appetizer section for now. This will be updated to filter per section but for now this is just for the appetizer arrays.
                                if let firstElem = menuItemType.first {
                                    for elem in predictions3 {
                                        if elem["section_name"] as! String == firstElem as! String {
                                        }
                                    }
                                }
                                
                                for dict4 in predictions4{
                                    let predictions5 = dict4["contents"] as! NSArray
                                    
                                    for dict5 in predictions5{
                                        let itemDescription = dict5["description"]
                                        descriptionsArray.append(itemDescription)
                                    }
                                }
                            }
                        }
                    } // this ends predictions
                    
                    let descriptionWithNoNilValues = descriptionsArray.flatMap { $0 }
                    
                    for app in descriptionWithNoNilValues {
                        foodDescription.append(app as! String)
                    }
                    
                    self.performSegueWithIdentifier("restaurantSelectSegue", sender: self)
                    
                    wholeMenuArray.removeAll()
                    menuItemType.removeAll()
                    
                    return
                }
            }
            catch let error as NSError{
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - Segues
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "restaurantSelectSegue" {
                if let menuTableViewController = segue.destinationViewController as?AccordionMenuTableViewController {
                    if let blogIndex = tableView.indexPathForSelectedRow?.row {
                        menuTableViewController.wholeMenuArray = wholeMenuArray
                        menuTableViewController.menuItemType = menuItemType
                        menuTableViewController.restaurantsID = restaurantsID[blogIndex]
                        menuTableViewController.restaurantsName = restaurantsName[blogIndex]
                        menuTableViewController.airlineFieldText = airlineFieldText
                        menuTableViewController.flightNumberText = flightNumberText
                        menuTableViewController.foodOption = foodOption
                    }
                }
            }
    }
}
