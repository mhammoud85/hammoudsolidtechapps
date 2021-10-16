//
//  ViewController.swift
//  Solidtech
//
//  Created by Mohamad Hammoud on 10/16/21.
//

import UIKit
import Kingfisher

class ViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!

    var array = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getRecipes()
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
        return 280
    }
}

extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)

        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 280), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ReceipeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ReceipeCollectionCell")
        
        collectionView.tag = indexPath.row
        collectionView.backgroundColor = .white
        
        cell?.contentView.addSubview(collectionView)
        
        return cell!
    }
}

extension ViewController: UICollectionViewDelegate
{
}

extension ViewController:UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (collectionView.frame.width-3*5)/2, height: collectionView.frame.height)
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
}
