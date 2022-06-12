//
//  LoadingIndicatorCollectionViewCell.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 09/06/2022.
//

import UIKit

class LoadingIndicatorCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "LoadingIndicatorCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static let identifier = "LoadingIndicatorCollectionViewCell"

}
