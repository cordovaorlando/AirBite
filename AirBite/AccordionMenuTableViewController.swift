//
//  AccordionMenuTableViewController.swift
//  AccordionTableSwift
//
//  Created by Eren Corapcioglu on 2/29/16.
//

import UIKit

class AccordionMenuTableViewController: UITableViewController, AddToCartDelegate, RemoveFromCartDelegate {
    
    
    var descriptionString = String()
    var foodDescription: [String] = []
    var restaurantsName = String()
    var restaurantsID = String()
    
    var menuSectionName: [String] = []
    var wholeMenuArray: [AnyObject!] = []
    var menuSectionItems = [String]()
    var menuItems = [[String]]()
    
    var addToCartArray: [String] = []
    
    var addPriceToCartArray: [String] = []
    
    var addSpecialRequestToCart: [String] = []
    
    var menuDescriptionItems = [[String]]()
    
    var menuPrice = [[String]]()
    
    var currentItemsExpanded = [Int]()
    var actualPositions = [Int]()
    var total = 0
    
    var menuSectionIdentifier = "MenuSection"
    var menuItemIdentifier = "MenuItem"
    
    var arrayToDelete = 0
    
    var menuItemType: [AnyObject!] = []
    
    var flightNumberText = String()
    var airlineFieldText = String()
    var foodOption = String()
    
    
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    
    /// function that populates the add to cart array based on the menu items selected to add to the cart in the 
    /// DescirptionViewController
    func addToCartResponse(addToCartArrayParam: [String], addPriceToCartArrayPram: [String], addSpecialRequestArrayParam: [String])
    {
        self.addToCartArray += addToCartArrayParam
        self.addPriceToCartArray += addPriceToCartArrayPram
        self.addSpecialRequestToCart += addSpecialRequestArrayParam
        
        let buttonTitle = "Cart (\(addToCartArray.count))"
        
        addToCartButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        addToCartButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    func removeFromCartResponse(removeFromCartArrayParam: [String], removePriceFromCartArrayPram: [String])
    {
        self.addPriceToCartArray = []
        self.addPriceToCartArray = []
        
        self.addToCartArray = removeFromCartArrayParam
        self.addPriceToCartArray = removePriceFromCartArrayPram
        
       // print(addToCartArray)
       // print(addPriceToCartArray)
    
        let buttonTitle = "Cart (\(addToCartArray.count))"
    
        addToCartButton.setTitle(buttonTitle, forState: UIControlState.Normal)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = restaurantsName
       // addToCartButton.frame = CGRectMake(50, 50, 50, 50)
        
        let menuSectionNameWithNoNilValues = menuItemType.flatMap { $0 }
        
         var menuSection: [String] = []
         for type in menuSectionNameWithNoNilValues {
             menuSection.append(type as! String)
         }
        
        menuSectionName = menuSection
       
        for (var i = 0; i < menuSectionName.count; i++) {
            
            // we want to remove the empty string values since these persent blank rows in data.
            if (menuSectionName[i] != ""){
                menuSectionItems.append(menuSectionName[i])
                actualPositions.append(-1)
            }
            
            if (menuSectionName[i] == "") {
                arrayToDelete = i
            }
            
            var foodItems: [AnyObject!] = []
            
            var desciprtionItems: [AnyObject!] = []
            var priceItems: [AnyObject!] = []
    
            for menu in wholeMenuArray {
                if menu["section_name"] as! String == menuSectionName[i]{
                    let subSections = menu["subsections"] as! NSArray
                    for subSection in subSections {
                        let foodContents = subSection["contents"] as! NSArray
                        for foodItem in foodContents {
                            if let food = foodItem["name"] {
                                let foodItemWithNoNils = food.flatMap { $0 }
                                foodItems.append(foodItemWithNoNils)
                            }
                            
                            if let description = foodItem["description"] {
                                let descriptionItemWithNoNils = description.flatMap { $0 }
                                    desciprtionItems.append(descriptionItemWithNoNils)
                            }
                            
                            if let price = foodItem["price"] {
                                let priceWithNoNils = price.flatMap { $0 }
                                priceItems.append(priceWithNoNils)
                            }
                        }
                    }
                }
            }
            
            let foodItemNoNil = foodItems.flatMap { $0 }
            var items = [String]()
            for (var i = 0; i < foodItemNoNil.count; i++) {
                items.append(foodItemNoNil[i] as! String)
            }
            
            // we want to remove the empty arrays since these persent blank rows in data. This keeps the menuItems "in line" with menuSectionItems
            if (items != []) {
                self.menuItems.append(items)
            }
            
            let desciptionItemNoNil = desciprtionItems.flatMap { $0 }
            var descItems = [String]()
            for (var i = 0; i < desciptionItemNoNil.count; i++) {
                descItems.append(desciptionItemNoNil[i] as! String)
            }
            
            self.menuDescriptionItems.append(descItems)
            
            let priceWithNoNil = priceItems.flatMap { $0 }
            var price = [String]()
            for (var i = 0; i < priceWithNoNil.count; i++) {
                price.append(priceWithNoNil[i] as! String)
            }
            
            self.menuPrice.append(price)

        }
        
        if (arrayToDelete > 0) {
            self.menuDescriptionItems.removeAtIndex(arrayToDelete)
            self.menuPrice.removeAtIndex(arrayToDelete)
        }
        
        total = menuSectionItems.count
        
        let mainScreenSize : CGSize = UIScreen.mainScreen().bounds.size // Getting main screen size of iPhone
    
        let imageObbj:UIImage! =   self.imageResize(UIImage(named: "PlainBackground.png")!, sizeChange: CGSizeMake(mainScreenSize.width, mainScreenSize.height))
        
        self.tableView.backgroundColor = UIColor(patternImage:imageObbj)
        
        addToCartButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }

    
    /// reloads the menu page after the back button is clicked.
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.tableView.reloadData(); // to reload selected cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// returns the number of sections in the table view.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /// returns the number of rows to be present in each section on the table view.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.total
    }
    
