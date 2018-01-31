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

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var fillerLabel: UILabel!
    @IBOutlet weak var addClassButton: UIButton!
    @IBOutlet weak var listOfClasses: UITableView!
    @IBOutlet weak var classTextEdit: UITextField!
    @IBOutlet weak var classDayTime: UITextField!
    @IBOutlet weak var classLocation: UITextField!
    
    var tableData = [String]()
    var locationData = [String]()
    var dayTimeData = [String]()
    var alert: UIAlertController!
    let thirdViewSegue = "segueToTabController"
    var edittingIndex = 0
    var amEdittingCell = false
    var oldClassName = ""
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UINavigationBar.appearance()
        app.barTintColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
        app.isTranslucent = false
        app.barStyle = .default
        app.tintColor = .white
        app.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        UIApplication.shared.statusBarStyle = .lightContent

        
        self.fillerLabel.backgroundColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
        
        self.listOfClasses.rowHeight = 60
        self.listOfClasses.delegate = self
        self.listOfClasses.dataSource = self
        self.listOfClasses.preservesSuperviewLayoutMargins = false
        self.listOfClasses.separatorInset = UIEdgeInsets.zero
        self.listOfClasses.layoutMargins = UIEdgeInsets.zero
        
        //let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneText))
        let nextButton = UIBarButtonItem(title: "Next >", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextText))
        let prevButton = UIBarButtonItem(title: "< Prev", style: UIBarButtonItemStyle.plain, target: self, action: #selector(prevText))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        //doneButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        nextButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        prevButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([prevButton, flexibleSpace, nextButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.classTextEdit.returnKeyType = UIReturnKeyType.done
        self.classLocation.returnKeyType = UIReturnKeyType.done
        self.classDayTime.returnKeyType = UIReturnKeyType.done
        
        self.classTextEdit.delegate = self
        self.classLocation.delegate = self
        self.classDayTime.delegate = self
        
        self.classTextEdit.inputAccessoryView = toolBar
        self.classLocation.inputAccessoryView = toolBar
        self.classDayTime.inputAccessoryView = toolBar
        
        self.classTextEdit.clearButtonMode = UITextFieldViewMode.whileEditing
        self.classDayTime.clearButtonMode = UITextFieldViewMode.whileEditing
        self.classLocation.clearButtonMode = UITextFieldViewMode.whileEditing
        
        self.classTextEdit.layer.borderWidth = 1.0
        self.classDayTime.layer.borderWidth = 1.0
        self.classLocation.layer.borderWidth = 1.0
        
        self.classTextEdit.layer.cornerRadius = 5
        self.classDayTime.layer.cornerRadius = 5
        self.classLocation.layer.cornerRadius = 5
        
        self.classTextEdit.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        self.classDayTime.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        self.classLocation.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        
        self.classTextEdit.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.classDayTime.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.classLocation.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        self.addClassButton.layer.cornerRadius = 5
        self.addClassButton.layer.borderWidth = 1
        self.addClassButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        self.addClassButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        readFromPreferences()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Long Press Gesture Recognizer (listOfAssignments)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressClasses))
        longPressRecognizer.minimumPressDuration = 0.677 // 1 second press
        self.listOfClasses.addGestureRecognizer(longPressRecognizer)
    }
    
    /* Long press on assignment list UITableView */
    
    @objc func longPressClasses(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.listOfClasses)
            
            if let indexPath = listOfClasses.indexPathForRow(at: touchPoint) {
                
                self.classTextEdit?.text = self.tableData[indexPath.row]
                self.classLocation?.text = self.locationData[indexPath.row]
                self.classDayTime?.text = self.dayTimeData[indexPath.row]
                self.edittingIndex = indexPath.row
                self.amEdittingCell = true
                self.oldClassName = self.tableData[indexPath.row]
                self.classTextEdit.becomeFirstResponder()
            }
        }
    }
    
    @objc func showAlertMessage(title: String, message: String) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(self.alert, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 1.75, target: self, selector: #selector(dismissAlert), userInfo: nil, repeats: false)
    }
    
    @objc func dismissAlert() {
        self.alert.dismiss(animated: true, completion: nil)
    }
    
    func doneText() {
        if self.classTextEdit.isFirstResponder {
            self.classTextEdit.resignFirstResponder()
        } else if self.classDayTime.isFirstResponder {
            self.classDayTime.resignFirstResponder()
        } else if self.classLocation.isFirstResponder {
            self.classLocation.resignFirstResponder()
        }
    }
    
    @objc func nextText() {
        if self.classTextEdit.isFirstResponder {
            self.classDayTime.becomeFirstResponder()
        } else if self.classDayTime.isFirstResponder {
            self.classLocation.becomeFirstResponder()
        } else if self.classLocation.isFirstResponder {
            self.classLocation.resignFirstResponder()
        }
    }
    
    @objc func prevText() {
        if self.classTextEdit.isFirstResponder {
            self.classTextEdit.resignFirstResponder()
        } else if self.classDayTime.isFirstResponder {
            self.classTextEdit.becomeFirstResponder()
        } else if self.classLocation.isFirstResponder {
            self.classDayTime.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            desView.classLocation = locationData[tableIndex!]
            desView.classDayTime = dayTimeData[tableIndex!]
            self.navigationController?.pushViewController(desView, animated: true)
        }
    }
    
    @IBAction func addClassButtonPressed(_ sender: AnyObject) {
        if (self.classTextEdit.text?.count != 0 && self.classLocation.text?.count != 0 && self.classDayTime.text?.count != 0) {
            if !amEdittingCell {
                self.tableData.append(self.classTextEdit.text!)
                self.locationData.append(self.classLocation.text!)
                self.dayTimeData.append(self.classDayTime.text!)
                
                self.listOfClasses.beginUpdates()
                let indexPath = IndexPath(row: 0, section: 0)
                self.listOfClasses.numberOfRows(inSection: tableData.count)
                self.listOfClasses.cellForRow(at: indexPath)
                self.listOfClasses.insertRows(at: [indexPath], with: .automatic)
                self.listOfClasses.endUpdates()
                self.listOfClasses.reloadData()
            } else {
                self.tableData[edittingIndex] = self.classTextEdit.text!
                self.locationData[edittingIndex] = self.classLocation.text!
                self.dayTimeData[edittingIndex] = self.classDayTime.text!
                
                self.listOfClasses.reloadData()
            }
            
            writeToPreferences(delete: false, className: "")
            self.amEdittingCell = false
            
            self.classTextEdit.text = ""
            self.classDayTime.text = ""
            self.classLocation.text = ""
            if self.classTextEdit.isFirstResponder {
                self.classTextEdit.resignFirstResponder()
            }
            if self.classDayTime.isFirstResponder {
                self.classDayTime.resignFirstResponder()
            }
            if self.classLocation.isFirstResponder {
                self.classLocation.resignFirstResponder()
            }
        } else {
            showAlertMessage(title: "Invalid Class", message: "Make sure all fields are completed.")
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
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        //cell.textLabel?.text = self.tableData[indexPath.row]
        cell.classNameText?.text = self.tableData[indexPath.row]
        cell.classLocationText?.text = self.locationData[indexPath.row]
        cell.classDayAndTimeText?.text = self.dayTimeData[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let name = self.tableData.remove(at: indexPath.row)
            self.locationData.remove(at: indexPath.row)
            self.dayTimeData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            writeToPreferences(delete: true, className: name)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: thirdViewSegue, sender: indexPath)
    }
    
    func writeToPreferences(delete: Bool, className: String) {
        let preferences = UserDefaults.standard
        let currentKey = "classList"
        preferences.set(self.tableData, forKey: currentKey)
        preferences.set(self.locationData, forKey: currentKey + " location")
        preferences.set(self.dayTimeData, forKey: currentKey + " dayTime")
        
        if delete {
            preferences.removeObject(forKey: className + " Assignments")
            preferences.removeObject(forKey: className + " GradeDistributions")
            preferences.removeObject(forKey: className + " PickerData")
        }
        
        if amEdittingCell {
            
            // Store previously stored data
            let assignments = preferences.array(forKey: self.oldClassName + " Assignments")
            let gradeDistributions = preferences.array(forKey: self.oldClassName + " GradeDistributions")
            let pickerData = preferences.array(forKey: self.oldClassName + " PickerData")
            
            // Remove previously stored data
            preferences.removeObject(forKey: self.oldClassName + " Assignments")
            preferences.removeObject(forKey: self.oldClassName + " GradeDistributions")
            preferences.removeObject(forKey: self.oldClassName + " PickerData")
            
            // Update previously stored data with new class name
            preferences.set(assignments, forKey: self.classTextEdit.text! + " Assignments")
            preferences.set(gradeDistributions, forKey: self.classTextEdit.text! + " GradeDistributions")
            preferences.set(pickerData, forKey: self.classTextEdit.text! + " PickerData")
        }
        
        let didSave = preferences.synchronize()
        if !didSave {
            showAlertMessage(title: "Error", message: "Could not save data")
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

        if preferences.object(forKey: currentKey + " location") == nil {

        } else {
            let ld = preferences.array(forKey: currentKey + " location")
            self.locationData =  ld as! [String]
        }

        if preferences.object(forKey: currentKey + " dayTime") == nil {

        } else {
            let dtd = preferences.array(forKey: currentKey + " dayTime")
            self.dayTimeData = dtd as! [String]
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 225
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 225
            }
        }
    }
}
