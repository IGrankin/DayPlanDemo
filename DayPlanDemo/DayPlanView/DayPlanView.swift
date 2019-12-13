//
//  DayPlanView.swift
//  DayPlanDemo
//
//  Created by admin on 13/12/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

struct Calendar {
    var length: CGFloat
}

class DayPlanView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    static var previousOffset: CGFloat = 0
    
    private var hourWidth: CGFloat = UIScreen.main.bounds.width / 3
    private var minSectionHeight: CGFloat = 250
    private var contentSize: CGSize = CGSize.zero
    private var totalHeight: CGFloat = 0
    private var currentMembers: [Calendar] = [Calendar]()
    private var timelineViewHeight: CGFloat = 20
    
    private var scrollview: UIScrollView = UIScrollView()
    private var timelineView: UIView = UIView()
    
    private var shapeLayersArray: [CAShapeLayer] = [CAShapeLayer]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        totalHeight = 0
        self.addSubview(scrollview)
        self.addSubview(timelineView)
        currentMembers.removeAll()
        let firstCalendar = Calendar(length: 70)
        let secondCalendar = Calendar(length: 140)
        let thirdCalendar = Calendar(length: 100)
        
        currentMembers.append(firstCalendar)
        currentMembers.append(secondCalendar)
        currentMembers.append(thirdCalendar)
        currentMembers.append(Calendar(length: 70))
        currentMembers.append(Calendar(length: 70))
        currentMembers.append(Calendar(length: 70))
        currentMembers.append(Calendar(length: 70))
        currentMembers.append(Calendar(length: 70))
        currentMembers.append(Calendar(length: 70))
        
        for currentMember in currentMembers {
            totalHeight += currentMember.length
        }
    }
    
    override func layoutSubviews() {
        for layer in shapeLayersArray {
            layer.removeFromSuperlayer()
        }
        shapeLayersArray.removeAll()
        
        timelineView.frame = CGRect(x: 0, y: 0, width: 24 * hourWidth, height: timelineViewHeight)
        timelineView.backgroundColor = .red
        scrollview.frame = CGRect(x: 0, y: timelineViewHeight, width: self.frame.size.width, height: self.frame.size.height)
        contentSize = CGSize(width: 24 * hourWidth, height: totalHeight)
        scrollview.contentSize = contentSize
        scrollview.backgroundColor = .clear
        scrollview.delegate = self
    
        drawMemberLines()
        drawHoursLines()
        //TODO: make method
        drawHoursLabels()
        
        
        super.layoutSubviews()
    }
    
    func drawHoursLabels() {
        for currentHour in 0..<24 {
            var hourLabel = UILabel()
            hourLabel.text = "\(currentHour):00"
            hourLabel.frame = CGRect(x: CGFloat(currentHour) * hourWidth, y: 0, width: hourWidth, height: timelineViewHeight)
            timelineView.addSubview(hourLabel)
        }
    }
    
    func drawHoursLines() {
        for currentHour in 0..<24 {
            let dashedHourLine = CAShapeLayer()
            shapeLayersArray.append(dashedHourLine)
            dashedHourLine.strokeColor = UIColor.black.cgColor
            dashedHourLine.lineWidth = 1
            dashedHourLine.lineDashPattern = [4,4]
            let path = CGMutablePath()
            let coordX:CGFloat = hourWidth * CGFloat(currentHour)
            path.addLines(between: [CGPoint(x: coordX, y: 0), CGPoint(x: coordX, y: totalHeight)])
            dashedHourLine.path = path
            scrollview.layer.addSublayer(dashedHourLine)
        }
    }
    
    func drawMemberLines() {
        var lastOffset: CGFloat = 0
        for currentMember in 0..<currentMembers.count {
            let dashedHourLine = CAShapeLayer()
            shapeLayersArray.append(dashedHourLine)
            let currentColor = currentMember % 2 == 0 ? UIColor.white : UIColor.lightGray
            dashedHourLine.fillColor = currentColor.cgColor
            
            let length = currentMembers[currentMember].length
            let coordY:CGFloat = lastOffset + length
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: lastOffset))
            bezierPath.addLine(to: CGPoint(x: 0, y: coordY))
            bezierPath.addLine(to: CGPoint(x: contentSize.width, y: coordY))
            bezierPath.addLine(to: CGPoint(x: contentSize.width, y: lastOffset))
            bezierPath.close()
            print("member N \(currentMember) bezier \(bezierPath)")
            lastOffset = coordY
            
            dashedHourLine.path = bezierPath.cgPath
            scrollview.layer.addSublayer(dashedHourLine)
        }
    }
    

}

extension DayPlanView : UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        if scrollview.contentOffset.x < 0 {
            scrollview.contentOffset.x = 0
        }
        timelineView.frame.origin.x += DayPlanView.previousOffset - scrollview.contentOffset.x
        DayPlanView.previousOffset = scrollview.contentOffset.x
       
    }
}
