//
//  ThirdViewController.swift
//  School Planner
//
//  Created by Nick Allaire on 12/15/16.
//  Copyright © 2016 Nick Allaire. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    // Story board variables
    
    @IBOutlet weak var dayTimeText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    
    @IBOutlet weak var addAssignmentButton: UIButton!
    @IBOutlet weak var calculateGradeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
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
    
    
    // local variables
    
    var className = String()
    var classLocation = String()
    var classDayTime = String()
    var oldValue = String()
    
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
    var pickerData = [String]()
    
    var datePicker = UIDatePicker()
    
    var alert: UIAlertController!
    
    var estyle = false

    
    /* View loads for first time */
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Navigation Item customization
        self.nItem.title = className
        self.bbItem.title = "Back"
        self.gbItem.title = "Distributions"
        self.nItem.leftBarButtonItem = bbItem
        self.nItem.rightBarButtonItem = gbItem
        
        // Initializing class information
        self.locationText.text = classLocation
        self.dayTimeText.text = classDayTime
        
        // Initializing UITableView
        self.listOfAssignments.delegate = self
        self.listOfAssignments.dataSource = self
        self.listOfAssignments.rowHeight = 60
        self.listOfAssignments.preservesSuperviewLayoutMargins = false
        self.listOfAssignments.separatorInset = UIEdgeInsets.zero
        self.listOfAssignments.layoutMargins = UIEdgeInsets.zero
        
        // Initializing UIPickers
        self.picker.showsSelectionIndicator = true
        self.picker.delegate = self
        self.datePicker.datePickerMode = .date
        
        // Initialize Custom Sub Views
        customViewFunc()
        customViewFuncGrades()
        
        // Initialize Class Data
        self.tableData = readFromPreferences(key: "Assignments")
        self.gradeTableData = readFromPreferences(key: "GradeDistributions")
        self.pickerData = readFromPreferences(key: "PickerData")
        
        // UIButton (addAssignmentButton) customization
        addAssignmentButton.layer.cornerRadius = 5
        addAssignmentButton.layer.borderWidth = 1
        addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        addAssignmentButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        // UIButton (calculateGradeButton) customization
        calculateGradeButton.layer.cornerRadius = 5
        calculateGradeButton.layer.borderWidth = 1
        calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        calculateGradeButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        // UIButton (editButton) customization
        editButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        // Long Press Gesture Recognizer (listOfAssignments)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAssignments))
        longPressRecognizer.minimumPressDuration = 0.677 // 1 second press
        self.listOfAssignments.addGestureRecognizer(longPressRecognizer)
        
        // Long Press Gesture Recognizer (listOfGradeDistributions)
        let longPressRecognizer1 = UILongPressGestureRecognizer(target: self, action: #selector (longPressGradeDistributions))
        longPressRecognizer1.minimumPressDuration = 0.677
        self.listOfGradeDistributions.addGestureRecognizer(longPressRecognizer1)
    }
    
    
    /* Memory warning code */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    /* View comes back onto screen */
    
    override func viewWillAppear(_ animated: Bool) {
        self.nBar.barTintColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
        self.bbItem.tintColor = UIColor.white
        self.gbItem.tintColor = UIColor.white
        animateTable()
    }
    
    
    /* Animate table so cells come up from bottom of screen */
    
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
    
    
    /* Long press on assignment list UITableView */
    
    @objc func longPressAssignments(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if !self.listOfAssignments.isEditing {
            if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
                let touchPoint = longPressGestureRecognizer.location(in: self.listOfAssignments)
               
                if let indexPath = listOfAssignments.indexPathForRow(at: touchPoint) {
                    
                    let tableText = tableData[indexPath.row]
                    let distributionArray : [String] = tableText.components(separatedBy: "|")
                    self.assignmentText.text = distributionArray[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
                    self.categoryText.text = distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces)
                    self.oldValue = self.assignmentText.text!
                    let charSet = CharacterSet(charactersIn: "/")
                    
                    if distributionArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces).rangeOfCharacter(from: charSet) == nil {
                        self.radioButton.setOn(true, animated: false)
                        self.gradeText.text = distributionArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces)
                    } else {
                        self.radioButton.setOn(false, animated: false)
                        self.gradeText.isHidden = true
                        self.dueDateText.isHidden = false
                        self.dueDateText.text = distributionArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces)
                    }
                    
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
    }
    
    
    /* Long press on grade distribution list UITableView */
    
    @objc func longPressGradeDistributions(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
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
    
    
    /*** Grade Distributions UIView ***/
    
    @objc func customViewFuncGrades() {
        
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
        listOfGradeDistributions.preservesSuperviewLayoutMargins = false
        listOfGradeDistributions.separatorInset = UIEdgeInsets.zero
        listOfGradeDistributions.layoutMargins = UIEdgeInsets.zero
        customViewGrades.addSubview(listOfGradeDistributions)
        
        
        // UIToolbar (toolBar) specifications
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let nextButton = UIBarButtonItem(title: "Next >", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextText))
        let prevButton = UIBarButtonItem(title: "< Prev", style: UIBarButtonItemStyle.plain, target: self, action: #selector(prevText))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        doneButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        nextButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        prevButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([doneButton, flexibleSpace, prevButton, nextButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        
        // UITextField (gradeCategoryText) specifications
        gradeCategoryText = UITextField(frame: CGRect(x: 30, y: customViewGrades.frame.height - 140, width: customViewGrades.frame.width - 60, height: 30))
        gradeCategoryText.backgroundColor = UIColor.white
        gradeCategoryText.placeholder = "Enter category name..."
        gradeCategoryText.delegate = self
        gradeCategoryText.inputAccessoryView = toolBar
        gradeCategoryText.font = UIFont.systemFont(ofSize: 15)
        gradeCategoryText.borderStyle = UITextBorderStyle.roundedRect
        gradeCategoryText.autocorrectionType = UITextAutocorrectionType.yes
        gradeCategoryText.keyboardType = UIKeyboardType.default
        gradeCategoryText.returnKeyType = UIReturnKeyType.done
        gradeCategoryText.clearButtonMode = UITextFieldViewMode.whileEditing;
        gradeCategoryText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customViewGrades.addSubview(gradeCategoryText)
        
        
        // UITextField (gradeDistributionText) specifications
        gradeDistributionText = UITextField(frame: CGRect(x: 30, y: customViewGrades.frame.height - 90, width: customViewGrades.frame.width - 60, height: 30))
        gradeDistributionText.backgroundColor = UIColor.white
        gradeDistributionText.delegate = self
        gradeDistributionText.inputAccessoryView = toolBar
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
    
    
    /*** Assignment UIView ***/
    
    @objc func customViewFunc() {
        
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
        
        
        // UIToolbar (toolBar) specifications
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let nextButton = UIBarButtonItem(title: "Next >", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextText))
        let prevButton = UIBarButtonItem(title: "< Prev", style: UIBarButtonItemStyle.plain, target: self, action: #selector(prevText))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        doneButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        nextButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        prevButton.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([doneButton, flexibleSpace, prevButton, nextButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        
        // UITextField (assignmentText) specifications
        assignmentText = UITextField(frame: CGRect(x: 30, y: 50, width: customView.frame.width - 60, height: 30))
        assignmentText.backgroundColor = UIColor.white
        assignmentText.placeholder = "Enter assignment..."
        assignmentText.delegate = self
        assignmentText.inputAccessoryView = toolBar
        assignmentText.font = UIFont.systemFont(ofSize: 15)
        assignmentText.borderStyle = UITextBorderStyle.roundedRect
        assignmentText.autocorrectionType = UITextAutocorrectionType.yes
        assignmentText.keyboardType = UIKeyboardType.default
        assignmentText.returnKeyType = UIReturnKeyType.done
        assignmentText.clearButtonMode = UITextFieldViewMode.whileEditing;
        assignmentText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        customView.addSubview(assignmentText)
        
        
        // UITextField (categoryText) specifications
        categoryText = UITextField(frame: CGRect(x: 30, y: 100, width: customView.frame.width - 60, height: 30))
        categoryText.inputView = picker
        categoryText.delegate = self
        categoryText.inputAccessoryView = toolBar
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
        gradeText.placeholder = "Enter grade..."
        gradeText.inputAccessoryView = toolBar
        gradeText.font = UIFont.systemFont(ofSize: 15)
        gradeText.borderStyle = UITextBorderStyle.roundedRect
        gradeText.autocorrectionType = UITextAutocorrectionType.no
        gradeText.keyboardType = UIKeyboardType.decimalPad
        gradeText.returnKeyType = UIReturnKeyType.done
        gradeText.clearButtonMode = UITextFieldViewMode.whileEditing;
        gradeText.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        gradeText.isHidden = false
        customView.addSubview(gradeText)

        
        // UIDatePicker (datePicker) specifications
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        let todaysDate = Date()
//        datePicker.minimumDate = todaysDate
        
        
        // UIToolBar (toolBar1) specifications
        let doneButton1 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let nextButton1 = UIBarButtonItem(title: "Next >", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextText))
        let prevButton1 = UIBarButtonItem(title: "< Prev", style: UIBarButtonItemStyle.plain, target: self, action: #selector(prevText))
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        doneButton1.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        nextButton1.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        prevButton1.tintColor = UIColor(red: 0.2431, green: 0.6784, blue: 0.5608, alpha: 1.0)
        
        let toolBar1 = UIToolbar()
        toolBar1.barStyle = UIBarStyle.default
        toolBar1.isTranslucent = true
        toolBar1.sizeToFit()
        toolBar1.setItems([doneButton1, flexibleSpace1, prevButton1, nextButton1], animated: false)
        toolBar1.isUserInteractionEnabled = true
        
        
        // UITextField (dueDateText) specifications
        dueDateText = UITextField(frame: CGRect(x: 30, y: 150, width: customView.frame.width - 60, height: 30))
        dueDateText.inputView = datePicker
        dueDateText.backgroundColor = UIColor.white
        dueDateText.delegate = self
        dueDateText.inputAccessoryView = toolBar1
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
    
    
    /* Displays alert message for wrong data */
    
    @objc func showAlertMessage(title: String, message: String) {
        self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(self.alert, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 1.75, target: self, selector: #selector(dismissAlert), userInfo: nil, repeats: false)
    }
    
    
    /* Dismisses displayed alert */
    
    @objc func dismissAlert() {
        self.alert.dismiss(animated: true, completion: nil)
    }
    
    
    /* Done button on UIToolBar pressed */
    
    @objc func donePicker() {
        if assignmentText.isFirstResponder {
            assignmentText.resignFirstResponder()
        } else if categoryText.isFirstResponder {
            categoryText.resignFirstResponder()
        } else if dueDateText.isFirstResponder {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            dueDateText.text = formatter.string(from: datePicker.date)
            dueDateText.resignFirstResponder()
        } else if gradeText.isFirstResponder {
            gradeText.resignFirstResponder()
        }
        
        if gradeCategoryText.isFirstResponder {
            gradeCategoryText.resignFirstResponder()
        } else if gradeDistributionText.isFirstResponder {
            gradeDistributionText.resignFirstResponder()
        }
    }
    
    
    /* Go to next UITextField */
    
    @objc func nextText() {
        if self.assignmentText.isFirstResponder {
            self.categoryText.becomeFirstResponder()
        } else if self.categoryText.isFirstResponder {
            if self.radioButton.isOn {
                self.gradeText.becomeFirstResponder()
            } else {
                self.dueDateText.becomeFirstResponder()
            }
        } else if self.gradeText.isFirstResponder {
            self.gradeText.resignFirstResponder()
        } else if self.dueDateText.isFirstResponder {
            self.dueDateText.resignFirstResponder()
        }
        
        if self.gradeCategoryText.isFirstResponder {
            self.gradeDistributionText.becomeFirstResponder()
        } else if gradeDistributionText.isFirstResponder {
            gradeDistributionText.resignFirstResponder()
        }
    }
    
    
    /* Go to previous UITextField */
    
    @objc func prevText() {
        if self.assignmentText.isFirstResponder {
            self.assignmentText.resignFirstResponder()
        } else if self.categoryText.isFirstResponder {
            self.assignmentText.becomeFirstResponder()
        } else if self.radioButton.isOn {
            if self.gradeText.isFirstResponder {
                self.categoryText.becomeFirstResponder()
            }
        } else if !self.radioButton.isOn {
            if self.dueDateText.isFirstResponder {
                self.categoryText.becomeFirstResponder()
            }
        }
        
        if self.gradeCategoryText.isFirstResponder {
            self.gradeCategoryText.resignFirstResponder()
        } else if self.gradeDistributionText.isFirstResponder {
            self.gradeCategoryText.becomeFirstResponder()
        }
    }

    
    /* Puts selected date in UITextField */
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dueDateText.text = formatter.string(from: datePicker.date)
    }
    
    
    /* Changes UITextField when UISwitch toggled on/off */
    
    @objc func switchChanged() {
        if radioButton.isOn {
            gradeText.isHidden = false
            dueDateText.isHidden = true
            dueDateText.text = ""
            if dueDateText.isFirstResponder {
                gradeText.becomeFirstResponder()
            }
        } else {
            gradeText.isHidden = true
            gradeText.text = ""
            dueDateText.isHidden = false
            if gradeText.isFirstResponder {
                dueDateText.becomeFirstResponder()
            }
        }
    }
    
    
    /* Checks category percentage doesn't exceed 100% */
    
    func checkCategoryPercentage(percentage: String, category: String) -> Bool {
        var total = 0.0
        for c in gradeTableData {
            let array : [String] = c.components(separatedBy: "|")
            let cat = array[0].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            let num = array[1].trimmingCharacters(in: NSCharacterSet.whitespaces)
            if cat == category {
                total += 0
            } else {
                if amEdittingCell && cat == oldValue.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased() {
                    total += 0
                } else {
                    total += Double(num)!
                }
            }
            debugPrint("num: " + num)
        }
        
        let tempTotal = total + Double(percentage.trimmingCharacters(in: NSCharacterSet.whitespaces))!
        if tempTotal <= 100 {
            return true
        } else {
            return false
        }
    }
    
    
    /* Checks if duplicate category is added */
    
    func checkDuplicateCategory(category: String) -> Bool {
        for c in gradeTableData {
            let array : [String] = c.components(separatedBy: "|")
            let temp = array[0].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            let cat = category.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            let old = oldValue.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            if cat == temp {
                if cat == old && amEdittingCell {
                    return false
                } else if cat != old && amEdittingCell {
                    return true
                } else if !amEdittingCell {
                    return true
                }
            }
        }
        return false
    }
    
    
    /* Checks if duplicate assignment is added */
    
    func checkDuplicateAssignment(assignment: String) -> Bool {
        for a in tableData {
            let array : [String] = a.components(separatedBy: "|")
            let temp = array[0].trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            let assgn = assignment.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            let old = oldValue.trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
            if assgn == temp {
                if assgn == old && amEdittingCell{
                    return true
                } else if assgn != old && amEdittingCell {
                    return false
                } else if !amEdittingCell {
                    return false
                }
            }
        }
        
        
        return true
    }
    
    
    /* Go back to FirstViewController */
    
    @IBAction func bbItemPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
    /* UI changes when Distributions button pressed */
    
    @IBAction func gradeButtonPressed(_ sender: Any) {
        customViewGrades.isHidden = false
        addAssignmentButton.isEnabled = false
        calculateGradeButton.isEnabled = false
        editButton.isEnabled = false
        bbItem.isEnabled = false
        gbItem.isEnabled = false
        listOfAssignments.isUserInteractionEnabled = false
        addAssignmentButton.layer.borderColor = UIColor.lightGray.cgColor
        calculateGradeButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        self.gradeCategoryText.becomeFirstResponder()
    }
    
    /* Allow table to be editted */
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        if self.editButton.titleLabel!.text == "Edit" {
            self.estyle = true
            self.listOfAssignments.isEditing = true
            self.editButton.setTitle("Done", for: .normal)
        } else if self.editButton.titleLabel!.text == "Done" {
            self.estyle = false
            self.listOfAssignments.isEditing = false
            self.editButton.setTitle("Edit", for: .normal)
        }
    }
    
    /* UI changes when Assignments button pressed */
    
    @IBAction func addAssignmentButtonPressed(_ sender: AnyObject) {
        customView.isHidden = false
        addAssignmentButton.isEnabled = false
        calculateGradeButton.isEnabled = false
        editButton.isEnabled = false
        bbItem.isEnabled = false
        gbItem.isEnabled = false
        listOfAssignments.isUserInteractionEnabled = false
        addAssignmentButton.layer.borderColor = UIColor.lightGray.cgColor
        calculateGradeButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        self.assignmentText.becomeFirstResponder()
    }
    
    
    /* Calculates current grade based on assignments that have a score */
    
    @IBAction func calculateGradeButtonPressed(_ sender: AnyObject) {
        var totalGrade = 0.0
        var totalCategory = 0.0
        var total = 0.0
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
                            let charSet = CharacterSet(charactersIn: "/")
                            if assignmentsArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces).rangeOfCharacter(from: charSet) == nil {
                                let grade = Double(assignmentsArray[2].trimmingCharacters(in: NSCharacterSet.whitespaces))!
                                totalCategory += grade
                                count += 1
                            }
                        }
                    }
                }
                
                row.append(String((Double(totalCategory) / Double(count)) * Double(distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces))! * 0.01))
                gradeArray.append(row)
                
                if count != 0 {
                    totalGrade += (Double(totalCategory) / Double(count)) * Double(distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces))! * 0.01
                    total += Double(distributionArray[1].trimmingCharacters(in: NSCharacterSet.whitespaces))!
                }
            }
            
            
            if total != 0 {
                var final = round(Double(totalGrade / 0.01))
                final = round(Double(final / total) / 0.01) / 100
                gradeLabel.text = String(final) + "%"
            } else {
                showAlertMessage(title: "Nothing is graded.", message: "")
            }
            
        } else {
            gradeLabel.text = "0.00%"
        }
    }
    
    
    /* Error check user data and if valid, store in arrays and UserDefaults; set all UI elements
       back to correct colors when adding new assignments */
    
    @objc func okayButtonPressed(sender: UIButton) {
        if self.assignmentText.text?.count != 0 && self.categoryText.text?.count != 0 && (self.gradeText.text?.count != 0 || self.dueDateText.text?.count != 0){
            var okay = false
            okay = checkDuplicateAssignment(assignment: self.assignmentText.text!)
            
            if okay {
                if !amEdittingCell {
                    var newString = ""
                    if self.gradeText.text?.count != 0 {
                        newString = self.assignmentText.text! + " | " + self.categoryText.text! + " | " + self.gradeText.text!

                    } else {
                        newString = self.assignmentText.text! + " | " + self.categoryText.text! + " | " + self.dueDateText.text!

                    }
                    self.tableData.append(newString)
                    self.listOfAssignments.beginUpdates()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.listOfAssignments.numberOfRows(inSection: tableData.count)
                    self.listOfAssignments.cellForRow(at: indexPath)
                    self.listOfAssignments.insertRows(at: [indexPath], with: .automatic)
                    self.listOfAssignments.endUpdates()
                    self.listOfAssignments.reloadData()
                } else {
                    if self.gradeText.text?.count != 0 {
                        self.tableData[edittingIndex] = self.assignmentText.text! + " | " + self.categoryText.text! + " | " + self.gradeText.text!

                    } else {
                        self.tableData[edittingIndex] = self.assignmentText.text! + " | " + self.categoryText.text! + " | " + self.dueDateText.text!

                    }
                    self.amEdittingCell = false
                    self.listOfAssignments.reloadData()
                }
                
                self.assignmentText.text = ""
                self.categoryText.text = ""
                self.gradeText.text = ""
                self.dueDateText.text = ""
                self.dueDateText.isHidden = true
                self.gradeText.isHidden = false
                self.radioButton.setOn(true, animated: false)
                self.picker.selectRow(0, inComponent: 0, animated: false)
                let todaysDate = Date()
                self.datePicker.setDate(todaysDate, animated: false)
                
                addAssignmentButton.isEnabled = true
                calculateGradeButton.isEnabled = true
                editButton.isEnabled = true
                bbItem.isEnabled = true
                gbItem.isEnabled = true
                listOfAssignments.isUserInteractionEnabled = true
                addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
                calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
                editButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor

                writeToPreferences(key: "Assignments", data: self.tableData)
                
                self.view.endEditing(true)
                
                customView.isHidden = true
            } else {
                showAlertMessage(title: "Assignment name already exists", message: "")
            }
        } else {
            showAlertMessage(title: "Invalid Assignment", message: "Make sure all fields are completed.")
        }
    }
    
    
    /* Error check user data and if valid, store in arrays; clear UITextFields when
       adding new grade distributions */
    
    @objc func okayButtonGradesPressed(sender: UIButton) {
        var okay = false
        var duplicate = false
        var zero = false
        if self.gradeDistributionText.text?.count != 0 && self.gradeCategoryText.text?.count != 0 {
            duplicate = checkDuplicateCategory(category: gradeCategoryText.text!)
            if !duplicate {
                okay = checkCategoryPercentage(percentage: self.gradeDistributionText.text!, category: gradeCategoryText.text!)
                
                let num = Double(gradeDistributionText.text!)!
                if num > 0.0 {
                    zero = false
                } else {
                    zero = true
                    okay = false
                }
            }
            
            if okay {
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
                
//                addAssignmentButton.isEnabled = true
//                calculateGradeButton.isEnabled = true
//                bbItem.isEnabled = true
//                gbItem.isEnabled = true
//                listOfAssignments.isUserInteractionEnabled = true
//                addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
//                calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
                
                self.gradeDistributionText.text = ""
                self.gradeCategoryText.text = ""
                
                writeToPreferences(key: "GradeDistributions", data: self.gradeTableData)
                
                listOfGradeDistributions.setContentOffset(.zero, animated: false)
                
//                self.view.endEditing(true)
//
//                customViewGrades.isHidden = true
                
            } else {
                if duplicate {
                    showAlertMessage(title: "Category name already exists.", message: "")
                } else if zero {
                    showAlertMessage(title: "Category value must be > 0.", message: "")
                } else {
                    showAlertMessage(title: "Category Percentage exceeds 100%", message: "")
                }
            }
        } else {
            showAlertMessage(title: "Invalid Category", message: "Make sure all fields are completed.")
        }
    }
    
    
    /* Clear all UITextFields, initialize UIPicker to first selection,
       put color back into all UI elements when either cancel button is pressed */
    
    @objc func cancelButtonPressed(sender: UIButton) {
        self.assignmentText.text = ""
        self.categoryText.text = ""
        self.gradeText.text = ""
        self.dueDateText.text = ""
        let date = Date()
        self.datePicker.setDate(date, animated: false)
        self.radioButton.setOn(true, animated: false)
        self.picker.selectRow(0, inComponent: 0, animated: false)
        self.gradeDistributionText.text = ""
        self.gradeCategoryText.text = ""
        
        self.dueDateText.isHidden = true
        self.gradeText.isHidden = false
        
        addAssignmentButton.isEnabled = true
        calculateGradeButton.isEnabled = true
        editButton.isEnabled = true
        bbItem.isEnabled = true
        gbItem.isEnabled = true
        listOfAssignments.isUserInteractionEnabled = true
        addAssignmentButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        calculateGradeButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        editButton.layer.borderColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0).cgColor
        listOfGradeDistributions.setContentOffset(.zero, animated: false)
        
        self.view.endEditing(true)
        
        customView.isHidden = true
        customViewGrades.isHidden = true
    }
    
    
    /* Not sure what this does */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /****** UITextField Delegate Function ******/
    /* Close keyboard when click off screen */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /****** UITextField Delegate Function ******/
    /* Initializes UITextField with first item in UIPickerView */
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == categoryText {
            if categoryText.text?.count == 0 {
                if pickerData.count > 0 {
                    categoryText.text = pickerData[0]
                }
            }
        } else if textField == dueDateText {
            if dueDateText.text?.count == 0 {
                let todaysDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                dueDateText.text = formatter.string(from: todaysDate)
            }
        }
    }
    
    
    /****** UITextField Delegate Function ******/
    /* Checks if only 1 period in grade score/distribution */
    
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
    
    
    /****** UIPickerView Delegate Function ******/
    /* Returns number of components in UIPickerView */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    /****** UIPickerView Delegate Function ******/
    /* Returns number of rows in components in UIPickerView */
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    
    /****** UIPickerView Delegate Function ******/
    /* Returns titleRow for UIPIckerView */
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    /****** UIPickerView Delegate Function ******/
    /* Put data in UITextField from UIPickerView selection */
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == picker {
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
    
    
    /****** UITableView Delegate Function ******/
    /* Returns number of sections in UITableView */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    /****** UITableView Delegate Function ******/
    /* Returns number of rows in UITableViews */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == listOfAssignments {
            return self.tableData.count
        } else {
            return self.gradeTableData.count
        }
    }
    
    
    /****** UITableView Delegate Function ******/
    /* Add data to cells of UITableView from arrays */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == listOfGradeDistributions {
            let cell = listOfGradeDistributions.dequeueReusableCell(withIdentifier: "gradeDistributionCell", for: indexPath)
            cell.textLabel?.text = self.gradeTableData[indexPath.row] + "%"
            cell.backgroundColor = UIColor.clear
            
            return cell
            
        } else {
            let cell : AssignmentTableViewCell = listOfAssignments.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! AssignmentTableViewCell
            let array: [String] = self.tableData[indexPath.row].components(separatedBy: "|")
            let assignment = array[0].trimmingCharacters(in: NSCharacterSet.whitespaces)
            let category = array[1].trimmingCharacters(in: NSCharacterSet.whitespaces)
            let grade = array[2].trimmingCharacters(in: NSCharacterSet.whitespaces)
            cell.assignmentNameText?.text = assignment
            cell.assignmentCategoryText?.text = category
            
            let charSet = CharacterSet(charactersIn: "/")
            if grade.rangeOfCharacter(from: charSet) != nil {
                cell.assignmentGradeText?.text = "Due: " + grade
            } else {
                cell.assignmentGradeText?.text = "Score: " + grade + "%"
            }

            return cell
        }
        
    }
    
    
    /****** UITableView Delegate Function ******/
    /* Delete cells from UITableView listOfAssignments and listOfGradeDistributions */
    
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
    
    
    /****** UITableView Delegate Function ******/
    /* deselects row after you click on it */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if estyle {
            return .none
        }
        return .delete

    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.tableData[sourceIndexPath.row]
        tableData.remove(at: sourceIndexPath.row)
        tableData.insert(movedObject, at: destinationIndexPath.row)
        writeToPreferences(key: "Assignments", data: self.tableData)
    }
    
    
    /****** Save data when added/edited ******/
    
    func writeToPreferences(key: String, data: [String]) {
        let preferences = UserDefaults.standard
        let currentKey = className + " " + key
        preferences.set(data, forKey: currentKey)
        let didSave = preferences.synchronize()
        if !didSave {
            debugPrint("FAILED: " + key)
        }
    }
    
    
    /****** Read data to initialize arrays ******/
    
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
