//
//  SearchLocationVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 1/16/23.
//  Copyright © 2023 Pickzon Inc. All rights reserved.
//

import UIKit
import MapKit
import IQKeyboardManager

protocol SearchLocationDelegate: AnyObject{
    
    func selectedSearchedLocation(place:MKPlacemark,mapItem:MKMapItem,title:String,Subtitle:String)
}

class SearchLocationVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTable: UITableView!
    @IBOutlet weak var cnstrnt_HtNavBar:NSLayoutConstraint!

    // Create a seach completer object
    var searchCompleter = MKLocalSearchCompleter()

    // These are the results that are returned from the searchCompleter & what we are displaying
    // on the searchResultsTable
    var searchResults = [MKLocalSearchCompletion]()
    var delegate:SearchLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cnstrnt_HtNavBar.constant = self.getNavBarHt
        searchResultsTable?.delegate = self
        searchResultsTable?.dataSource = self
        searchCompleter.delegate = self
        
        searchBar?.delegate = self
        searchResultsTable?.delegate = self
        searchResultsTable?.dataSource = self
       // searchBar.becomeFirstResponder()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    //MARK: UIButton Action Methods
    
    @IBAction func backButtonActionMethods(_ sender:UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

}

extension SearchLocationVC: MKLocalSearchCompleterDelegate,UISearchBarDelegate {
    
    // This method declares that whenever the text in the searchbar is change to also update
    // the query that the searchCompleter will search based off of
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            print("Сancel button tapped")
        searchCompleter.queryFragment = ""

        self.view.endEditing(true)
        }
    
    // This method declares gets called whenever the searchCompleter has new search results
    // If you wanted to do any filter of the locations that are displayed on the the table view
    // this would be the place to do it.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Setting our searcResults variable to the results that the searchCompleter returned
        searchResults = completer.results

        // Reload the tableview with our new searchResults
        searchResultsTable.reloadData()
    }
    
    

    // This method is called when there was an error with the searchCompleter
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Error
    }
}

// Setting up extensions for the table view
extension SearchLocationVC: UITableViewDataSource,UITableViewDelegate {
    // This method declares the number of sections that we want in our table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // This method declares how many rows are the in the table
    // We want this to be the number of current search results that the
    // searchCompleter has generated for us
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    // This method delcares the cells that are table is going to show at a particular index
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the specific searchResult at the particular index
        let searchResult = searchResults[indexPath.row]

        //Create  a new UITableViewCell object
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        //Set the content of the cell to our searchResult data
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)

        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }

            guard let name = response?.mapItems[0].name else {
                return
            }

            let lat = coordinate.latitude
            let lon = coordinate.longitude

            print(lat)
            print(lon)
            print(name)
            
            self.delegate?.selectedSearchedLocation(place: (response?.mapItems[0].placemark)!,mapItem:(response?.mapItems[0])!,title:self.searchResults[indexPath.row].title,Subtitle: self.searchResults[indexPath.row].subtitle)
            self.navigationController?.popViewController(animated: true)

        }
    }
}
