//
//  ViewController.swift
//  Solidtech
//
//  Created by Mohamad Hammoud on 10/16/21.
//

import UIKit
import Kingfisher
import GoogleMobileAds

class ViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerView: UIView!

    var array = [[String: Any]]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        if UserDefaults.standard.bool(forKey: "ads")
        {
            self.adBannerView.isHidden = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        self.getRecipes()
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
    
    func getRecipes()
    {
        let url = URL(string: "http://testtask.solidtechapps.com/api/v1/response/")
        var request = URLRequest(url:url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with:request){ (data, response, error) in
            if error != nil
            {
            }
            else
            {
                do
                {
                    let dic = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                    self.array = dic?.value(forKey: "AllFoods") as! [[String : Any]]
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let error as NSError
                {
                    print(error)
                }
            }
            }.resume()
    }
    
}

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let item = self.array[indexPath.row] as [String: Any]
        let receipes = item["receipes"] as! [[String: Any]]
        let row = CGFloat(receipes.count/2).rounded(.up)
        
        return CGFloat(row * 250)
    }
}

extension ViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)

        let item = self.array[indexPath.section] as [String: Any]
        let receipes = item["receipes"] as! [[String: Any]]
        let row = CGFloat(receipes.count/2).rounded(.up)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: CGFloat(row * 250)), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ReceipeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ReceipeCollectionCell")
        
        collectionView.tag = indexPath.section
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        
        cell?.contentView.addSubview(collectionView)

        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let item = self.array[section] as [String: Any]

        return item["categoryName"] as? String
    }
}

extension ViewController: UICollectionViewDelegate
{
}

extension ViewController:UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (collectionView.frame.width-3*10)/2, height: 250)
    }
}

extension ViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let tag = collectionView.tag
        let item = self.array[tag] as [String: Any]
        let receipes = item["receipes"] as! [[String: Any]]
        
        return receipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReceipeCollectionCell", for: indexPath) as! ReceipeCollectionCell
        
        let tag = collectionView.tag
        let item = self.array[tag] as [String: Any]
        let receipes = item["receipes"] as! [[String: Any]]
        let receipe = receipes[indexPath.row]
        
        cell.titleLabel.text = receipe["name"] as? String
        cell.dateLabel.text = receipe["timetoprepare"] as? String
        cell.descriptionLabel.text = receipe["smalldescription"] as? String
        let imageurl = receipe["imageurl"] as? String
        let url = URL(string: imageurl!.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!)
        cell.imageView.kf.setImage(with: url)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let previewViewController = storyboard.instantiateViewController(withIdentifier: "preview") as! PreviewViewController
        let tag = collectionView.tag
        let item = self.array[tag] as [String: Any]
        let receipes = item["receipes"] as! [[String: Any]]
        let receipe = receipes[indexPath.row]
        previewViewController.receipe = receipe
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension ViewController: GADBannerViewDelegate
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
