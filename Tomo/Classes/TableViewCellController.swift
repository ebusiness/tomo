//
//  TableViewCellController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension MCSwipeTableViewCell{
    
    typealias SuccessHandler = ((cell:MCSwipeTableViewCell, state:MCSwipeTableViewCellState, mode:MCSwipeTableViewCellMode)->())
    // Swope switch
    func setSwopeON(withLeft:Bool,withRight:Bool = false){
        self.modeForState1 = .None
        self.modeForState2 = .None
        self.modeForState3 = .None
        self.modeForState4 = .None
        
        if withLeft {
            self.modeForState1 = .Switch
            self.modeForState2 = .Switch
        }
        if withRight {
            self.modeForState3 = .Switch
            self.modeForState4 = .Switch
        }
    }
    //ui
    func setSwipe(state: MCSwipeTableViewCellState,successHandler: SuccessHandler?) {
        var backgroundColor:UIColor!
        
        let image = Util.coloredImage(UIImage(named: "ic_add_black_48dp")!, color: UIColor.whiteColor())
        let imageView = UIImageView(image: image)
        imageView.contentMode =  .Center
        
        //        let uilabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        //        uilabel.text = "sssss"
        
        if state == .State1 || state == .State2 {
            
            backgroundColor = UIColor.greenColor()
        }else if  state == .State3 || state == .State4 {
            
            backgroundColor = UIColor.redColor()
        }
        self.setSwipeGestureWithView(imageView, color: backgroundColor, mode: .Switch, state: state, completionBlock: { (cell, state, model) -> Void in
            if let successHandler = successHandler {
                successHandler(cell: cell,  state: state, mode: model)
            }
        })
        
    }
    
    func setHandler(withLeft:Bool,withRight:Bool = false,handler:SuccessHandler){
        if withLeft {
            self.setSwipe(.State1,successHandler: handler)
            self.setSwipe(.State2,successHandler: handler)
        }
        if withRight {
            self.setSwipe(.State3,successHandler: handler)
            self.setSwipe(.State4,successHandler: handler)
        }
    }
}
