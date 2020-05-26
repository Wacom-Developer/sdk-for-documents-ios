//
//  PageViewController.h
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Baxter/Baxter.h>


/**
 Basic table view that shows the baxter page details in the top portion
 */
@interface PageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


/**
 The baxter page to display details about
 */
@property (nonatomic, strong) BXPage *baxterPage;

@end
