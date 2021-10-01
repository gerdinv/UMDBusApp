//
//  SearchVC.swift
//  UMDBusApp
//
//  Created by Gerdin Ventura on 9/30/21.
//

import UIKit
import CoreLocation

protocol SearchVCDelegate: AnyObject {
    func searchViewController(_ vc: SearchVC, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

class SearchVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SearchVCDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Destination"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()

    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Enter building name"
        field.layer.cornerRadius = 10
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        return field
    }()
    
    private let tableView: UITableView = {
        let tb = UITableView()
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb.backgroundColor = .secondarySystemBackground
        return tb
    }()
    
    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(tableView)
        view.backgroundColor = .secondarySystemBackground
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setupConstraints()
    }
    
    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
                
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor))
        constraints.append(titleLabel.heightAnchor.constraint(equalToConstant: 25))
        
        constraints.append(textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10))
        constraints.append(textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor))
        constraints.append(textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        constraints.append(textField.heightAnchor.constraint(equalToConstant: 50))
        
        constraints.append(tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10))
        constraints.append(tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor))
        constraints.append(tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor))
        constraints.append(tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        

        NSLayoutConstraint.activate(constraints)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .secondarySystemBackground
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coordinate = locations[indexPath.row].coordinates
//        Notify map controller to show pin at selected place.
        delegate?.searchViewController(self, didSelectLocationWith: coordinate)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text, !text.isEmpty {
            LocationManager.shared.findLocations(with: text) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                    self?.tableView.reloadData()
                }
            }
        }
        
        return true
    }

}
