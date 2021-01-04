//
//  ViewController.swift
//  hhotdog-or-not
//
//  Created by Paweł Kozioł on 27/12/2020.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraItem: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    private let config = MLModelConfiguration()
    
    private let textAttributesStart = [NSAttributedString.Key.foregroundColor:UIColor.systemOrange,
                                       NSAttributedString.Key.font:UIFont(name: "Futura-Bold", size: 26)
    ]
    private let textAttributesGreen = [NSAttributedString.Key.foregroundColor:UIColor.black,
                                       NSAttributedString.Key.font:UIFont(name: "Futura-Bold", size: 26)
    ]
    private let textAttributesRed = [NSAttributedString.Key.foregroundColor:UIColor.white,
                                     NSAttributedString.Key.font:UIFont(name: "Futura-Bold", size: 26)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        navigationController?.navigationBar.titleTextAttributes = textAttributesStart as [NSAttributedString.Key : Any]
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage.")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: config).model) else {
            fatalError ("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { [self] (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = .green
                    self.navigationController?.navigationBar.titleTextAttributes = textAttributesGreen as [NSAttributedString.Key : Any]
                    
                    UIApplication.shared.statusBarStyle = .darkContent
                    cameraItem.tintColor = .black
                    
                } else {
                    self.navigationItem.title = "Not hotdog!"
                    self.navigationController?.navigationBar.barTintColor = .red
                    self.navigationController?.navigationBar.titleTextAttributes = textAttributesRed as [NSAttributedString.Key : Any]
                    
                    UIApplication.shared.statusBarStyle = .lightContent
                    cameraItem.tintColor = .white
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true , completion: nil)
    }
    
}

