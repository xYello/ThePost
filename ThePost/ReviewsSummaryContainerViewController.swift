//
//  ReviewsSummaryContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/13/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ReviewsSummaryContainerViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var userRatingLabel: UILabel!
    
    @IBOutlet weak var farLeftStar: UIImageView!
    @IBOutlet weak var leftMidStar: UIImageView!
    @IBOutlet weak var midStar: UIImageView!
    @IBOutlet weak var righMidStar: UIImageView!
    @IBOutlet weak var farRightStar: UIImageView!
    
    @IBOutlet weak var farLeftBar: PercentageBar!
    @IBOutlet weak var leftMidBar: PercentageBar!
    @IBOutlet weak var midBar: PercentageBar!
    @IBOutlet weak var rightMidBar: PercentageBar!
    @IBOutlet weak var farRightBar: PercentageBar!
    
    @IBOutlet var bottomBarStars: [UIImageView]!
    
    @IBOutlet weak var farLeftStarLabel: UILabel!
    @IBOutlet weak var leftMidStarLabel: UILabel!
    @IBOutlet weak var midStarLabel: UILabel!
    @IBOutlet weak var rightMidStarLabel: UILabel!
    @IBOutlet weak var farRightStarLabel: UILabel!
    
    @IBOutlet weak var totalReviewsLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    private var reviews: [Review] = []
    
    var userId: String!
    
    // MARK: - View lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.roundCorners(radius: 8.0)
        view.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        userRatingLabel.text = "3.9"
        farLeftStarLabel.text = "11"
        totalReviewsLabel.text = "39"
        profileNameLabel.text = "Ethan Andrews"
        
        for imageView in bottomBarStars {
            imageView.image = UIImage(named: "ProfileReviewsStar")!.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.8235294118, alpha: 1)
        }
        
        let stars: [UIImageView] = [farLeftStar, leftMidStar, midStar, righMidStar, farRightStar]
        for star in stars {
            star.image = UIImage(named: "ProfileReviewsStar")!.withRenderingMode(.alwaysTemplate)
            star.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
        }
        
        farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
        
        closeButton.layer.borderColor = closeButton.titleLabel!.textColor.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.roundCorners(radius: 8.0)
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reviews.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewSummaryTableViewCell
        
        cell.reviewerNameLabel.text = "ThisIsSome ReallyLongTextEvenLongerText"
        cell.timeLabel.text = "3 days ago"
        
        cell.commentLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut eget imperdiet neque. Suspendisse luctus mattis cursus."
        
        cell.locationLabel.text = "Joplin, MO"
        
        cell.amountOfStars = 3
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func wantsToClose(_ sender: UIButton) {
        dismissParent()
    }
    
    func parentAnimatorDidFinish() {
        farLeftBar.value = 11.0 / 39.0
        leftMidBar.value = 11.0 / 39.0
        midBar.value = 11.0 / 39.0
        rightMidBar.value = 11.0 / 39.0
        farRightBar.value = 11.0 / 39.0
    }
    
    // MARK: - Helpers
    
    private func dismissParent() {
        if let parent = parent as? ReviewsSummaryViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}
