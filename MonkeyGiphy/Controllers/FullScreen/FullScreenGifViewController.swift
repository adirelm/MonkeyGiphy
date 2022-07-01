//
//  FullScreenGifViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 31/05/2022.
//

import UIKit
import Photos

class FullScreenGifViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var lblSuggested: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    private let image: UIImage
    private let data: Data
    private let gifURL: String
    private let postManager = PostManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGifImageView(image: image)
        setUpNavBar()
        setGestures()
        configureImageView()
        configureSuggestedLabel()
        setUpDelegates()
        setUpCollectionView()
        setUpFavoriteBtn()
    }
    
    init?(coder: NSCoder, image: UIImage, data: Data, url: String) {
        self.image = image
        self.data = data
        self.gifURL = url
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpCollectionView() {
        collectionView.register(GifCollectionViewCell.nib(), forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        collectionView.backgroundColor = .black
        collectionView.collectionViewLayout = layout
    }
    
    private func setUpDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setUpFavoriteBtn() {
        if postManager.favorites.contains(where: { url in
            url == gifURL
        }) {
            btnFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        else {
            btnFavorite.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    private func configureSuggestedLabel() {
        lblSuggested.adjustsFontSizeToFitWidth = true
    }
    
    private func configureImageView() {
        self.gifImageView.layer.cornerRadius = 25.0
    }
    
    private func setGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                navigationController?.popToRootViewController(animated: true)
                print("Swiped right")
            default:
                break;
            }
        }
    }
    
    private func setUpNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }
    
    @IBAction func favoriteBtnClicked(_ sender: Any) {
        postManager.modifyFavorites(with: gifURL)
        setUpFavoriteBtn()
    }
    
    @IBAction private func saveToGalleryButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Save gif to Camera Roll?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Save!", style: .destructive, handler: {_ in
            let refreshAlert = UIAlertController(title: "Yay!", message: "Gif saved to Camera Roll!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            PHPhotoLibrary.shared().performChanges({ [weak self] in
                guard let data = self?.data else { return }
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            }) { (success, error) in
                if error == nil {
                    return
                }
            }
            self.present(refreshAlert, animated: true, completion: nil)
        }))
        present(actionSheet, animated: true)
    }
    
    @IBAction private func shareImageButton(_ sender: UIButton) {
        let firstActivityItem: Array = [data]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: firstActivityItem, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    private func configureGifImageView(image: UIImage) {
        self.gifImageView.image = image
    }
    
    @IBAction func didTapBackButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension FullScreenGifViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem (at: indexPath) as? GifCollectionViewCell else { return }
        guard let gifImage = cell.imageView.image else { return }
        guard let gifData = cell.getDataOfCell() else { return }
        guard let gifURL = cell.getGifURLOfCell() else { return }
        
        let fullScreenGifVC = UIStoryboard(name: "FullScreenGif", bundle: .main).instantiateViewController(identifier: "FullScreenGif") { coder in
            FullScreenGifViewController(coder: coder, image: gifImage, data: gifData, url: gifURL)
        }
        navigationController?.pushViewController(fullScreenGifVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let gifURLString = self.postManager.getRandomUrlFromDataSource(for: indexPath) else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: gifURLString, session: self.postManager.session)
        return cell
    }
}