    /// Organize the MenuSection and MenuItem cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let menuSection = self.findParentMenuSection(indexPath.row)
        let currentItemsExpanded = self.currentItemsExpanded.indexOf(menuSection)
        
        let isMenuItem = currentItemsExpanded != nil && indexPath.row != self.actualPositions[menuSection]
        
        var cell : UITableViewCell!
        
        if isMenuItem {
            cell = tableView.dequeueReusableCellWithIdentifier(menuItemIdentifier, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = self.menuItems[menuSection][indexPath.row - self.actualPositions[menuSection] - 1]
            
            cell.textLabel?.font = UIFont(name: "Georgia", size: 16.0)

            
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier(menuSectionIdentifier, forIndexPath: indexPath) as UITableViewCell
            let topIndex = self.findParentMenuSection(indexPath.row)
            
            cell.textLabel!.text = self.menuSectionItems[topIndex]
            cell.detailTextLabel?.text = ""
            cell.textLabel?.font = UIFont(name: "Georgia-BoldItalic", size: 18.0)
        }
        
        cell.backgroundColor = UIColor(red: 135, green: 223, blue: 238, alpha: 0)
        cell.textLabel?.textColor = UIColor.blackColor()
        
        return cell
    }
    
    /// set up the features when a row is tapped - whether it's a parent row or child row.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let menuSections = self.findParentMenuSection(indexPath.row)

        // this is a built in table view featuer - allow multiple insert/delete of rows and sections to be animated simultaneously.
        self.tableView.beginUpdates()
        
        if let removeIndexValue = self.currentItemsExpanded.indexOf(self.findParentMenuSection(indexPath.row)) {
            
            self.collapseSubItemsAtIndex(indexPath.row)
            self.actualPositions[menuSections] = -1
            self.currentItemsExpanded.removeAtIndex(removeIndexValue)
            
            for (var i = menuSections + 1; i < self.menuSectionItems.count; i++) {
                if self.actualPositions[i] != -1 {
                    self.actualPositions[i] -= self.menuItems[menuSections].count
                }
            }
        }
        else {
            let menuSection = self.findParentMenuSection(indexPath.row)
            
            self.expandItemAtIndex(indexPath.row)
            self.actualPositions[menuSection] = indexPath.row
            
            for (var i = menuSection + 1; i < self.menuSectionItems.count; i++) {
                if self.actualPositions[i] != -1 {
                    self.actualPositions[i] += self.menuItems[menuSection].count
                }
            }
            self.currentItemsExpanded.append(menuSection)
        }
        
