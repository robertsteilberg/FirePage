//
//  HelpLineViewController.swift
//  FirePage
//
//  Created by Theodore Franceschi on 11/12/17.
//  Copyright © 2017 Theodore Franceschi. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class HelplineViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    
    
    // MARK: Global Variables
    private var cells = [DormCollectionViewCell]()
    private var dormDic = [String:String]()
    private var currDorm = ""
    
    //below will be replaced with db call
    private var dormPhotos = [#imageLiteral(resourceName: "randolph"),#imageLiteral(resourceName: "epworth"),#imageLiteral(resourceName: "wilson"),#imageLiteral(resourceName: "aycock"),#imageLiteral(resourceName: "blackwell")]
    
    
    // MARK: Horizontal Menu
    let cellID = "dormCell"
    @IBOutlet weak var dormMenu: UICollectionView!
    
    // MARK: button status
    private var dormClicked = false;
    private var campusClicked = false;
    private var callClicked = false;
    
    // MARK: Dorm info
    private var selectedDorm = "Epworth"
    private var eastDorms = ["Epworth","East","Randolph","Bell Tower"]

    //This will be replaced by firebase pull
    private var eastPhones = [String]()
    
    // MARK: Campus info
    private var selectedCampus = "East"
    private var campusList = ["East","West"]
    
    // MARK: Outlets
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var subjectField: FireTextField!
    @IBOutlet weak var dormButton: UIButton!
    @IBOutlet weak var campusButton: UIButton!
    @IBOutlet weak var dormLabel: UILabel!
    @IBOutlet weak var campusLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var locationField: FireTextField!
    
    // MARK: Actions
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(slider.value)), animated: true)
        currPhone = self.phoneList[Int(sender.value)]
    }
    
    @IBAction func campusClick(_ sender: Any) {
        self.campusClicked = !self.campusClicked
        self.dormMenu.isHidden = self.campusClicked
        let newImage = self.campusClicked ? #imageLiteral(resourceName: "contract") : #imageLiteral(resourceName: "expand")
        campusButton.setImage(newImage, for: .normal)
    }
    
    @IBAction func dormClick(_ sender: Any) {
        self.dormClicked = !self.dormClicked
        self.dormMenu.isHidden = self.dormClicked
        let newImage = self.dormClicked ? #imageLiteral(resourceName: "contract") : #imageLiteral(resourceName: "expand")
        dormButton.setImage(newImage, for: .normal)
    }

    @IBAction func callClick(_ sender: Any) {
        self.callClicked = !self.callClicked
        //let newImage = self.callClicked ?#imageLiteral(resourceName: "hangup"): #imageLiteral(resourceName: "helpPhone")
        //callButton.setImage(newImage, for: .normal)
        
        if let url = URL(string: "tel://\(currPhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
 
        var dict = Dictionary<String,Any>()
        
        //dict["date"] = getDate()
        //dict["onCallGroup"] = dormDic[currDorm]
        dict["date"] = "12-04-2017"
        dict["onCallGroup"] = "N2Group"
        dict["time"] = getTime()
        dict["isResolved"] = false
        dict["description"] = subjectField.text
        dict["Location"] = "\(currDorm) \(locationField.text ?? "")"
        dict["fromPerson"] = getUserData()["email"]
        
        DB.addHelpRequest(onCallGroup: "N2Group", day: "12-04-2017", helpRequest: HelpRequest(dictionary: dict as NSDictionary))
        
        
        
    }
    
    // MARK: Phone Setup
    private var phoneList = ["5857979725","5857979725","5857979725"]
    private var currPhone: String = ""
    private var handle: AuthStateDidChangeListenerHandle?
    let reuseIdentifier = "dormCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subjectField.useUnderline()
        locationField.useUnderline()
        updateLabels()
        self.currPhone = phoneList[1]
        DB.getDormsMap(reloadFunction: setDormDic)
        /*
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.dormDic = ["Epworth":"N2Group"]
            print("reload me")
            self.eastDorms = []
            self.dormMenu.reloadData()
        }
         */
        dormMenu.reloadData()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissBoard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //Do any additional setup after loading the view.
    }
    
    func setDormDic(dictionary: [String: String]){
        dormDic = dictionary
        //print(dictionary)
        eastDorms = Array(dormDic.keys)
        dormMenu.reloadData()
        cells = [DormCollectionViewCell]()
    }
    
    private func updateLabels(){
        dormLabel.text = self.selectedDorm
        campusLabel.text = self.selectedCampus
    }
    
    @objc func dismissBoard(){
        view.endEditing(true)
    }
    
    
    // MARK: Horizontal Menu functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eastDorms.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("reloaded")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DormCollectionViewCell
        cell.dorm = eastDorms[indexPath.row]
        cell.dormPhoto.image = dormPhotos[indexPath.row]
        cell.dormPhoto.layer.borderWidth = 0
        cell.dormPhoto.layer.masksToBounds = false
        cell.dormPhoto.layer.borderColor = UIColor.black.cgColor
        cell.dormPhoto.layer.cornerRadius = cell.dormPhoto.frame.height/2
        cell.dormPhoto.clipsToBounds = true
        cell.cellNum = "5857979725"
        cell.dormLabel.text = eastDorms[indexPath.row]
        cells.append(cell)
        clearSelected()
        currDorm = cells[0].dorm
        cells[0].dormPhoto.layer.borderWidth = 4.0
        cells[0].dormPhoto.layer.borderColor = UIColor.white.cgColor
        dormLabel.text = currDorm
        
        return cell;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //phoneList[0] = eastPhones[indexPath.row]
        phoneList[0] = "5857979725"
        clearSelected()
        cells[indexPath.row].dormPhoto.layer.borderWidth = 4.0
        cells[indexPath.row].dormPhoto.layer.borderColor = UIColor.white.cgColor
        currDorm = cells[indexPath.row].dorm
        dormLabel.text = currDorm
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Handles Auth for HelpLine
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
        }
        dormMenu.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    private func clearSelected(){
        for cell in cells{
            cell.dormPhoto.layer.borderWidth = 0
        }
    }
    
    private func getDate()->String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    
    private func getTime()->String{
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.hour,.minute,.second], from: date)
        
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(String(hour!)  + ":" + String(minute!) + ":" +  String(second!))
        return today_string
    }
    
    private func getUserData()->[String:String]{
        let user = Auth.auth().currentUser
        var uid = ""
        var email = ""
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            uid = user.uid
            email = user.email!
            // ...
        }
        return ["uid":uid,"email":email]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
