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
import SwiftyXMLParser

class MapVC: UIViewController, SearchVCDelegate, CLLocationManagerDelegate, FloatingPanelControllerDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let panel = FloatingPanelController()
    let searchVC = SearchVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)

        mapView.delegate = self
        searchVC.delegate = self
    
//        getBusPrediction()
//        fire()
//        Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
    }

    
    var ids = ["4819", "3510", "7816", "4113", "8005", "4516", "3710", "9813", "6211", "9913", "8505", "8813", "3310", "311", "4416", "2813"]
    
    var myPins = [String : MKPointAnnotation]()
    
    @objc func fire() {
        print("\nPINS: \(myPins)\n")
        for id in ids {
            self.getCurrentBusLocation(bus_id: id)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            mapView.showsUserLocation = true
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007) // Span of the map
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    override func didMove(toParent parent: UIViewController?) {
        print("\n\n\n Floating panel moved? \n\n\n")
    }
    
    var secondFpc: FloatingPanelController!

    override func show(_ vc: UIViewController, sender: Any?) {
        panel.removePanelFromParent(animated: false, completion: nil)
        secondFpc = FloatingPanelController()
        secondFpc.view.tag = -100
        secondFpc.set(contentViewController: vc)
        secondFpc.addPanel(toParent: self, at: -1, animated: true, completion: nil)
        
    }
    
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(removeNewFloatingPanel), for: .touchUpInside)
        return button
    }()
    
    @objc func removeNewFloatingPanel() {
        
        for cs in self.children {
            if(cs.view.tag == -100) {
                UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    cs.view.removeFromSuperview()
                }, completion: nil)
                
                
                panel.addPanel(toParent: self)
            }
            print("\n\nchild\n\n")
        }

//        secondFpc.removePanelFromParent(animated: true, completion: nil)

//        panel.move(to: .half, animated: false, completion: nil)
//        panel.hide()
//        panel.show(animated: true, completion: nil)
        print("\n\nBUTTON CLICKED\n\n")
    }
    
    func addVC(_ vc: SearchVC) {


//        panel.present(vcc, animated: true, completion: nil)
//        let detailPanel = FloatingPanelController()
//        detailPanel.view.backgroundColor = .green
//        panel.set(contentViewController: detailPanel)
        let vvc = UIViewController()
        vvc.view.backgroundColor = .green
        vvc.view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: vvc.view.leadingAnchor, constant: 15),
            cancelButton.topAnchor.constraint(equalTo: vvc.view.topAnchor, constant: 15)
        ])
        

//        panel.set(contentViewController: vvc)
        

//        panel.addPanel(toParent: self)
        
        show(vvc, sender: nil)
    }
    
    func searchBarClicked(_ vc: SearchVC) {
        panel.move(to: .full, animated: true, completion: nil) //Moves screen down
        print("\n\n Search bar clicked \n\n")
    }
    
    func searchViewController(_ vc: SearchVC, didSelectLocationWith coordinates: CLLocationCoordinate2D?) {
        guard let coordinates = coordinates else {
            print("Invalid coordiantes")
            return
        }
        
        panel.move(to: .tip, animated: true, completion: nil) //Moves screen down
        mapView.removeAnnotations(mapView.annotations)
        
        
        let userLocation = MKPlacemark(coordinate: mapView.userLocation.coordinate)
        let endLocation = MKPlacemark(coordinate: coordinates)
        mapView.addAnnotation(endLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userLocation)
        request.destination = MKMapItem(placemark: endLocation)
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            var c = 1
            for route in unwrappedResponse.routes {
                if (c == 1) {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
                c += 1
            }
        }
        
        //How much we are zooming in is the decimal
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
    }
    
    private func customPin(lat: String, long: String, id: String) {
//      If the map pin already exists, update it's location
        if let pin = myPins[id] {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 2.5) { [self] in
                    let coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                    pin.coordinate = coordinate
                }
            }
        } else {
//          Create a new pin and add it to the map
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            pin.title = "Bird"
            pin.subtitle = "Bus: " + id
            mapView.addAnnotation(pin)
            myPins[id] = pin
        }
    }
    
    //  Send a request every 10 seconds min for getting the bus location.
    func getBusPrediction() {
        let url = URL(string: "https://retro.umoiq.com/service/publicXMLFeed?command=predictions&a=umd&r=104&s=regdrgar_d")
        URLSession.shared.dataTask(with: url!, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print("Error with Bus location prediction request")
                return
            }
            
            let xml = XML.parse(data)
            
            let predictions = xml["body"]["predictions"]["direction"]["prediction"]
            
            //            for prediction in predictions {
            //                print("\n\n\(String(describing: prediction.element?.attributes["minutes"]))\n\n")
            //            }
            
            //            print(des.element?.attributes ?? "")
            //            print(des["direction"].all?.count ?? 0)
            //            print(des.element?.attributes["routeTitle"] ?? "")
        }).resume()
    }
    
    func getCurrentBusLocation(bus_id : String) {
        let url = URL(string: "https://retro.umoiq.com/service/publicXMLFeed?command=vehicleLocation&a=umd&v=" + bus_id)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else {
                print("Error getting live bus data")
                return
            }
            
            let xml = XML.parse(data)
            let predictions = xml["body"]["vehicle"]
            let latitude = predictions.element?.attributes["lat"]
            let longitude = predictions.element?.attributes["lon"]
            let id = predictions.element?.attributes["id"]
            
            if(latitude != nil && longitude != nil && id != nil) {
                //              Create a pin for each bus
                self.customPin(lat: latitude!, long: longitude!, id: id!)
            }
            
        }.resume()
    }
    
    private let customView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: -10, y: -120, width: 160, height: 110)
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 3
        view.tag = 1
        return view
    }()
}

extension MapVC: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let calloutView = customView
        for sub in customView.subviews {
            sub.removeFromSuperview()
        }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label
        label.text = view.annotation?.subtitle ?? "No bus #"
        view.addSubview(calloutView)
        customView.layer.opacity = 0.20
        calloutView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: calloutView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: calloutView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: calloutView.trailingAnchor)
//            calloutView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
//            calloutView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        panel.move(to: .tip, animated: true, completion: nil) //Moves screen down
        self.searchVC.searchBar.resignFirstResponder()
    }
    
//    This don't even work fr
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        for annotation in mapView.selectedAnnotations {
                mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
//            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        if(annotation.title == "Bird") {
            

            // Resize image
            let pinImage = UIImage(named: "bus-icon")
            let size = CGSize(width: 25, height: 25)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            
            annotationView?.image = resizedImage
        } else {
            // Resize image
            let pinImage = UIImage(named: "building-icon")
            let size = CGSize(width: 32, height: 32)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            annotationView?.image = resizedImage
        }
        
        
        
        
//        let cView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        cView.layer.cornerRadius = 50
//        cView.backgroundColor = .blue
//
//        annotationView?.detailCalloutAccessoryView = cView
//        annotationView?.canShowCallout = true
    
        
        return annotationView
    }
}