        self.tableView.endUpdates()
    }
    
    /// expands the selected parent cell.
    private func expandItemAtIndex(index : Int) {
        
        var indexPaths = [NSIndexPath]()
        
        let val = self.findParentMenuSection(index)
        
        let currentMenuItems = self.menuItems[val]
        var insertPos = index + 1
        
        for (var i = 0; i < currentMenuItems.count; i++) {
            indexPaths.append(NSIndexPath(forRow: insertPos++, inSection: 0))
        }
        
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.total += self.menuItems[val].count
    }
    
    /// collapses the selected (and currently expanded) parent cell.
    private func collapseSubItemsAtIndex(index : Int) {
        
        var indexPaths = [NSIndexPath]()
        let menuSections = self.findParentMenuSection(index)
        
        for (var i = index + 1; i <= index + self.menuItems[menuSections].count; i++ ){
            indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        self.total  -= self.menuItems[menuSections].count
    }
    
    /// sets the height and width of the cells based on if child cells are showing.
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let menuSections = self.findParentMenuSection(indexPath.row)
        let currentItemsExpanded = self.currentItemsExpanded.indexOf(menuSections)
        
        let isMenuItem = currentItemsExpanded != nil && indexPath.row != self.actualPositions[menuSections]
        
        if (isMenuItem) {
            return 54.0
        }
        return 84.0
    }
    
    /// finds the index at which the parent menu section cell is located.
    private func findParentMenuSection(index : Int) -> Int {
        
        var menuSection = 0
        var i = 0
        
        while (true) {
            if (i >= index) {
                break
            }
            
            // if is opened
            if let _ = self.currentItemsExpanded.indexOf(menuSection) {
                i += self.menuItems[menuSection].count + 1
                
                if (i > index) {
                    break
                }
            }
            else {
                ++i
            }
            
            ++menuSection
        }
        
        return menuSection
    }
    
    /// prepare for the segue to the description page. Pass the necessary values to the description page.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var menuSections = 0
        var menuItemSectionsIndex = 0
        
        if let blogIndex = tableView.indexPathForSelectedRow?.row {
            
            // this variable gets the location of the parent/menu section
            //let menuSections = self.findParentMenuSection(blogIndex)
            menuSections = self.findParentMenuSection(blogIndex)
            // this variable gets the location of the menu item selected under the menu section.
            //let menuItemSectionsIndex = (blogIndex - self.actualPositions[menuSections] - 1) as Int
            menuItemSectionsIndex = (blogIndex - self.actualPositions[menuSections] - 1) as Int
            
            // for items that don't come with a description, we are adding a generic description in order for the array not to break.
            if (menuDescriptionItems[menuSections].count == 0)
            {
                
                print(menuItems[menuSections].count)
                
                
                for _ in menuItems[menuSections]
                {
                    menuDescriptionItems[menuSections].append("Please ask for description")
                }
                
                print(menuDescriptionItems[menuSections].count)
            }
            
            // for not append a set price for the items that do not have a set price. This will allow the add to cart to not break.
            if (menuPrice[menuSections].count == 0) {
                let setPrice = String(format: "%.2f", Float(5.00))
                
                for _ in menuItems[menuSections]
                {
                    menuPrice[menuSections].append(setPrice)
                }
            }
        }
        
        // if these print statments work, which they do, then there should be no breaking on the segue.
        print(menuDescriptionItems[menuSections][menuItemSectionsIndex])
        print(menuPrice[menuSections][menuItemSectionsIndex])
        
        if segue.identifier == "descriptionSegue" {
            if let destination = segue.destinationViewController as? DescriptionViewController {
                
                // this sets the delegate to the DescriptionViewController, which is important for setting up the values for addToCartArray.
                destination.delegate = self
                
                destination.itemName = menuItems[menuSections][menuItemSectionsIndex]
                destination.descriptionString = menuDescriptionItems[menuSections][menuItemSectionsIndex]
                destination.itemPrice = menuPrice[menuSections][menuItemSectionsIndex]
                destination.restaurantsName = restaurantsName
            }
        }
        
        if (segue.identifier == "addToCartSegue") {
            let addToCart = segue.destinationViewController as! PaymentViewController
            
            // this sets the delegate to the PaymentViewController, which is important for updating the cart when hitting the back button.
            addToCart.delegate = self
            
            addToCart.itemsInCart = addToCartArray
            addToCart.priceOfItemsInCart = addPriceToCartArray
            addToCart.restaurantsName = restaurantsName
            addToCart.specialRequests = addSpecialRequestToCart
            addToCart.airlineFieldText = airlineFieldText
            addToCart.flightNumberText = flightNumberText
            addToCart.foodOption = foodOption
            
        }
    }
}
