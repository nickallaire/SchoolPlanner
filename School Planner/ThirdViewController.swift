//
//  ThirdViewController.swift
//  School Planner
//
//  Created by Nick Allaire on 12/15/16.
//  Copyright © 2016 Nick Allaire. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var addAssignmentButton: UIButton!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var calculateGradeButton: UIButton!
    
    @IBOutlet weak var listOfAssignments: UITableView!
    @IBOutlet weak var bbItem: UIBarButtonItem!
    @IBOutlet weak var nItem: UINavigationItem!
    @IBOutlet weak var nBar: UINavigationBar!
    
    @IBOutlet weak var assignmentText: UITextField!
    
    var className = String()
    var tableData = [String]()
    
    var customView: UIView!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.nItem.title = className
        self.bbItem.title = "Back"
        self.nItem.leftBarButtonItem = bbItem
        
        self.listOfAssignments.delegate = self
        self.listOfAssignments.dataSource = self
        
        customViewFunc()
        readFromPreferences()
        
        addAssignmentButton.layer.cornerRadius = 5
        addAssignmentButton.layer.borderWidth = 1
        addAssignmentButton.layer.borderColor = UIColor.blue.cgColor
        
        calculateGradeButton.layer.cornerRadius = 5
        calculateGradeButton.layer.borderWidth = 1
        calculateGradeButton.layer.borderColor = UIColor.blue.cgColor

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    
    func customViewFunc() {
        
        // UIView specifications
        customView = UIView(frame: CGRect(x: 30, y: (self.view.frame.height / 2) - 150, width: self.view.frame.width - 60, height: 100))
        customView.backgroundColor = UIColor.lightText
        customView.addShadow()
        customView.isHidden = true
        view.addSubview(customView)

        
        // UIButton(okayButton) specifications
        let okayButton = UIButton(type: UIButtonType.system) as UIButton
        okayButton.frame = CGRect(x: 5, y: customView.frame.height - 35, width: 50, height: 30)
        okayButton.setTitle("Okay", for: .normal)
        okayButton.addTarget(self, action: #selector(okayButtonPressed), for: UIControlEvents.touchUpInside)
        customView.addSubview(okayButton)
        
        
        // UIButton(cancelButton) specifications
        let cancelButton = UIButton(type: UIButtonType.system) as UIButton
        cancelButton.frame = CGRect(x: self.view.frame.width - 120, y: customView.frame.height - 35, width: 50, height: 30)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControlEvents.touchUpInside)
        customView.addSubview(cancelButton)
        
        
        // UITextField specifications
        assignmentText = UITextField(frame: CGRect(x: 30, y: 15, width: customView.frame.width - 60, height: 30))
        assignmentText.backgroundColor = UIColor.white
        assignmentText.placeholder = "Enter text here"
        assignmentText.font = UIFont.systemFont(ofSize: 15)
        assignmentText.borderStyle = UITextBorderStyle.roundedRect
        assignmentText.autocorrectionType = UITextAutocorrectionType.no
        assignmentText.keyboardType = UIKeyboardType.default
        assignmentText.returnKeyType = UIReturnKeyType.done
        assignmentText.clearButtonMode = UITextFieldViewMode.whileEditing;
        assignmentText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customView.addSubview(assignmentText)
    }
    
    @IBAction func bbItemPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
        
    }
    
    @IBAction func addAssignmentButtonPressed(_ sender: AnyObject) {
        customView.isHidden = false
        addAssignmentButton.isEnabled = false
        calculateGradeButton.isEnabled = false
        bbItem.isEnabled = false
        listOfAssignments.isUserInteractionEnabled = false
    }
    
    @IBAction func calculateGradeButtonPressed(_ sender: AnyObject) {
        gradeLabel.text = "81.9%"
    }
    
    func okayButtonPressed(sender: UIButton) {
        if self.assignmentText.text?.characters.count != 0 {
            self.tableData.append(self.assignmentText.text!)
            self.listOfAssignments.beginUpdates()
            let indexPath = IndexPath(row: 0, section: 0)
            self.listOfAssignments.numberOfRows(inSection: tableData.count)
            self.listOfAssignments.cellForRow(at: indexPath)
            self.listOfAssignments.insertRows(at: [indexPath], with: .automatic)
            self.listOfAssignments.endUpdates()
            self.listOfAssignments.reloadData()
            
            self.assignmentText.text = ""
            
            addAssignmentButton.isEnabled = true
            calculateGradeButton.isEnabled = true
            bbItem.isEnabled = true
            listOfAssignments.isUserInteractionEnabled = true
            
            writeToPreferences()
            
            self.view.endEditing(true)
            
            customView.isHidden = true
        }
    }
    
    func cancelButtonPressed(sender: UIButton) {
        self.assignmentText.text = ""
        
        addAssignmentButton.isEnabled = true
        calculateGradeButton.isEnabled = true
        bbItem.isEnabled = true
        listOfAssignments.isUserInteractionEnabled = true
        
        self.view.endEditing(true)
        
        customView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath)
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
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    
    func writeToPreferences() {
        let preferences = UserDefaults.standard
        let currentKey = className + " Assignments"
        preferences.set(self.tableData, forKey: currentKey)
        let didSave = preferences.synchronize()
        if !didSave {
            
        }
    }
    
    func readFromPreferences() {
        let preferences = UserDefaults.standard
        let currentKey = className + " Assignments"
        if preferences.object(forKey: currentKey) == nil {
            
        } else {
            let td = preferences.array(forKey: currentKey)
            self.tableData = td as! [String]
        }
    }
}
