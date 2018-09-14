//
//  OFACourseDetailsInstructorsTableViewCell.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

protocol CourseDetailsInstructorsDelegate{
    func updateRowHeightForInstructors(with array:NSMutableArray)
}

class OFACourseDetailsInstructorsTableViewCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableViewInstructorsList: UITableView!
    var delegate:CourseDetailsInstructorsDelegate!
    var arrayInstructors = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK:- TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayInstructors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewInstructorsList.dequeueReusableCell(withIdentifier: "CourseInstructorsList", for: indexPath) as! OFACourseInstructorsTableViewCell
        let dicInstructors = self.arrayInstructors[indexPath.row] as! NSDictionary
        if dicInstructors["rl_name"] != nil {
            cell.customizeCellWithDetails(imageURL: "\(dicInstructors["us_image"]!)", fullName: "\(dicInstructors["us_name"]!)", designation: "\(dicInstructors["rl_name"]!)")
        }else{
            cell.customizeCellWithDetails(imageURL: "\(dicInstructors["us_image"]!)", fullName: "\(dicInstructors["us_name"]!)", designation: "")
        }
        return cell
    }
}
