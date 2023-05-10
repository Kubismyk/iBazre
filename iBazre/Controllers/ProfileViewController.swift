//
//  ProfileViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 09.02.23.
//

import UIKit
import SceneKit
import FirebaseAuth
import JGProgressHUD

class ProfileViewController: UIViewController {

    let spinner = JGProgressHUD(style: .dark)
    let mail = UserDefaults.standard.value(forKey: "email") as? String ?? "test@mail.ru"
    
    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = mail
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.magnifyingglass"), landscapeImagePhone: UIImage(systemName: "plus.magnifyingglass"), style: .done, target: self, action: #selector(goToSearch))
        design()
        pfp()
    }
    @objc func goToSearch(){
        let vc = UINavigationController(rootViewController: SearchViewController())
        self.present(vc, animated: true, completion: nil)
    }
    
    
    // functions
    
    private func pfp(){
        print("feth starts here 000 00 0 - - -- - ")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let path = "images/" + uid + "_profile_picture.png"
        
        StorageManager.shared.requestDownload(for: path) { [ weak self ] result in
            switch result {
            case .success(let url):
                self?.donwloadImage(imageView: (self?.profilePicture)!, url: url)
            case .failure(let error):
                print("failed to download pfp: \(error)")
            }
        }
    }
    
    
    func donwloadImage(imageView:UIImageView, url:URL){
        self.spinner.show(in: self.view)
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                
                let image = UIImage(data: data)
                self.profilePicture.image = image
                self.spinner.dismiss(animated: false)
            }
        }.resume()
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
        let safeEmail = DatabaseManager.safeEmail(email: self.mail)
        let fileName = "\(safeEmail)_profile_picture.png"
        

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
