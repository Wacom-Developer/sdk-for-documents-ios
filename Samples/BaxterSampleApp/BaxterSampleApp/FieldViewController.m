//
//  FieldViewController.m
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import "FieldViewController.h"

@interface FieldViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return(8);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return(1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return(@"Page Level Details");
    } else {
        return (@"Field List (Tap to examine page)");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PAGECELL"];
    
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        switch (indexPath.row) {
            case 0: {//Field ID
                cell.textLabel.text = @"ID";
                cell.detailTextLabel.text = [self.field fieldID];
                break;
            }
            case 1: { //Field Location
                cell.textLabel.text = @"Location";
                cell.detailTextLabel.text = NSStringFromCGRect([self.field location]);
                
                break;
            }
            case 2: { //Field Type
                cell.textLabel.text = @"Type";
                cell.detailTextLabel.text = [self fieldTypeToString:self.field.type];
                break;
            }
            case 3: { //Field Tag
                cell.textLabel.text = @"Tag";
                cell.detailTextLabel.text = self.field.tag;
                break;
            }
            case 4: { //Required
                cell.textLabel.text = @"Required";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.field.required ? @"Yes" : @"No"];
                break;
            }
            case 5: { //Pen data
                cell.textLabel.text = @"Pen data";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu strokes", [[[self.field getPenData] getStrokes] count]];
                break;
            }
            case 6: { //Completion time
                cell.textLabel.text = @"Completion Time";
                cell.detailTextLabel.text = self.field.completionTime.length > 0 ? self.field.completionTime : @"No data";
                break;
            }
            case 7: { //Data (e.g. signature, HWR)
                cell.textLabel.text = @"Translated Data";
                cell.detailTextLabel.text = self.field.data.length > 0 ? self.field.data : @"No data";
                break;
            }
        }
  
    
    return(cell);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/**
 Helper function to convert between field type and text

 @param type The field type to convert
 @return The human readable string version of the field
 */
- (NSString *)fieldTypeToString:(BXFieldType)type {
    switch (type ) {
        case boolean:
            return @"Boolean";
        case freehand:
            return @"Freehand";
        case number:
            return @"Number";
        case signature:
            return @"Signature";
        case text:
            return @"Text";
        case unknown:
        default:
            return @"Unkown";
    }
}

@end
