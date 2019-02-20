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
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionHeaders[section]
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var totalCount : Int = 0
//        for g in data { totalCount += g.count }
        return data[section].count
    }
    
    func returnCurrDataIndex(_ index : Int) -> Int {
        if index < data[0].count { return 0 }
        if index < (data[0].count + data[1].count) { return 1 }
        if index < (data[0].count + data[1].count + data[2].count) { return 2 }
        return 3
    }
    
//    section 1 (3)
//    0 new
//    1 new
    //2 new
//    section 2 (1)
//    3 (0) new
    // 3 - ( 4 - 1 )
    // 0 - (4-3)
    // 4 - (3 - 3)
    
    // 3 - (3 - 2) = 2 this works
    // 4 - (3 - 2) =
    // ()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! MainCell
        print("This is the data: \(data)")
        let currGroup = data[indexPath.section]
        print("Printing cell #\(indexPath.row)")
        let currData = currGroup[indexPath.row]
        
        // [indexPath.row]
        print(currData.name)
        cell.taskName.text = currData.name
        
//        Date Formatter Information
//
//        Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
//        09/12/2018                        --> MM/dd/yyyy
//        09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
//        Sep 12, 2:11 PM                   --> MMM d, h:mm a
//        September 2018                    --> MMMM yyyy
//        Sep 12, 2018                      --> MMM d, yyyy
//        Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
//        2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
//        12.09.18                          --> dd.MM.yy
//        10:41:02.112                      --> HH:mm:ss.SSS
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var currData = data[returnCurrDataIndex(indexPath.row)]
        if editingStyle == .delete {
            currData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
