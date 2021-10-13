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

class MapVC: UIViewController, SearchVCDelegate, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let panel = FloatingPanelController()
    let locationManager = CLLocationManager()
    let searchVC = SearchVC()
    var req = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        title = "UMD"
        mapView.delegate = self
        searchVC.delegate = self
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        getBusPrediction()
        Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
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
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
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
                    self.req += 1
                    self.searchVC.responseCounter.text = "Count \(req)"
                    //                    self.title = "UMD \(seconds)"
                    let coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                    pin.coordinate = coordinate
                }
            }
        } else {
//          Create a new pin and add it to the map
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            pin.title = "Bird"
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
        view.frame = CGRect(x: 0, y: -50, width: 50, height: 30)
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.layer.cornerRadius = 20
        view.tag = 1
        return view
    }()
}

extension MapVC: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let calloutView = customView
        view.addSubview(calloutView)
        NSLayoutConstraint.activate([
            calloutView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            calloutView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
            annotationView?.backgroundColor = .green
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
            let size = CGSize(width: 25, height: 25)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            annotationView?.image = resizedImage
        }
        
        annotationView?.canShowCallout = false
        
//        let cView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        cView.layer.cornerRadius = 50
//        cView.backgroundColor = .blue
//
//        annotationView?.detailCalloutAccessoryView = cView
//        annotationView?.canShowCallout = true
        
        
        
        //        annotationView?.image = UIImage(named: "building-icon")
        
        
        return annotationView
    }
}
