//
//  MapVC.swift
//  UMDBusApp
//
//  Created by Gerdin Ventura on 9/30/21.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation

class MapVC: UIViewController, SearchVCDelegate {
    let mapView = MKMapView()
    let panel = FloatingPanelController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
        
        title = "UMD"
        
        let searchVC = SearchVC()
        searchVC.delegate = self
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        mapView.frame = view.bounds
    }
    
    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
                
        constraints.append(mapView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor))

        
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    func searchViewController(_ vc: SearchVC, didSelectLocationWith coordinates: CLLocationCoordinate2D?) {
        
        guard let coordinates = coordinates else {
            print("Invalid coordiantes")
            return
        }
        
        panel.move(to: .tip, animated: true, completion: nil)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        
        //How much we are zooming in is the decimal
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
    }
}
