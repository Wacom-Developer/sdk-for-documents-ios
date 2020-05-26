//
//  DocumentViewController.h
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BXDocument;

@interface DocumentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


/**
 This is the baxrter document object loaded from the test PDF
 */
@property (nonatomic, strong) BXDocument *baxterDoc;


@end
