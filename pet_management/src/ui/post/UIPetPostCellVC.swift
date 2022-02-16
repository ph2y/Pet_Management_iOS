//
//  UIPetPostCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/16.
//

import UIKit

class UIPetPostCellVC: UITableViewCell {
    @IBOutlet weak var petImage: UIImageView!;
    @IBOutlet weak var authorAndPetNameLabel: UILabel!;
    @IBOutlet weak var contentTextView: UITextView!;
    @IBOutlet weak var postTagLabel: UILabel!;
    @IBOutlet weak var attachmentFileBtn: UIButton!;
    @IBOutlet weak var commentBtn: UIButton!;
    @IBOutlet weak var likeBtn: UIButton!;
    
    var post: Post?;
    
    
    // Action Methods
    @IBAction func attachementFileBtnOnClick(_ sender: UIButton) {
    }
    @IBAction func commentBtnOnClick(_ sender: UIButton) {
    }
    @IBAction func likeBtnOnClick(_ sender: UIButton) {
    }
}
