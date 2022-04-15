//
//  ViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import AVFAudio
import Photos

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    
    private var data: [Result] = []
    private  var songPlayer : AVAudioPlayer?
    private var imageFullScreen = false

    
    private var postManager = PostManager()
    private var K = Constants()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpDelegates()
        setUpNavBar()
        setUpSearchBar()
        setUpCollectionView()
        hideKeyboardWhenTappedAround()
        setUpSound()
        
        postManager.fetchPhotos(query: K.initalFetch)
        
    }
    
    private func setUpCollectionView() {
        collectionView.register(GifCollectionViewCell.nib(), forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = layout
    }
    
    private func setUpSearchBar() {
        self.searchbar.barTintColor = .systemGray
        searchbar.searchTextField.backgroundColor = .systemGray3
    }
    
    private func setUpNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }
    
    private func setUpDelegates() {
        searchbar.delegate = self;
        collectionView.delegate = self
        collectionView.dataSource = self
        postManager.delegate = self
    }
    
    
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        guard let text = searchbar.text  else {return}
        data = []
        collectionView?.reloadData()
        postManager.fetchPhotos(query: text)
        
    }
    
    private func setUpSound() {
        guard let path = Bundle.main.path(forResource: "song", ofType: "wav") else { return }
        let filePath = NSURL(fileURLWithPath:path)
        songPlayer = try! AVAudioPlayer.init(contentsOf: filePath as URL)
        songPlayer?.numberOfLoops = -1 //logic for infinite loop
        songPlayer?.prepareToPlay()
        songPlayer?.play()
        
    }
    
    
}

extension ViewController: PostManagerDelegate {
    
    func didUpdateData(postManager: PostManager, postGifData: Post) {
            DispatchQueue.main.async {
                self.data = postGifData.data
                self.collectionView?.reloadData()
            }
    }
    
}


extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem (at: indexPath) as? GifCollectionViewCell else {
            return
        }
        let gif = cell.imageView.image!
        
        if !imageFullScreen {
            self.addImageViewWithImage(image: gif)
        }
        else {
            removeImage()
        }
    }
    
    @objc func removeImage() {
        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
        imageFullScreen = false
    }
    
    func addImageViewWithImage(image: UIImage) {
        let imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.tag = 100
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(dismissTap)
        self.view.addSubview(imageView)
        imageFullScreen = true
        
    }
        
        
}



extension ViewController: UICollectionViewDataSource, MyTableViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURLString = data[indexPath.row].images.downsized.url
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: imageURLString, session: postManager.session)
        cell.delegate = self
        return cell
    }
    
    func shareImageButton(with data: Data) {
        
        let firstActivityItem: Array = [data]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: firstActivityItem, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    func saveToGalleryButton(with data: Data) {
        let actionSheet = UIAlertController(title: "Save gif to Camera Roll?", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Save!", style: .destructive, handler: {_ in
            
            let refreshAlert = UIAlertController(title: "Yay!", message: "Gif saved to Camera Roll!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            }) { (success, error) in
                if error == nil {
                    return
                }
            }
            self.present(refreshAlert, animated: true, completion: nil)
            
        }
            
        ))
        
        present(actionSheet, animated: true)
        
        
    }
}


// Hide keyboard by touching anywhere
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

