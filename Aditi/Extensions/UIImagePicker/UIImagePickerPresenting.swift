//
//  ImagePickerPresenting.swift
//
//  Created by Ilker Baltaci on 11.06.18.
//

import Foundation
import AVFoundation
import Photos
import UIKit

private var completionBlock: ((UIImage?) -> Void)?

protocol ImagePickerPresenting: ImagePickerControllerDelegate {
    func presentImagePicker(completion: @escaping (UIImage?) -> Void)
}

extension ImagePickerPresenting where Self: UIViewController {
    
    func presentImagePicker(completion: @escaping (UIImage?) -> Void) {
        
        completionBlock = completion
        let imagePickerViewController = ImagePickerController()
        imagePickerViewController.imagePickerDelegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerViewController.sourceType = .camera
            imagePickerViewController.cameraDevice = .rear
            imagePickerViewController.cameraCaptureMode = .photo
            imagePickerViewController.showsCameraControls = true
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                imagePickerViewController.sourceType = .camera
                self.accessCameraWithReminderPrompt(completion: { (accessGranted) in
                    DispatchQueue.main.async {
                        self.present(imagePickerViewController, animated: true, completion: nil)
                    }
                })
                
            }
            let gallery = UIAlertAction(title: "Choose Photo", style: .default) { (action) in
                imagePickerViewController.sourceType = .photoLibrary
                self.remindToGiveGalleryWithReminderPrompt(completion: { (accessGranted) in
                    DispatchQueue.main.async {
                        self.present(imagePickerViewController, animated: true, completion: nil)
                    }
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                completionBlock = nil
            }
            
            actionSheet.addAction(camera)
            actionSheet.addAction(gallery)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        } else {
            imagePickerViewController.sourceType = .photoLibrary
            imagePickerViewController.imagePickerDelegate = self
            imagePickerViewController.isNavigationBarHidden = false
            imagePickerViewController.isToolbarHidden = true
            self.present(imagePickerViewController, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidFinish(image: UIImage?, _ viewController: ImagePickerController) {
        
        completionBlock?(image)
        completionBlock = nil
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func accessCameraWithReminderPrompt(completion:@escaping (_ accessGranted: Bool)->()) {
        let accessRight = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch accessRight {
        case .authorized:
            completion(true)
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted == true  {
                    completion(true)
                    return
                }
                self.alertCameraAccessNeeded()
            })
        case .denied, .restricted:
            self.alertCameraAccessNeeded()
            
            break
        }
    }
    
    func remindToGiveGalleryWithReminderPrompt(completion:@escaping (_ accessGranted: Bool)->()) {
        
        let accessRight = PHPhotoLibrary.authorizationStatus()
        
        switch accessRight {
        case .authorized:
            completion(true)
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    completion(true)
                    return
                }
                self.alertPhotosAccessNeeded()
            }
        case .denied, .restricted:
            alertPhotosAccessNeeded()
            break
            
        default:
            print("unknown state")
        }
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Access Camera",
            message: "This app wants to access your Camera",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow", style: .cancel, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsAppURL)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func alertPhotosAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Access Photos",
            message: "This app wants to access your Photo Library",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow", style: .cancel, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsAppURL)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
