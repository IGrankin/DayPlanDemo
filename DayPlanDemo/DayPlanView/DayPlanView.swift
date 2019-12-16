//
//  DayPlanView.swift
//  DayPlanDemo
//
//  Created by admin on 13/12/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

struct Event {
    var startTime: Date
    var endTime: Date
}

struct Calendar {
    var events: [Event]
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
    
    var backgroundEventHeight: CGFloat = 70
    private var contentSize: CGSize = CGSize.zero
    private var totalHeight: CGFloat = 0
    private var currentMembers: [Calendar] = [Calendar]()
    private var timelineViewHeight: CGFloat = 20
    
    private var scrollview: UIScrollView = UIScrollView()
    private var timelineView: UIView = UIView()
    
    private var shapeLayersArray: [CAShapeLayer] = [CAShapeLayer]()
    
    private var events: [Event] = [Event]()
    
    //EventView
    let eventViewHeight = 50
    let eventViewMinWidth = 70
    let eventOffsetHeight: CGFloat = 10
    
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
        events.removeAll()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        events.append(Event(startTime: formatter.date(from: "2016/10/08 02:00")!, endTime: formatter.date(from: "2016/10/08 05:10")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 03:10")!, endTime: formatter.date(from: "2016/10/08 08:10")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 05:11")!, endTime: formatter.date(from: "2016/10/08 08:10")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 05:11")!, endTime: formatter.date(from: "2016/10/08 08:10")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 03:11")!, endTime: formatter.date(from: "2016/10/08 07:23")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 02:00")!, endTime: formatter.date(from: "2016/10/08 03:09")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 02:00")!, endTime: formatter.date(from: "2016/10/08 04:23")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 02:00")!, endTime: formatter.date(from: "2016/10/08 05:10")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 03:00")!, endTime: formatter.date(from: "2016/10/08 10:10")!))
        events.append(Event(startTime: formatter.date(from: "2016/10/08 01:55")!, endTime: formatter.date(from: "2016/10/08 06:48")!))
//        events.append(Event(startTime: formatter.date(from: "2016/10/08 05:00")!, endTime: formatter.date(from: "2016/10/08 06:10")!))
//        events.append(Event(startTime: formatter.date(from: "2016/10/08 05:00")!, endTime: formatter.date(from: "2016/10/08 06:10")!))
        
        let firstCalendar = Calendar(events: events)
        
        currentMembers.append(firstCalendar)
        
        
//        for currentMember in currentMembers {
//            totalHeight += backgroundEventHeight
//        }
    }
    
    override func layoutSubviews() {
        
        totalHeight = self.frame.size.height > totalHeight ? self.frame.size.height : totalHeight
        timelineView.frame = CGRect(x: 0, y: 0, width: 24 * hourWidth, height: timelineViewHeight)
        timelineView.backgroundColor = .red
        scrollview.frame = CGRect(x: 0, y: timelineViewHeight, width: self.frame.size.width, height: self.frame.size.height)
        contentSize = CGSize(width: 24 * hourWidth, height: totalHeight)
        scrollview.contentSize = contentSize
        scrollview.backgroundColor = .clear
        scrollview.delegate = self
    
        
        
        drawLayers()
        
        showEventsViews()
        super.layoutSubviews()
    }
    
    func drawLayers() {
        for layer in shapeLayersArray {
            layer.removeFromSuperlayer()
        }
        shapeLayersArray.removeAll()
        
        drawMemberLines()
        drawHoursLines()
        drawHoursLabels()
    }
    
    func showEventsViews() {
        //TODO: remove subviews
        for subview in scrollview.subviews {
            if !subview.isKind(of: NSClassFromString("_UIScrollViewScrollIndicator")!) {
                subview.removeFromSuperview()
            }
        }
        for event in events {
            let eventView = UIView()
            eventView.backgroundColor = .random()
            let timeDiff = (event.endTime.timeIntervalSince1970 - event.startTime.timeIntervalSince1970) / 3600
            let tempEventViewWidth = CGFloat(timeDiff) * hourWidth
            let eventViewWidth = tempEventViewWidth < hourWidth ? hourWidth : tempEventViewWidth
            //Point calculation
            /// x coordinate calculation
            let hour = NSCalendar.current.component(.hour, from: event.startTime)
            let minute = NSCalendar.current.component(.minute, from: event.startTime)
            let xCoord = CGFloat(hour) * hourWidth + CGFloat(minute) / 60 * hourWidth
            ///y coordinate calculation
            var tempRect = CGRect(x: xCoord, y: eventOffsetHeight, width: CGFloat(eventViewWidth), height: CGFloat(eventViewHeight))
            var didFoundYCoord = false
            var shouldUpdateScrollViewHeight = false
            while (!didFoundYCoord) {
                for currentEventView in scrollview.subviews {
                    if tempRect.intersects(currentEventView.frame) {
                        tempRect.origin.y += backgroundEventHeight
                        didFoundYCoord = false
                        print("temp.origin.y \(tempRect.origin.y) totalHeight \(totalHeight)")
                        if tempRect.origin.y + CGFloat(backgroundEventHeight) > totalHeight  {
                            shouldUpdateScrollViewHeight = true
                        }
                        break
                    }
                    didFoundYCoord = true
                }
            }
            if shouldUpdateScrollViewHeight {
                totalHeight += tempRect.origin.y + CGFloat(backgroundEventHeight) - totalHeight
                scrollview.contentSize.height = totalHeight
                drawLayers()
            }
            eventView.frame = tempRect
            
            let timeLabel = UILabel()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            timeLabel.text = "\(dateFormatter.string(from: event.startTime))-\(dateFormatter.string(from: event.endTime))"
            timeLabel.frame = eventView.bounds
            eventView.addSubview(timeLabel)
            scrollview.addSubview(eventView)
        }
    }
    
    func drawHoursLabels() {
        for currentHour in 0..<24 {
            let hourLabel = UILabel()
            hourLabel.text = "\(currentHour):00"
            hourLabel.frame = CGRect(x: CGFloat(currentHour) * hourWidth, y: 0, width: hourWidth, height: timelineViewHeight)
            timelineView.addSubview(hourLabel)
        }
    }
    
    func drawHoursLines() {
        for currentHour in 0..<24 {
            let dashedHourLine = CAShapeLayer()
            dashedHourLine.zPosition = scrollview.layer.zPosition-1
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
        let backgroundNumbers = Int(Float(totalHeight / backgroundEventHeight).rounded())
        for currentBackground in 0..<backgroundNumbers {
            let dashedHourLine = CAShapeLayer()
            dashedHourLine.zPosition = scrollview.layer.zPosition-1
            shapeLayersArray.append(dashedHourLine)
            let currentColor = currentBackground % 2 == 0 ? UIColor.white : UIColor.lightGray
            dashedHourLine.fillColor = currentColor.cgColor
            
            let length = backgroundEventHeight
            let coordY:CGFloat = lastOffset + length
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: lastOffset))
            bezierPath.addLine(to: CGPoint(x: 0, y: coordY))
            bezierPath.addLine(to: CGPoint(x: contentSize.width, y: coordY))
            bezierPath.addLine(to: CGPoint(x: contentSize.width, y: lastOffset))
            bezierPath.close()
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

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
