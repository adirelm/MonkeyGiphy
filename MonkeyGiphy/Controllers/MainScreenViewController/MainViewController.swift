//
//  ViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import AVFAudio
import Photos

enum GifSection: Int {
    case main
}

class MainViewController: UIViewController, UISearchBarDelegate {
    typealias DataSource = UICollectionViewDiffableDataSource<GifSection, GifData.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<GifSection, GifData.ID>
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    private lazy var searchController = setUpSearchController()
    private lazy var dataSource = makeDataSource()
    
    private var songPlayer: AVAudioPlayer?
    private var postManager = PostManager()
    private let defaultVal = "Cartoon"
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
        setUpNavBar()
        setUpCollectionView()
        hideKeyboardWhenTappedAround()
        setUpSound()
        postManager.fetchPhotos(query: defaultVal)
    }
    
    //MARK: - Diffable DataSource
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, gifID) in
            
            guard let self = self else { return UICollectionViewCell() }

            if self.postManager.isLoading {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingIndicatorCollectionViewCell.identifier, for: indexPath) as? LoadingIndicatorCollectionViewCell else { return UICollectionViewCell() }
                cell.activityIndicator.startAnimating()
                return cell
            }
            
            let gifURLString = self.postManager.getGifUrlByIndexPath(for: indexPath)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: gifURLString, session: self.postManager.session)
            cell.delegate = self
            return cell
        }
        return dataSource
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(postManager.data.map{$0.id}, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setUpSearchController() -> UISearchController {
        let searchController = UISearchController()
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "e.g 'Monkey'"
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.tintColor = .white
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.delegate = self
        return searchController
    }
    
    private func setUpCollectionView() {
        collectionView.register(GifCollectionViewCell.nib(), forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        collectionView.register(LoadingIndicatorCollectionViewCell.nib(), forCellWithReuseIdentifier: LoadingIndicatorCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = layout
    }
    
    private func setUpNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setUpDelegates() {
        collectionView.delegate = self
        postManager.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text  else { return }
        postManager.modifyDataSource(with: nil)
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

extension MainViewController: PostManagerDelegate {
    func didUpdateData(postManager: PostManager?, postGifData: GiphyResponse) {
        guard let postManager = postManager else { return }
        DispatchQueue.main.async {
            postManager.modifyDataSource(with: postGifData.data)
            self.applySnapshot()
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem (at: indexPath) as? GifCollectionViewCell else { return }
        guard let gif = cell.imageView.image else { return }
        guard let gifData = cell.getDataOfCell() else { return }
        
        let fullScreenGifVC = UIStoryboard(name: "FullScreenGif", bundle: .main).instantiateViewController(identifier: "FullScreenGif") { coder in
            FullScreenGifViewController(coder: coder, image: gif, data: gifData)
        }
        navigationController?.pushViewController(fullScreenGifVC, animated: true)
    }
}

extension MainViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        postManager.isLoading ? postManager.data.count + 1 : postManager.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == postManager.data.count - 2 else { return }
        guard let searchText = searchController.searchBar.text else { return }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            postManager.fetchPhotos(query: searchText)
            return
        } else { postManager.fetchPhotos(query: defaultVal) }
    }
}

extension MainViewController: MyTableViewDelegate {
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
        }))
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

