//
//  ProfileViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 09.02.23.
//

import UIKit
import SceneKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), landscapeImagePhone: UIImage(systemName: "plus.magnifyingglass"), style: .done, target: self, action: #selector(goToSearch))
        design()
    }
    @objc func goToSearch(){
        let vc = UINavigationController(rootViewController: SearchViewController())
        self.present(vc, animated: true, completion: nil)
    }
    
    private func design(){
        profileBackground.layer.shadowColor = UIColor.black.cgColor
        profileBackground.layer.shadowOpacity = 0.25
        profileBackground.layer.shadowOffset = .zero
        profileBackground.layer.shadowRadius = 4
        profileBackground.layer.shadowPath = UIBezierPath(rect: profileBackground.bounds).cgPath
        profileBackground.layer.shouldRasterize = true
        profileBackground.layer.rasterizationScale = UIScreen.main.scale
    }

    @IBAction func uploadAndChangePFP(_ sender: Any) {
        presentPhotoActionSheet()
    }

}

extension ProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How Would You Like To Select PFP", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler:{ [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Upload Photo", style: .default, handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true )
    }
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true )
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.profilePicture.image = selectedImage
        
        guard let data = selectedImage.pngData() else {
            print("Error: Failed to convert UIImage to PNG data")
            return
        }
        
        let storageManager = StorageManager()
        let userID = Auth.auth().currentUser!.uid // to add to current uid storage
        let fileName = "\(userID)_profile_picture.png"
        

        storageManager.uploadPFP(with: data, fileName: fileName) { result in
            switch result {
            case .success(let downloadUrl):
                print(downloadUrl)
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}
