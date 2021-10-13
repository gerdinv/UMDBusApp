//
//  SearchVC.swift
//  UMDBusApp
//
//  Created by Gerdin Ventura on 9/30/21.
//

import UIKit
import MapKit
import CoreLocation

protocol SearchVCDelegate: AnyObject {
    func searchViewController(_ vc: SearchVC, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

struct Building: Codable {
    let name: String
    let code: String
    let id: String
    let lng: String
    let lat: String
}

class SearchVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    weak var delegate: SearchVCDelegate?
    var buildings : [Building]?
    var filteredBuildings: [Building]?
    var locations = [Location]()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Destination"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
     var responseCounter: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Count: "
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
  
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.searchBarStyle = UISearchBar.Style.default
        bar.placeholder = "Enter building name"
        bar.sizeToFit()
        bar.isTranslucent = false
        bar.backgroundColor = .secondarySystemBackground
        bar.barTintColor = .secondarySystemBackground
        bar.backgroundImage = UIImage() // Get's rid of top and bottom lines/border
        return bar
    }()
    
    private let tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb.backgroundColor = .secondarySystemBackground
        return tb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(responseCounter)
        view.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        setupConstraints()
        getData()
    }
    
    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(titleLabel.widthAnchor.constraint(equalToConstant: 250))
        constraints.append(titleLabel.heightAnchor.constraint(equalToConstant: 25))
                
        constraints.append(searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10))
        constraints.append(searchBar.heightAnchor.constraint(equalToConstant: 50))
                
        constraints.append(tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor))
        constraints.append(tableView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))

        constraints.append(responseCounter.topAnchor.constraint(equalTo: titleLabel.topAnchor))
        constraints.append(responseCounter.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10))
        constraints.append(responseCounter.widthAnchor.constraint(equalToConstant: 140))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBuildings?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .secondarySystemBackground
        //        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.text = filteredBuildings![indexPath.row].name
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
//      let coordinate = locations[indexPath.row].coordinates
        let lat = Double(filteredBuildings![indexPath.row].lat)
        let long = Double(filteredBuildings![indexPath.row].lng)
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        
//      Notify map controller to show pin at selected place.
        delegate?.searchViewController(self, didSelectLocationWith: coordinate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredBuildings = searchText.isEmpty ? buildings : buildings?.filter { (item: Building) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        // add a transition
        tableView.reloadData()
    }

    func getData() {
        let req = URLRequest(url: URL(string: "https://api.umd.io/v0/map/buildings")!)
        URLSession.shared.dataTask(with: req, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print("Error with request")
                return
            }
            
            do {
                self.buildings = try JSONDecoder().decode([Building].self, from: data)
                self.filteredBuildings = self.buildings
            } catch {
                print("Error decoding data")
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }).resume()
    }
}
