//
//  ViewController.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    var editingTaskId = (-1,-1)
    
    @IBOutlet weak var mainNavBar: UINavigationBar!
    @IBOutlet weak var mainNavText: UINavigationItem!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var newTaskPicker: UIDatePicker!
    @IBOutlet weak var newTaskTextfield: UITextField!
    
    @IBOutlet weak var navBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskView: UIView!
    @IBOutlet weak var newTaskViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskTextfieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskTextfieldTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var newTaskAddButton: UIButton!
    
    // New Task Functions
    @IBAction func newTaskTriggered(_ sender: Any) {
        newTaskVisible(visible: true)
    }
    
    @IBAction func newTaskCancel(_ sender: Any) {
        newTaskVisible(visible: false)
        newTaskPicker.date = Date()
    }
    
    func newTaskVisible(visible : Bool) {
        if (!visible) {
            view.endEditing(true) // Remove focus
            // Reset options
            self.newTaskTextfield.text = ""
            newTaskAddButton.setTitle("Add task to list", for: [])
            newTaskPicker.date = Date()

        }
        let multiplier : CGFloat = visible ? 1 : -1
        
        navBarConstraint.constant -= 50 * multiplier
        newTaskViewConstraint.constant -= 50 * multiplier
        newTaskTextfieldConstraint.constant -= 50 * multiplier
        newTaskTextfieldTrailingConstraint.constant += 60 * multiplier
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut,
                       animations: {
                        self.newTaskView.alpha = visible ? 1 : 0
                        self.mainNavBar.alpha = visible ? 0 : 1
                        self.view.layoutIfNeeded()
        })
    }
    
    // Custom functions
    //
    func updateTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        mainNavText.title = dateFormatter.string(from: Date())
    }
    
    // Data Manipulation
    func convertToOneArray(_ arr : [[Task]]) -> [Task] {
        var returnArray : [Task] = []
        for e in arr {
            returnArray.append(contentsOf: e)
        }
        return returnArray
    }
    
    func hideDoneTasks(_ tasks : [[Task]]) -> [[Task]] {
        var returnTasks : [[Task]] = [[],[],[],[]]
        for i in 0..<tasks.count {
            for t in tasks[i] {
                if (!t.done) { returnTasks[i].append(t) }
            }
        }

        return returnTasks
    }
    
    func resortTasks(_ tasks : [Task]) -> [[Task]]  {
        var returnTasks = [[Task]]()
        var overdue = [Task]()
        var today = [Task]()
        var tomorrow = [Task]()
        var other = [Task]()
        
        for t in tasks {
            let dueDiff = Calendar.current.dateComponents([.day, .hour], from: Date(), to: t.dueDate)
            if dueDiff.day ?? 0 < 0 { overdue.append(t) }
            else {
                switch t.dueDate {
                case let d where Calendar.current.isDateInToday(d): today.append(t)
                case let d where Calendar.current.isDateInTomorrow(d): tomorrow.append(t)
                default: other.append(t)
                }
            }
        }
        
        returnTasks = [overdue, today, tomorrow, other]
        for i in 0..<returnTasks.count {
            returnTasks[i] = returnTasks[i].sorted(by: { $0.dueDate < $1.dueDate })
        }
        
        return returnTasks
    }
    
    func reloadData() {
        tasks = hideDoneTasks(resortTasks(fullTaskList))
        fullTaskList = convertToOneArray(tasks)
        dataSource = TaskDataSource(tasks)
        mainTableView.dataSource = dataSource
        mainTableView.reloadData()
    }
    
    
    
    // Main interactions
    @IBAction func createTask(_ sender: Any) {
        if (editingTaskId != (-1, -1)) {
            self.tasks[editingTaskId.0][editingTaskId.1].name = newTaskTextfield.text!
            self.tasks[editingTaskId.0][editingTaskId.1].dueDate = newTaskPicker.date
            editingTaskId = (-1,-1)
        }
        else {
            self.fullTaskList.append(Task(name:newTaskTextfield.text!, dueDate: newTaskPicker.date))
            print("added new task")
        }
        self.reloadData()
        newTaskVisible(visible: false)
    }
    
    @IBAction func donePressed (_ sender : UIButton) {
        fullTaskList[sender.tag].done = !fullTaskList[sender.tag].done
        mainTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.reloadData() }
    }
    
    
    // Data
    var dataSource : TaskDataSource? = nil
    var taskRepo : TaskRepository = (UIApplication.shared.delegate as! AppDelegate).taskRepository
    var tasks : [[Task]] = [[]]
    var fullTaskList : [Task] = []
    let sectionHeaders : [String] = ["Overdue", "Today", "Tomorrow", "Upcoming"]

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row at \(indexPath.row)")
        editingTaskId = (indexPath.section, indexPath.row)
        newTaskTextfield.text = tasks[editingTaskId.0][editingTaskId.1].name
        newTaskPicker.date = tasks[editingTaskId.0][editingTaskId.1].dueDate
        newTaskAddButton.setTitle("Apply changes", for: [])
        newTaskTextfield.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black

        let headerLabel = UILabel(frame: CGRect(x: 12, y: 0, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)
        headerLabel.textColor = UIColor.white
        headerLabel.text = sectionHeaders[section]
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateTitle()
        
        tasks = taskRepo.getTasks()
        fullTaskList = convertToOneArray(tasks)
        dataSource = TaskDataSource(tasks)
        mainTableView.dataSource = dataSource
        mainTableView.delegate = self
        
        newTaskPicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    // Status bar update
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

