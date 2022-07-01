//
//  ViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import AVFAudio
import Photos

enum TrendingButtonStatus {
    case trending
    case other
}

enum GifSection: Int {
    case main
}

class MainViewController: UIViewController, UISearchBarDelegate {
    typealias DataSource = UICollectionViewDiffableDataSource<GifSection, GifData.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<GifSection, GifData.ID>
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var trendingBtn: UIButton!
    
    private lazy var searchController = setUpSearchController()
    private lazy var dataSource = makeDataSource()
    
    private var songPlayer: AVAudioPlayer?
    private var postManager = PostManager.shared()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegates()
        setUpNavBar()
        setUpCollectionView()
        hideKeyboardWhenTappedAround()
//        setUpSound()
        setButtonAttributes(buttonStatus: .trending)
        postManager.fetchPhotos(fetchType: .trending, isPagination: false)
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
            
            guard let gifURLString = self.postManager.getGifUrlByIndexPathFromDataSource(for: indexPath) else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: gifURLString, session: self.postManager.session)
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
    
    private func setUpSearchController() -> UISearchController {
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
    
    private func setUpSound() {
        guard let path = Bundle.main.path(forResource: "song", ofType: "wav") else { return }
        let filePath = NSURL(fileURLWithPath:path)
        songPlayer = try! AVAudioPlayer.init(contentsOf: filePath as URL)
        songPlayer?.numberOfLoops = -1 //logic for infinite loop
        songPlayer?.prepareToPlay()
        songPlayer?.play()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text  else { return }
        postManager.modifyDataSource(with: nil)
        postManager.fetchPhotosBySearch(query: text, isPagination: false)
        setButtonAttributes(buttonStatus: .other)
    }
    
    func setButtonAttributes(buttonStatus: TrendingButtonStatus) {
        let font = UIFont(name: "HelveticaNeue-Bold", size: 14)!
        switch buttonStatus {
        case .trending:
            trendingBtn.setAttributedTitle(NSAttributedString(string: "👇🏻 TRENDING GIFS! 👇🏻", attributes: [NSAttributedString.Key.font: font]), for: .normal)
            trendingBtn.tintColor = .systemGreen
            
        case .other:
            trendingBtn.setAttributedTitle(NSAttributedString(string: "CLICK FOR TRENDING GIFS!", attributes: [NSAttributedString.Key.font: font]), for: .normal)
            trendingBtn.tintColor = .systemBlue
        }
    }
    
    @IBAction func trendingBtnClicked(_ sender: UIButton) {
        if trendingBtn.tintColor == .systemBlue {
            postManager.modifyDataSource(with: nil)
            postManager.fetchPhotos(fetchType: .trending, isPagination: false)
            setButtonAttributes(buttonStatus: .trending)
            searchController.searchBar.text = ""
        }
    }
}

extension MainViewController: PostManagerDelegate {
    func didUpdateData(postManager: PostManager?, postGifData: GiphyResponse) {
        guard let postManager = postManager else { return }
        DispatchQueue.main.async { [weak self] in
            postManager.modifyDataSource(with: postGifData.data)
            self?.applySnapshot()
        }
    }
    
    func handleScrollToTop() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.setContentOffset(.zero, animated: true)
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
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
        postManager.isLoading ? postManager.data.count + 1 : postManager.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == postManager.data.count - 2 else { return }
        guard let searchText = searchController.searchBar.text else { return }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            postManager.fetchPhotosBySearch(query: searchText, isPagination: true)
            return
        } else { postManager.fetchPhotos(fetchType: .trending, isPagination: true) }
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

