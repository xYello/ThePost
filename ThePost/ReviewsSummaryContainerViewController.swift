//
//  ReviewsSummaryContainerViewController.swift
//  ThePost
//
//  Created by Andrew Robinson on 1/13/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit
import Firebase

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
    
    private var animationFinished = false
    
    var amountOfStars = 0 {
        didSet {
            switch amountOfStars {
            case 1:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                leftMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                righMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            case 2:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                midStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                righMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            case 3:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                righMidStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            case 4:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                righMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                
                farRightStar.tintColor = #colorLiteral(red: 0.7215686275, green: 0.7607843137, blue: 0.7803921569, alpha: 1)
            default:
                farLeftStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                leftMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                midStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                righMidStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
                farRightStar.tintColor = #colorLiteral(red: 0.9529411765, green: 0.6274509804, blue: 0.09803921569, alpha: 1)
            }
        }
    }
    
    var userId: String!
    
    // MARK: - View lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.roundCorners(radius: 8.0)
        view.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
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
        
        grabReviewStats()
        grabReviewerInfo()
        
        grabReviews()
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewSummaryTableViewCell
        let review = reviews[indexPath.row]
        
        cell.reviewUserId = review.reviewerId
        cell.timeLabel.text = review.relativeDate
        
        cell.commentLabel.text = review.comment
        
        cell.amountOfStars = review.rating
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func wantsToClose(_ sender: UIButton) {
        dismissParent()
    }
    
    func parentAnimatorDidFinish() {
        animationFinished = true
        
        farLeftBar.animateValueChanges()
        leftMidBar.animateValueChanges()
        midBar.animateValueChanges()
        rightMidBar.animateValueChanges()
        farRightBar.animateValueChanges()
    }
    
    // MARK: - Helpers
    
    private func dismissParent() {
        if let parent = parent as? ReviewsSummaryViewController {
            parent.prepareForDismissal {
                parent.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - Firebase
    
    private func grabReviewStats() {
        let ref = FIRDatabase.database().reference().child("reviews").child(userId).child("reviewNumbers")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let numbers = snapshot.value as? [String: Int] {
                let count = numbers["count"]!
                let number = Double(numbers["sum"]!) / Double(count)
                let roundedNumber = number.roundTo(places: 1)
                
                self.determineStarsfor(number: roundedNumber)
                
                DispatchQueue.main.async {
                    self.userRatingLabel.text = "\(roundedNumber)"
                    
                    self.farLeftBar.value = CGFloat(numbers["oneStars"]!) / CGFloat(count)
                    self.leftMidBar.value = CGFloat(numbers["twoStars"]!) / CGFloat(count)
                    self.midBar.value = CGFloat(numbers["threeStars"]!) / CGFloat(count)
                    self.rightMidBar.value = CGFloat(numbers["fourStars"]!) / CGFloat(count)
                    self.farRightBar.value = CGFloat(numbers["fiveStars"]!) / CGFloat(count)
                    
                    if self.animationFinished {
                        self.parentAnimatorDidFinish()
                    }
                    
                    self.farLeftStarLabel.text = "\(numbers["oneStars"]!)"
                    self.leftMidStarLabel.text = "\(numbers["twoStars"]!)"
                    self.midStarLabel.text = "\(numbers["threeStars"]!)"
                    self.rightMidStarLabel.text = "\(numbers["fourStars"]!)"
                    self.farRightStarLabel.text = "\(numbers["fiveStars"]!)"
                    
                    self.totalReviewsLabel.text = "\(count)"
                }
            }
        })
    }
    
    private func determineStarsfor(number: Double) {
        let wholeNumber = Int(number)
        var starsToTurnOn = wholeNumber
        
        if number - Double(wholeNumber) >= 0.9 {
            starsToTurnOn += 1
        }
        
        amountOfStars = starsToTurnOn
    }
    
    private func grabReviewerInfo() {
        let userRef = FIRDatabase.database().reference().child("users").child(userId).child("fullName")
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String {
                self.profileNameLabel.text = name
            }
        })
    }
    
    private func grabReviews() {
        let ref = FIRDatabase.database().reference().child("reviews").child(userId)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let reviews = snapshot.value as? [String: AnyObject] {
                
                for (_, value) in reviews {
                    if let review = value as? [String: AnyObject] {
                        if let comment = review["comment"] as? String, let rating = review["rating"] as? Int, let reviewerId = review["reviewerId"] as? String, let time = review["timeReviewed"] as? String {
                            
                            let newReview = Review()
                            newReview.comment = comment
                            newReview.rating = rating
                            newReview.reviewerId = reviewerId
                            newReview.timePostedString = time
                            
                            self.reviews.append(newReview)
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        })
    }
    
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
