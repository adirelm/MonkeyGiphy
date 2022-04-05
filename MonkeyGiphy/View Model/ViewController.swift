//
//  ViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import AVFAudio

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    var data: [Result] = []
    var songPlayer : AVAudioPlayer?
    var imageFullScreen = false
    @IBOutlet weak var navBar: UINavigationItem!
    
    var postManager = PostManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar modify
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance

        // Search bar modify
        self.searchbar.barTintColor = .systemGray
        searchbar.searchTextField.backgroundColor = .systemGray3
        
        
        searchbar.delegate = self;
        collectionView.delegate = self
        collectionView.dataSource = self
        postManager.delegate = self
        
        
        collectionView.register(GifCollectionViewCell.nib(), forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = layout
        
        
        self.hideKeyboardWhenTappedAround()
        SetUpSound()
        postManager.fetchPhotos(query: "Cartoon")
        
    }
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        if let text = searchbar.text {
            data = []
            collectionView?.reloadData()
            postManager.fetchPhotos(query: text)
        }
    }
    
    func SetUpSound() {
        if let path = Bundle.main.path(forResource: "song", ofType: "wav") {
            let filePath = NSURL(fileURLWithPath:path)
            songPlayer = try! AVAudioPlayer.init(contentsOf: filePath as URL)
            songPlayer?.numberOfLoops = -1 //logic for infinite loop
            songPlayer?.prepareToPlay()
            songPlayer?.play()
        }
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
        
        cell.delegate = self
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

