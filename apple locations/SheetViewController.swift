//
//  SheetViewController.swift
//  apple locations
//
//  Created by Kyle Hilla on 1/4/23.
//

import UIKit
import MapKit

class SheetViewController: UIViewController, UITextViewDelegate {

    var storeData: LocationData?
    
    var storeImage = UIImage()
    
    @IBOutlet weak var storeImageView: UIImageView!
    
    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var addressLabel1: UILabel!
    @IBOutlet weak var addressLabel2: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    
    @IBOutlet weak var storeMapView: MKMapView!
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Width = %i", self.view.frame.size.width)

        if UIDevice.current.hasNotch {
            // next https://www.createwithswift.com/using-a-uisheetpresentationcontroller-in-swiftui/
            if let presentationController = presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
                presentationController.prefersGrabberVisible = true
                presentationController.preferredCornerRadius = 22
                
                // Allow background map interaction... maybe later, more work to support
//                presentationController.largestUndimmedDetentIdentifier = .medium
            }
        }
        
        storeLabel.text = storeData?.location

        addressLabel1.text = (storeData?.address ?? "")
        addressLabel2.text = (storeData?.city ?? "") + ", " + (storeData?.state ?? "") + " " + String(describing: storeData?.zipCode ?? 0)
        
        phoneButton.setTitle(storeData?.phone, for: .normal)
        
        DispatchQueue.main.async {
            self.storeImageView.image = self.storeImage
        }
        
        let region = MKCoordinateRegion( center: CLLocationCoordinate2D(latitude: storeData!.latitude, longitude: storeData!.longitude), latitudinalMeters: CLLocationDistance(exactly: 1300)!, longitudinalMeters: CLLocationDistance(exactly: 1300)!)
        
        storeMapView.setRegion(storeMapView.regionThatFits(region), animated: true)
        storeMapView.layer.cornerRadius = 22

        directionsTextView.text = storeData?.details
        directionsTextView.textContainer.lineBreakMode = .byTruncatingTail
//        
//        if !UIDevice.current.hasNotch {
//            directionsTextView.removeFromSuperview()
//        }
        
//        switch view.frame.size.width {
//        case 375:
//            textSize(storeSize: 21.0, addressSize: 18.0)
//
//        default:
//            break
//        }
    }
    
    func textSize(storeSize: CGFloat, addressSize: CGFloat) {
        storeLabel.font = storeLabel.font.withSize(storeSize)
        addressLabel1.font = addressLabel1.font.withSize(addressSize)
        addressLabel2.font = addressLabel2.font.withSize(addressSize)
    }
    
    @IBAction func callStore(_ sender: Any) {
        if let storePhone = storeData?.phone {
            var phoneNumber = storePhone.components(separatedBy: ["(", ")", "-", " "]).joined()
            phoneNumber = "tel://" + phoneNumber

            UIApplication.shared.open(URL(string: phoneNumber)!)
        }
    }
    
    @IBAction func openMaps(_ sender: Any) {
        let alertController = UIAlertController(title: "Open for directions", message: "in Apple Maps?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel"), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: "get directions"), style: .`default`, handler: { _ in
            if let storeMap = self.storeData?.mapURL {
                UIApplication.shared.open(URL(string: storeMap)!)
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("deselectAnnotation"), object: nil)
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
