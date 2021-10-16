//
//  ReceipeCollectionCell.swift
//  Solidtech
//
//  Created by Mohamad Hammoud on 10/16/21.
//

import UIKit

class ReceipeCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
}
