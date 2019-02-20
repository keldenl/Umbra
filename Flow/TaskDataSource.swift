//
//  QuizDataSource.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import Foundation
import UIKit

class TaskDataSource : NSObject, UITableViewDataSource
{
    var data : [[Task]]
    init(_ elements : [[Task]]) {
        data = elements
    }
    
    // Section Header
    let sectionHeaders : [String] = ["Overdue", "Today", "Tomorrow", "Upcoming"]
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    // Table Cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! MainCell
        print("This is the data: \(data)")
        let currGroup = data[indexPath.section]
        print("Printing cell #\(indexPath.row)")
        let currData = currGroup[indexPath.row]

        cell.taskName.text = currData.name
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()

        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        cell.taskDueDate.text = "\(dateFormatter.string(from: currData.dueDate)) at \(timeFormatter.string(from: currData.dueDate))"
        
        let doneImg = currData.done ? UIImage(named: "done") : UIImage(named: "undone")
        cell.taskDone.setImage(doneImg, for: [])
        
        var totalCountBefore : Int = 0
        for i in 0..<indexPath.section {
            totalCountBefore += data[i].count
        }
        cell.taskDone.tag = totalCountBefore + indexPath.row
        
        return cell
    }
}
