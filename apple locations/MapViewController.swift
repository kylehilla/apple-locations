//
//  MapViewController.swift
//  apple locations
//
//  Created by Kyle Hilla on 12/30/22.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    private var locationArray = [LocationData]()
    
    var selectedLocationData: LocationData?
    var selectedAnnotation = MKAnnotationView()
    
    var isPinCentering = false
    
    var storeImage = UIImage()
    
    let locationManager = CLLocationManager()
    
    var activityView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    private var currentLocation: CLLocation?
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    var hasShownAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView(style: .medium)
        self.activityIndicator.color = .systemBlue
        self.activityIndicator.hidesWhenStopped = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(deselectAnnotation), name: Notification.Name("deselectAnnotation"), object: nil)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        /* Warning/Error loop: If CLLocationManager is changed to locationManager there is an error
        "Static member 'authorizationStatus' cannot be used on instance of type 'CLLocationManager'"
         The Fix-It correction is to change locationManager to CLLocationManager. */
        
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                currentLocation = locationManager.location
            
                break
            case .denied:
                break
            
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            
            case .restricted:
                break
            
            case .authorizedAlways:
                break
            
            @unknown default:
                print("Critical error")
        }
        
        let urlString = "https://gist.githubusercontent.com/kylehilla/28e0fc38214766560a5d83a93020f4f5/raw/594a6d05cac7f3eae5bfdd7183d33f66aed9bbe1/apple_store.json"
                
        MapManager.shared.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                MapManager.shared.parse(jsonData: data)
                
                self.locationArray = MapManager.shared.locationArray
                
                DispatchQueue.main.async {
                    self.dropLocationPins()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func deselectAnnotation() {
        self.locationMapView?.deselectAnnotation(self.selectedAnnotation as? MKAnnotation, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] as CLLocation

        let center = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
        
        locationMapView.setRegion(region, animated: false)
        
        currentLocation = locationManager.location
        
        locationManager.stopUpdatingLocation()
    }
    
    func dropLocationPins() {
        for locationData in locationArray {
            
            let lat = locationData.latitude
            let lon = locationData.longitude
            
            let storeCoorinates = CLLocation(latitude: lat, longitude: lon)

            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.title = locationData.location
            
            locationMapView.addAnnotation(annotation)
            
            let distance = currentLocation?.distance(from: storeCoorinates)
            
            if distance != nil && distance ?? 0.0 <= 1609.34 {
                if hasShownAlert == false {
                    hasShownAlert = true
                    
                    proximityAlert(location: locationData.location)
                }
            }
        }
    }
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Store"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            containerView.backgroundColor = .white.withAlphaComponent(0.9)
            containerView.layer.cornerRadius = containerView.frame.size.width/2
            
            let imageView =  UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 36))
            imageView.image = UIImage(systemName: "apple.logo")
            imageView.center = containerView.center
            containerView.center = annotationView?.center ?? CGPoint()
            
            annotationView?.calloutOffset = CGPoint(x: -15, y: -containerView.frame.size.width/2)
        
            containerView.addSubview(imageView)
            annotationView?.addSubview(containerView)
            
            // Show info button to segue to details... Part I
//            let button = UIButton(type: .detailDisclosure)
//            annotationView?.rightCalloutAccessoryView = button
        }
        else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    func proximityAlert(location: String) {
        let alertController = UIAlertController(title: "You're close!", message: "You're about 1 mile from \(location).", preferredStyle: .alert)
                   
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: {_ in
            self.hasShownAlert = false
        })
                   
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for locationData in locationArray {
            if locationData.location == view.annotation?.title {
                selectedLocationData = locationData
            
                if view.isKind(of: MKAnnotationView.self) {
                    if !self.isPinCentering {
                        self.isPinCentering = true
                        centerMapOnSelectedAnnotation(mapView, view: view, locationData: selectedLocationData!)
                    }
                    else {
                        self.isPinCentering = false
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self) {
            if !self.isPinCentering {
                view.canShowCallout = false
            }
        }
    }
    
    // Show info button to segue to details... Part II
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        self.performSegue(withIdentifier: "StoreInfo", sender: self)
//    }
    
    func centerMapOnSelectedAnnotation(_ mapView: MKMapView, view: MKAnnotationView, locationData: LocationData) {
        let centerCoordinates = CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)

        let offset = UIOffset(horizontal: 0, vertical: 180)
        var point: CGPoint = mapView.convert(centerCoordinates, toPointTo: mapView)

        point.x += offset.horizontal
        point.y += offset.vertical

        let newCenter = mapView.convert(point, toCoordinateFrom: mapView)

        UIView.animate(withDuration: 0.8) {
            self.locationMapView.setCenter(CLLocationCoordinate2D(latitude: newCenter.latitude, longitude: newCenter.longitude), animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                self.activityView = UIView(frame: CGRect(x: -25, y: -25, width: 50, height: 50))
                self.activityView.backgroundColor = .white.withAlphaComponent(0.9)
                self.activityView.layer.cornerRadius = (self.activityView.frame.size.width )/2
                
                self.activityIndicator.center = self.activityView.convert(self.activityView.center, from: view)
                
                self.activityView.addSubview(self.activityIndicator)
                view.addSubview(self.activityView)
                
                self.activityIndicator.startAnimating()
                
                UIView.animate(withDuration: 0.2) {
                    self.activityView.alpha = 1.0
                }
            }
        }
        
        view.canShowCallout = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            mapView.selectAnnotation(view.annotation!, animated: true)
        }

        if let url = URL(string: locationData.imageURL) {
            MapManager.shared.getData(from: url) { data,_,_ in
                self.storeImage = UIImage(data: data!) ?? UIImage()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.performSegue(withIdentifier: "StoreInfo", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StoreInfo" {
            if let destinationController = segue.destination as? SheetViewController {
                destinationController.storeData = selectedLocationData
                destinationController.storeImage = storeImage
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2) {
                        self.activityView?.alpha = 1.0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.activityIndicator.stopAnimating()
                            self.activityView?.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
}

