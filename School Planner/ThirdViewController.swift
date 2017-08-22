//
//  ThirdViewController.swift
//  School Planner
//
//  Created by Nick Allaire on 12/15/16.
//  Copyright © 2016 Nick Allaire. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var addAssignmentButton: UIButton!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var calculateGradeButton: UIButton!
    
    @IBOutlet weak var listOfAssignments: UITableView!
    @IBOutlet weak var bbItem: UIBarButtonItem!
    @IBOutlet weak var gbItem: UIBarButtonItem!
    @IBOutlet weak var nItem: UINavigationItem!
    @IBOutlet weak var nBar: UINavigationBar!
    
    @IBOutlet weak var assignmentText: UITextField!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var gradeText: UITextField!
    @IBOutlet weak var gradeDistributionText: UITextField!
    @IBOutlet weak var gradeCategoryText: UITextField!
    
    var className = String()
    var tableData = [String]()
    var gradeTableData = [String]()
    var edittingIndex = 0
    var amEdittingCell = false
    
    var customView: UIView!
    var customViewGrades: UIView!
    var listOfGradeDistributions: UITableView!
    var assignmentLabel: UILabel!
    var gradedLabel: UILabel!
    var dueDateText: UITextField!
    var radioButton: UISwitch!
    
    var picker = UIPickerView()
    var datePicker = UIDatePicker()
    var pickerData = [String]()
    var oldValue = String()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Navigation Item customization
        self.nItem.title = className
        self.bbItem.title = "Back"
        self.gbItem.title = "Distributions"
        self.nItem.leftBarButtonItem = bbItem
        self.nItem.rightBarButtonItem = gbItem
        
        // Initializing UITableView
        self.listOfAssignments.delegate = self
        self.listOfAssignments.dataSource = self
        self.listOfAssignments.register(UITableViewCell.self, forCellReuseIdentifier: "assignmentCell")
        
        self.picker.showsSelectionIndicator = true
        self.picker.delegate = self
        
        self.datePicker.datePickerMode = .date
        
        customViewFunc()
        customViewFuncGrades()
        
        self.tableData = readFromPreferences(key: "Assignments")
        self.gradeTableData = readFromPreferences(key: "GradeDistributions")
        self.pickerData = readFromPreferences(key: "PickerData")
        
        // UIButton (addAssignmentButton) border customization
        addAssignmentButton.layer.cornerRadius = 5
        addAssignmentButton.layer.borderWidth = 1
        addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        addAssignmentButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        // UIButton (calculateGradeButton) border customization
        calculateGradeButton.layer.cornerRadius = 5
        calculateGradeButton.layer.borderWidth = 1
        calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        calculateGradeButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        // Long Press Gesture Recognizer (listOfAssignments)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAssignments))
        longPressRecognizer.minimumPressDuration = 0.677 // 1 second press
        self.listOfAssignments.addGestureRecognizer(longPressRecognizer)
        
        // Long Press Gesture Recognizer (listOfGradeDistributions)
        let longPressRecognizer1 = UILongPressGestureRecognizer(target: self, action: #selector (longPressGradeDistributions))
        longPressRecognizer1.minimumPressDuration = 0.677
        self.listOfGradeDistributions.addGestureRecognizer(longPressRecognizer1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.nBar.barTintColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
        self.bbItem.tintColor = UIColor.white
        self.gbItem.tintColor = UIColor.white
        animateTable()
    }
    
    func animateTable() {
        listOfAssignments.reloadData()
        
        let cells = listOfAssignments.visibleCells
        let tableHeight: CGFloat = listOfAssignments.bounds.size.height
        
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
    
    func longPressAssignments(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.listOfAssignments)
            if let indexPath = listOfAssignments.indexPathForRow(at: touchPoint) {
                let tableText = tableData[indexPath.row]
                let distributionArray : [String] = tableText.components(separatedBy: "|")
                self.assignmentText.text = distributionArray[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
                self.categoryText.text = distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces)
                self.gradeText.text = distributionArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces)
                customView.isHidden = false
                addAssignmentButton.isEnabled = false
                calculateGradeButton.isEnabled = false
                bbItem.isEnabled = false
                gbItem.isEnabled = false
                listOfAssignments.isUserInteractionEnabled = false
                addAssignmentButton.layer.borderColor = UIColor.lightGray.cgColor
                calculateGradeButton.layer.borderColor = UIColor.lightGray.cgColor
                self.edittingIndex = indexPath.row
                self.amEdittingCell = true
            }
        }
    }
    
    func longPressGradeDistributions(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.listOfGradeDistributions)
            if let indexPath = listOfGradeDistributions.indexPathForRow(at: touchPoint) {
                let tableText = gradeTableData[indexPath.row]
                let distributionArray : [String] = tableText.components(separatedBy: "|")
                self.gradeCategoryText.text = distributionArray[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
                self.gradeDistributionText.text = distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces)
                self.oldValue = gradeCategoryText.text!
                customViewGrades.isHidden = false
                addAssignmentButton.isEnabled = false
                calculateGradeButton.isEnabled = false
                bbItem.isEnabled = false
                gbItem.isEnabled = false
                listOfAssignments.isUserInteractionEnabled = false
                addAssignmentButton.layer.borderColor = UIColor.lightGray.cgColor
                calculateGradeButton.layer.borderColor = UIColor.lightGray.cgColor
                self.edittingIndex = indexPath.row
                self.amEdittingCell = true
            }
        }
    }
    
    func customViewFuncGrades() {
        
        // UIView specifications
        customViewGrades = UIView(frame: CGRect(x: 30, y: (self.view.frame.height / 2) - 245, width: self.view.frame.width - 60, height: 360))
        customViewGrades.backgroundColor = UIColor(red: 0.9294, green: 0.9294, blue: 0.9294, alpha: 1.0)
        customViewGrades.addShadow()
        customViewGrades.isHidden = true
        view.addSubview(customViewGrades)
        
        
        // UIButton(okayButton) specifications
        let okayButton = UIButton(type: UIButtonType.system) as UIButton
        okayButton.frame = CGRect(x: 10, y: customViewGrades.frame.height - 40, width: 50, height: 30)
        okayButton.setTitle("Okay", for: .normal)
        okayButton.addTarget(self, action: #selector(okayButtonGradesPressed), for: UIControlEvents.touchUpInside)
        okayButton.layer.cornerRadius = 5
        okayButton.layer.borderWidth = 1
        okayButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        okayButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        customViewGrades.addSubview(okayButton)
        
        
        // UIButton(cancelButton) specifications
        let cancelButton = UIButton(type: UIButtonType.system) as UIButton
        cancelButton.frame = CGRect(x: self.view.frame.width - 130, y: customViewGrades.frame.height - 40, width: 60, height: 30)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControlEvents.touchUpInside)
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        cancelButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        customViewGrades.addSubview(cancelButton)
        
        
        // UITableView (listOfGradeDistributions) specifications
        listOfGradeDistributions = UITableView() as UITableView
        listOfGradeDistributions.delegate = self
        listOfGradeDistributions.dataSource = self
        listOfGradeDistributions.frame = CGRect(x: 20, y: 20, width: customViewGrades.frame.width - 40, height: 175)
        listOfGradeDistributions.backgroundColor = UIColor.lightText
        listOfGradeDistributions.register(UITableViewCell.self, forCellReuseIdentifier: "gradeDistributionCell")
        customViewGrades.addSubview(listOfGradeDistributions)
        
        
        // UITextField (gradeCategoryText) specifications
        gradeCategoryText = UITextField(frame: CGRect(x: 30, y: customViewGrades.frame.height - 140, width: customViewGrades.frame.width - 60, height: 30))
        gradeCategoryText.backgroundColor = UIColor.white
        gradeCategoryText.placeholder = "Enter category name..."
        gradeCategoryText.delegate = self
        gradeCategoryText.font = UIFont.systemFont(ofSize: 15)
        gradeCategoryText.borderStyle = UITextBorderStyle.roundedRect
        gradeCategoryText.autocorrectionType = UITextAutocorrectionType.no
        gradeCategoryText.keyboardType = UIKeyboardType.default
        gradeCategoryText.returnKeyType = UIReturnKeyType.done
        gradeCategoryText.clearButtonMode = UITextFieldViewMode.whileEditing;
        gradeCategoryText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customViewGrades.addSubview(gradeCategoryText)
        
        
        // UITextField (gradeDistributionText) specifications
        gradeDistributionText = UITextField(frame: CGRect(x: 30, y: customViewGrades.frame.height - 90, width: customViewGrades.frame.width - 60, height: 30))
        gradeDistributionText.backgroundColor = UIColor.white
        gradeDistributionText.delegate = self
        gradeDistributionText.placeholder = "Enter category percentage..."
        gradeDistributionText.font = UIFont.systemFont(ofSize: 15)
        gradeDistributionText.borderStyle = UITextBorderStyle.roundedRect
        gradeDistributionText.autocorrectionType = UITextAutocorrectionType.no
        gradeDistributionText.keyboardType = UIKeyboardType.decimalPad
        gradeDistributionText.returnKeyType = UIReturnKeyType.done
        gradeDistributionText.clearButtonMode = UITextFieldViewMode.whileEditing;
        gradeDistributionText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customViewGrades.addSubview(gradeDistributionText)
        
    }
    
    func customViewFunc() {
        
        // UIView specifications
        customView = UIView(frame: CGRect(x: 30, y: (self.view.frame.height / 2) - 185, width: self.view.frame.width - 60, height: 300))
        customView.backgroundColor = UIColor(red: 0.9294, green: 0.9294, blue: 0.9294, alpha: 1.0)
        customView.addShadow()
        customView.isHidden = true
        view.addSubview(customView)

        
        // UIButton(okayButton) specifications
        let okayButton = UIButton(type: UIButtonType.system) as UIButton
        okayButton.frame = CGRect(x: 10, y: customView.frame.height - 40, width: 50, height: 30)
        okayButton.setTitle("Okay", for: .normal)
        okayButton.addTarget(self, action: #selector(okayButtonPressed), for: UIControlEvents.touchUpInside)
        okayButton.layer.cornerRadius = 5
        okayButton.layer.borderWidth = 1
        okayButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        okayButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        customView.addSubview(okayButton)
        
        
        // UIButton(cancelButton) specifications
        let cancelButton = UIButton(type: UIButtonType.system) as UIButton
        cancelButton.frame = CGRect(x: self.view.frame.width - 130, y: customView.frame.height - 40, width: 60, height: 30)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControlEvents.touchUpInside)
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        cancelButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        customView.addSubview(cancelButton)
        
        
        // UITextField (assignmentText) specifications
        assignmentText = UITextField(frame: CGRect(x: 30, y: 50, width: customView.frame.width - 60, height: 30))
        assignmentText.backgroundColor = UIColor.white
        assignmentText.placeholder = "Enter assignment..."
        assignmentText.delegate = self
        assignmentText.font = UIFont.systemFont(ofSize: 15)
        assignmentText.borderStyle = UITextBorderStyle.roundedRect
        assignmentText.autocorrectionType = UITextAutocorrectionType.no
        assignmentText.keyboardType = UIKeyboardType.default
        assignmentText.returnKeyType = UIReturnKeyType.done
        assignmentText.clearButtonMode = UITextFieldViewMode.whileEditing;
        assignmentText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customView.addSubview(assignmentText)
        
        // UITextField (categoryText) specifications
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        categoryText = UITextField(frame: CGRect(x: 30, y: 100, width: customView.frame.width - 60, height: 30))
        categoryText.inputView = picker
        categoryText.delegate = self
        categoryText.inputAccessoryView = toolBar
        categoryText.tintColor = UIColor.clear
        categoryText.backgroundColor = UIColor.white
        categoryText.placeholder = "Enter category..."
        categoryText.font = UIFont.systemFont(ofSize: 15)
        categoryText.borderStyle = UITextBorderStyle.roundedRect
        categoryText.autocorrectionType = UITextAutocorrectionType.no
        categoryText.keyboardType = UIKeyboardType.default
        categoryText.returnKeyType = UIReturnKeyType.done
        categoryText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customView.addSubview(categoryText)
        
        // UISwitch (radioButton) specifications
        radioButton = UISwitch() as UISwitch
        radioButton.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        radioButton.frame = CGRect(x: self.view.frame.width - 130, y: customView.frame.height - 100, width: 60, height: 30)
        radioButton.isOn = true
        radioButton.onTintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        radioButton.backgroundColor = UIColor.white
        radioButton.layer.cornerRadius = 16.0
        customView.addSubview(radioButton)
        
        
        // UITextField (gradeText) specifications
        gradeText = UITextField(frame: CGRect(x: 30, y: 150, width: customView.frame.width - 60, height: 30))
        gradeText.backgroundColor = UIColor.white
        gradeText.delegate = self
        //gradeText.inputAccessoryView = toolBar
        gradeText.placeholder = "Enter grade..."
        gradeText.font = UIFont.systemFont(ofSize: 15)
        gradeText.borderStyle = UITextBorderStyle.roundedRect
        gradeText.autocorrectionType = UITextAutocorrectionType.no
        gradeText.keyboardType = UIKeyboardType.decimalPad
        gradeText.returnKeyType = UIReturnKeyType.done
        gradeText.clearButtonMode = UITextFieldViewMode.whileEditing;
        gradeText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        gradeText.isHidden = false
        customView.addSubview(gradeText)

        // UITextField (dueDateText) specifications
        dueDateText = UITextField(frame: CGRect(x: 30, y: 150, width: customView.frame.width - 60, height: 30))
        dueDateText.inputView = datePicker
        dueDateText.backgroundColor = UIColor.white
        //dueDateText.inputAccessoryView = toolBar
        dueDateText.placeholder = "Enter due date..."
        dueDateText.font = UIFont.systemFont(ofSize: 15)
        dueDateText.borderStyle = UITextBorderStyle.roundedRect
        dueDateText.autocorrectionType = UITextAutocorrectionType.no
        dueDateText.keyboardType = UIKeyboardType.decimalPad
        dueDateText.returnKeyType = UIReturnKeyType.done
        //dueDateText.clearButtonMode = UITextFieldViewMode.whileEditing
        dueDateText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        dueDateText.isHidden = true
        customView.addSubview(dueDateText)
        
        // UILabel (assignmentLabel) specifications
        assignmentLabel = UILabel() as UILabel
        assignmentLabel.frame = CGRect(x: (customView.frame.width / 2) - 74, y: 15, width: 148, height: 30)
        assignmentLabel?.text = "Assignment Details"
        assignmentLabel?.textColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        customView!.addSubview(assignmentLabel)
        
        // UILabel (gradedLabel) specifications
        gradedLabel = UILabel() as UILabel
        gradedLabel.frame = CGRect(x: self.view.frame.width - 210, y: customView.frame.height - 100, width: 100, height: 30)
        gradedLabel.text = "Graded?"
        gradedLabel.textColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        customView.addSubview(gradedLabel)
        
    }
    
    func donePicker(_ textField: UITextField) {
        pickerView(picker, didSelectRow: picker.selectedRow(inComponent: 0), inComponent: 0)
        picker.selectRow(0, inComponent: 0, animated: true)
        categoryText.resignFirstResponder()
    }
    
    func switchChanged() {
        if radioButton.isOn {
            gradeText.isHidden = false
            dueDateText.isHidden = true
            gradeText.becomeFirstResponder()
        } else {
            gradeText.isHidden = true
            dueDateText.isHidden = false
            dueDateText.becomeFirstResponder()
        }
    }
    
    @IBAction func bbItemPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func gradeButtonPressed(_ sender: Any) {
        customViewGrades.isHidden = false
        addAssignmentButton.isEnabled = false
        calculateGradeButton.isEnabled = false
        bbItem.isEnabled = false
        gbItem.isEnabled = false
        listOfAssignments.isUserInteractionEnabled = false
        addAssignmentButton.layer.borderColor = UIColor.lightGray.cgColor
        calculateGradeButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func addAssignmentButtonPressed(_ sender: AnyObject) {
        customView.isHidden = false
        addAssignmentButton.isEnabled = false
        calculateGradeButton.isEnabled = false
        bbItem.isEnabled = false
        gbItem.isEnabled = false
        listOfAssignments.isUserInteractionEnabled = false
        addAssignmentButton.layer.borderColor = UIColor.lightGray.cgColor
        calculateGradeButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func calculateGradeButtonPressed(_ sender: AnyObject) {
        var totalGrade = 0.0
        var totalCategory = 0.0
        var gradeArray = [[String]]()
        if gradeTableData.count != 0 || tableData.count != 0 {
            for i in gradeTableData {
                var count = 0
                var row = [String]()
                totalCategory = 0.0
                let distributionArray : [String] = i.components(separatedBy: "|")
                row.append(distributionArray[0])
                for j in tableData {
                    let assignmentsArray : [String] = j.components(separatedBy: "|")
                    if distributionArray.count == 2 && assignmentsArray.count == 3 {
                        let aa = assignmentsArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
                        let da = distributionArray[0].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
                        if aa == da {
                            let grade = Double(assignmentsArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces))!
                            totalCategory += grade
                            count += 1
                        }
                    }
                }
//                debugPrint((Double(totalCategory) / Double(count)) * Double(distributionArray[1])! * 0.01)
                
                row.append(String((Double(totalCategory) / Double(count)) * Double(distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces))! * 0.01))
                gradeArray.append(row)
                
                if count != 0 {
                    totalGrade += (Double(totalCategory) / Double(count)) * Double(distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces))! * 0.01
                }
            }
            debugPrint("total " + String(totalGrade))
            
            let final = round(Double(totalGrade / 0.01)) * 0.01
            gradeLabel.text = String(final) + "%"
            
        } else {
            gradeLabel.text = "0.00%"
        }
        
        for d in gradeArray {
            debugPrint(d)
        }
    }
    
    func okayButtonPressed(sender: UIButton) {
        if self.assignmentText.text?.characters.count != 0 && self.categoryText.text?.characters.count != 0 && self.gradeText.text?.characters.count != 0 {
            if !amEdittingCell {
                let newString = self.assignmentText.text! + " | " + self.categoryText.text! + " | " + self.gradeText.text!
                self.tableData.append(newString)
                self.listOfAssignments.beginUpdates()
                let indexPath = IndexPath(row: 0, section: 0)
                self.listOfAssignments.numberOfRows(inSection: tableData.count)
                self.listOfAssignments.cellForRow(at: indexPath)
                self.listOfAssignments.insertRows(at: [indexPath], with: .automatic)
                self.listOfAssignments.endUpdates()
                self.listOfAssignments.reloadData()
            } else {
                self.tableData[edittingIndex] = self.assignmentText.text! + " | " + self.categoryText.text! + " | " + self.gradeText.text!
                self.amEdittingCell = false
                self.listOfAssignments.reloadData()
            }
            
            self.assignmentText.text = ""
            self.categoryText.text = ""
            self.gradeText.text = ""
            
            addAssignmentButton.isEnabled = true
            calculateGradeButton.isEnabled = true
            bbItem.isEnabled = true
            gbItem.isEnabled = true
            listOfAssignments.isUserInteractionEnabled = true
            addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
            calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor

            writeToPreferences(key: "Assignments", data: self.tableData)
            
            self.view.endEditing(true)
            
            customView.isHidden = true
        }
    }
    
    func okayButtonGradesPressed(sender: UIButton) {
        if self.gradeDistributionText.text?.characters.count != 0 && self.gradeCategoryText.text?.characters.count != 0 {
            if !amEdittingCell {
                let newString = self.gradeCategoryText.text! + " | " + self.gradeDistributionText.text!
                self.gradeTableData.append(newString)
                listOfGradeDistributions.beginUpdates()
                let indexPath = IndexPath(row: 0, section: 0)
                listOfGradeDistributions.numberOfRows(inSection: gradeTableData.count)
                listOfGradeDistributions.cellForRow(at: indexPath)
                listOfGradeDistributions.insertRows(at: [indexPath], with: .automatic)
                listOfGradeDistributions.endUpdates()
                listOfGradeDistributions.reloadData()
            } else {
                self.gradeTableData[edittingIndex] = self.gradeCategoryText.text! + " | " + self.gradeDistributionText.text!
                self.listOfGradeDistributions.reloadData()
                
                // Reload assignmentTable with new value
                var i = 0;
                for cell in tableData {
                    let assignmentArray : [String] = cell.components(separatedBy: "|")
                    let aa = assignmentArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
                    if aa == oldValue.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased() {
                        tableData[i] = assignmentArray[0] + "| " + self.gradeCategoryText.text! + " |" + assignmentArray[2]
                    }
                    i += 1
                }
                self.listOfAssignments.reloadData()
            }
            
            var notNew = false
            if amEdittingCell {
                self.amEdittingCell = false
                for data in gradeTableData {
                    let distributionsArray : [String] = data.components(separatedBy: "|")
                    let da = distributionsArray[0].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
                    if da == self.gradeCategoryText.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased() {
                        notNew = true
                        pickerData[edittingIndex] = self.gradeCategoryText.text!
                        writeToPreferences(key: "PickerData", data: self.pickerData)
                        break
                    }
                }
            }
            
            if !notNew {
                pickerData.append(self.gradeCategoryText.text!)
                writeToPreferences(key: "PickerData", data: self.pickerData)
            }
            
            addAssignmentButton.isEnabled = true
            calculateGradeButton.isEnabled = true
            bbItem.isEnabled = true
            gbItem.isEnabled = true
            listOfAssignments.isUserInteractionEnabled = true
            addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
            calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
            
            self.gradeDistributionText.text = ""
            self.gradeCategoryText.text = ""
            
            writeToPreferences(key: "GradeDistributions", data: self.gradeTableData)
            
            listOfGradeDistributions.setContentOffset(.zero, animated: false)
            
            self.view.endEditing(true)
            
            customViewGrades.isHidden = true
        }
    }
    
    func cancelButtonPressed(sender: UIButton) {
        self.assignmentText.text = ""
        self.categoryText.text = ""
        self.gradeText.text = ""
        
        self.gradeDistributionText.text = ""
        self.gradeCategoryText.text = ""
        
        addAssignmentButton.isEnabled = true
        calculateGradeButton.isEnabled = true
        bbItem.isEnabled = true
        gbItem.isEnabled = true
        listOfAssignments.isUserInteractionEnabled = true
        addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        listOfGradeDistributions.setContentOffset(.zero, animated: false)
        
        self.view.endEditing(true)
        
        customView.isHidden = true
        customViewGrades.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { // check this
        if textField == categoryText {
            if categoryText.text?.characters.count == 0 {
                categoryText.text = pickerData[0]
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == gradeText || textField == gradeDistributionText {
            let countdots = textField.text?.components(separatedBy: ".")
            let count = countdots!.count - 1
            if count > 0 && string == "." {
                return false
            }
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == picker { // check this
            if pickerData.count > 0 {
                categoryText.text = pickerData[row]
            }
        } else if pickerView == datePicker { // check this
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            let strDate = timeFormatter.string(from: datePicker.date)
            dueDateText.text = strDate
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == listOfAssignments {
            return self.tableData.count
        } else {
            return self.gradeTableData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == listOfGradeDistributions {
            let cell = listOfGradeDistributions.dequeueReusableCell(withIdentifier: "gradeDistributionCell", for: indexPath)
            cell.textLabel?.text = self.gradeTableData[indexPath.row]
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            let cell = listOfAssignments.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath)
            cell.textLabel?.text = self.tableData[indexPath.row]
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if tableView == listOfAssignments {
                self.tableData.remove(at: indexPath.row)
                listOfAssignments.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                writeToPreferences(key: "Assignments", data: self.tableData)
            } else {
                var stillAssignments = false
                let distributionArray : [String] = self.gradeTableData[indexPath.row].components(separatedBy: "|")
                let da = distributionArray[0].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
                debugPrint("Category: " + distributionArray[0])
                for data in tableData {
                    let assignmentsArray : [String] = data.components(separatedBy: "|")
                    let aa = assignmentsArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
                    if aa == da {
                        stillAssignments = true
                        break
                    }
                }
                
                if !stillAssignments {
                    self.pickerData.remove(at: indexPath.row)
                    self.gradeTableData.remove(at: indexPath.row)
                    listOfGradeDistributions.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
                    writeToPreferences(key: "GradeDistributions", data: self.gradeTableData)
                    writeToPreferences(key: "PickerData", data: self.pickerData)
                } else {
                    tableView.setEditing(false, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func writeToPreferences(key: String, data: [String]) {
        let preferences = UserDefaults.standard
        let currentKey = className + " " + key
        preferences.set(data, forKey: currentKey)
        let didSave = preferences.synchronize()
        if !didSave {
            
        }
    }
    
    func readFromPreferences(key: String) -> [String] {
        let preferences = UserDefaults.standard
        let currentKey = className + " " + key
        if preferences.object(forKey: currentKey) == nil {
            let data = [String]()
            return data
        } else {
            let td = preferences.array(forKey: currentKey)
            return td as! [String]
        }
    }
}
