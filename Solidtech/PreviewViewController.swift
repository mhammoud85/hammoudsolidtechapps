//
//  PreviewViewController.swift
//  Solidtech
//
//  Created by Mohamad Hammoud on 10/16/21.
//

import UIKit
import Kingfisher
import GoogleMobileAds

class PreviewViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var adBannerView: UIView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    {
        didSet {
            var frame = CGRect.zero
            frame.size.height = .leastNormalMagnitude
            ingredientsTableView.tableHeaderView = UIView(frame: frame)
            ingredientsTableView.tableFooterView = UIView(frame: frame)
        }
    }
    @IBOutlet weak var directionsTableView: UITableView!
    {
        didSet {
            var frame = CGRect.zero
            frame.size.height = .leastNormalMagnitude
            directionsTableView.tableHeaderView = UIView(frame: frame)
            directionsTableView.tableFooterView = UIView(frame: frame)
        }
    }
    @IBOutlet weak var ingredientsTableHeight : NSLayoutConstraint!
    @IBOutlet weak var directionsTableHeight : NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight : NSLayoutConstraint!

    var receipe = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = self.receipe["name"] as? String
        
        let ingredients = self.receipe["ingredients"] as! [String]
        self.ingredientsTableHeight.constant = CGFloat(ingredients.count * 44)
        
        let steps = self.receipe["steps"] as! [String]
        self.directionsTableHeight.constant = CGFloat(steps.count * 150)

        self.contentViewHeight.constant = self.ingredientsTableHeight.constant + self.directionsTableHeight.constant + 300
        
        if UserDefaults.standard.bool(forKey: "ads")
        {
            self.adBannerView.isHidden = true
        }
        
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        let imageurl = self.receipe["imageurl"] as? String
        let url = URL(string: imageurl!.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!)
        self.imageView.kf.setImage(with: url)
    }

    @IBAction func onRemoveAds(_ sender: Any)
    {
        self.adBannerView.isHidden = true
        UserDefaults.standard.set(true, forKey: "ads")
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView)
    {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.adBannerView.addSubview(bannerView)
        self.adBannerView.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self.adBannerView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: self.adBannerView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
}

extension PreviewViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.ingredientsTableView
        {
            return 44
        }
        
        return 150
    }
}

extension PreviewViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.ingredientsTableView
        {
            let ingredients = self.receipe["ingredients"] as! [String]
            
            return ingredients.count
        }
        let steps = self.receipe["steps"] as! [String]
        
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        }
        
        if tableView == self.ingredientsTableView
        {
            let ingredients = self.receipe["ingredients"] as! [String]
            let item = ingredients[indexPath.row]
            
            cell?.textLabel?.text = "- \(item)"
        }
        else
        {
            let steps = self.receipe["steps"] as! [String]
            let item = steps[indexPath.row]
            
            cell?.textLabel?.text = "Step \(indexPath.row + 1)"
            cell?.detailTextLabel?.text = item
            cell?.detailTextLabel?.numberOfLines = 8
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if tableView == self.ingredientsTableView
        {
            return "Ingredients"
        }
        return ""
    }
}


extension PreviewViewController: GADBannerViewDelegate
{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      addBannerViewToView(bannerView)
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
