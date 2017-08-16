//
//  FirstViewController.swift
//  School Planner
//
//  Created by Nick Allaire on 12/15/16.
//  Copyright © 2016 Nick Allaire. All rights reserved.
//
//
//  FirstViewController.swift
//  School Planner
//
//  Created by Nick Allaire on 12/15/16.
//  Copyright © 2016 Nick Allaire. All rights reserved.
//


import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addClassButton: UIButton!
    @IBOutlet weak var listOfClasses: UITableView!
    @IBOutlet weak var classTextEdit: UITextField!
    @IBOutlet weak var classDayTime: UITextField!
    @IBOutlet weak var classLocation: UITextField!
    
    var tableData = [String]()
    let thirdViewSegue = "segueToTabController"
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UINavigationBar.appearance()
        app.barTintColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
        app.isTranslucent = false
        app.barStyle = .black
        app.tintColor = .white
        app.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        self.listOfClasses.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.listOfClasses.delegate = self
        self.listOfClasses.dataSource = self
        
        self.classTextEdit.layer.borderWidth = 1.0
        self.classDayTime.layer.borderWidth = 1.0
        self.classLocation.layer.borderWidth = 1.0
        
        self.classTextEdit.layer.cornerRadius = 5
        self.classDayTime.layer.cornerRadius = 5
        self.classLocation.layer.cornerRadius = 5
        
        self.classTextEdit.layer.borderColor = UIColor.black.cgColor
        self.classDayTime.layer.borderColor = UIColor.black.cgColor
        self.classLocation.layer.borderColor = UIColor.black.cgColor
        
        self.addClassButton.layer.cornerRadius = 5
        self.addClassButton.layer.borderWidth = 1
        self.addClassButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        self.addClassButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        readFromPreferences()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.navBar.barTintColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
        //listOfClasses.reloadData()
        animateTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == thirdViewSegue {
            let tabBarC : UITabBarController = (segue.destination as? UITabBarController)!
            let desView : ThirdViewController = (tabBarC.viewControllers?.first as? ThirdViewController)!
            let tableIndex = listOfClasses.indexPathForSelectedRow?.row
            desView.className = tableData[tableIndex!]
            self.navigationController?.pushViewController(desView, animated: true)
        }
    }
    
    @IBAction func addClassButtonPressed(_ sender: AnyObject) {
        if (self.classTextEdit.text?.characters.count != 0) {
            self.tableData.append(self.classTextEdit.text!)
            writeToPreferences()
            
            self.listOfClasses.beginUpdates()
            let indexPath = IndexPath(row: 0, section: 0)
            self.listOfClasses.numberOfRows(inSection: tableData.count)
            self.listOfClasses.cellForRow(at: indexPath)
            self.listOfClasses.insertRows(at: [indexPath], with: .automatic)
            self.listOfClasses.endUpdates()
            self.listOfClasses.reloadData()
            classTextEdit.text = ""
        }
    }
    
    func animateTable() {
        listOfClasses.reloadData()
        
        let cells = listOfClasses.visibleCells
        let tableHeight: CGFloat = listOfClasses.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.tableData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.tableData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            writeToPreferences()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        self.performSegue(withIdentifier: thirdViewSegue, sender: indexPath)
    }
    
    func writeToPreferences() {
        let preferences = UserDefaults.standard
        let currentKey = "classList"
        preferences.set(self.tableData, forKey: currentKey)
        let didSave = preferences.synchronize()
        if !didSave {
            
        }
    }
    
    func readFromPreferences() {
        let preferences = UserDefaults.standard
        let currentKey = "classList"
        if preferences.object(forKey: currentKey) == nil {
            
        } else {
            let td = preferences.array(forKey: currentKey)
            self.tableData = td as! [String]
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 85
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += 85
            }
        }
    }
    
}



