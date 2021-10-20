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
    func searchBarClicked(_ vc: SearchVC)
    func addVC(_ vc: SearchVC)
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
    var ids = ["2813", "311", "3310", "3510", "3710", "4113", "4416", "4516", "4819", "6211", "7816", "8005","8505", "8813", "9813", "9913" ]
    var filteredIds: [String]?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Destination"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
  
    let searchBar: UISearchBar = {
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
//        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb.register(BusInformationCell.self, forCellReuseIdentifier: BusInformationCell.identifier)
        tb.backgroundColor = .secondarySystemBackground
        return tb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        setupConstraints()
        getData()
        filteredIds = ids
        tableView.rowHeight = 120

    }
    
    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(titleLabel.widthAnchor.constraint(equalToConstant: 150))
        constraints.append(titleLabel.heightAnchor.constraint(equalToConstant: 25))
                
        constraints.append(searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10))
        constraints.append(searchBar.heightAnchor.constraint(equalToConstant: 50))
                
        constraints.append(tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor))
        constraints.append(tableView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredBuildings?.count ?? 0
        return filteredIds?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BusInformationCell.identifier, for: indexPath) as! BusInformationCell

//        cell.busIdLabel.text = filteredBuildings![indexPath.row].name
        cell.busIdLabel.text = filteredIds![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        delegate?.addVC(self)
        tableView.deselectRow(at: indexPath, animated: true)
        
//      let coordinate = locations[indexPath.row].coordinates
        let lat = Double(filteredBuildings![indexPath.row].lat)
        let long = Double(filteredBuildings![indexPath.row].lng)
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        
//      Notify map controller to show pin at selected place.
        delegate?.searchViewController(self, didSelectLocationWith: coordinate)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        delegate?.searchBarClicked(self)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        filteredBuildings = searchText.isEmpty ? buildings : buildings?.filter { (item: Building) -> Bool in
//            // If dataItem matches the searchText, return true to include it
//            return item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
//        }
          
        filteredIds = searchText.isEmpty ? ids : ids.filter { (item: String) -> Bool in
            return item.range(of: searchText, range: nil, locale: nil) != nil
        }
        
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
