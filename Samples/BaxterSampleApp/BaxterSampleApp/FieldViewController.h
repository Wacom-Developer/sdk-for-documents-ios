//
//  FieldViewController.h
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Baxter/Baxter.h>

@interface FieldViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


/**
 The field to display the details of
 */
@property (nonatomic, strong) BXField *field;
@end
