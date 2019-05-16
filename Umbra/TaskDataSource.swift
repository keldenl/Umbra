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
        let currGroup = data[indexPath.section]
        let currData = currGroup[indexPath.row]

        cell.taskName.text = currData.name
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()

        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        cell.taskDueDate.text = "\(dateFormatter.string(from: currData.dueDate)) at \(timeFormatter.string(from: currData.dueDate))"
        
        if !currData.done {
            cell.taskDone.backgroundColor = #colorLiteral(red: 0.150000006, green: 0.150000006, blue: 0.150000006, alpha: 1);
            cell.taskDone.setTitleColor(#colorLiteral(red: 0.9764705882, green: 0.5098039216, blue: 0.03529411765, alpha: 1), for: .normal)
        } else {
            cell.taskDone.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.5098039216, blue: 0.03529411765, alpha: 1);
            cell.taskDone.setTitleColor(.white, for: .normal)
        }
        
        var totalCountBefore : Int = 0
        for i in 0..<indexPath.section {
            totalCountBefore += data[i].count
        }
        
        cell.taskDone.tag = totalCountBefore + indexPath.row
        cell.layoutIfNeeded()

        
        return cell
    }
}
