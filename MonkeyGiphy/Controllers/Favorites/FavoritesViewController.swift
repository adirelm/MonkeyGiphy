//
//  FavoritesViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/07/2022.
//

import Foundation
import UIKit
import Combine

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationItem!
    private var subscriptions = Set<AnyCancellable>()
    private let gifAPI = GifAPI.shared()
    
    override func viewDidLoad() {
        setUpNavBar()
        setUpDelegates()
        setUpCollectionView()
        addObservers()
    }
    
    private func setUpDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func addObservers() {
        gifAPI.$favorites.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &subscriptions)
    }
    
    private func setUpCollectionView() {
        collectionView.register(GifCollectionViewCell.nib(), forCellWithReuseIdentifier: GifCollectionViewCell.identifier)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        collectionView.backgroundColor = .white
        collectionView.collectionViewLayout = layout
    }
    
    private func setUpNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemTeal
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = navBar.standardAppearance
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        return gifAPI.favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let favoriteGifData = self.gifAPI.getFavoriteGif(for: indexPath) else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCollectionViewCell.identifier, for: indexPath) as? GifCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureByData(favoriteGif: favoriteGifData)
        return cell
    }
}
