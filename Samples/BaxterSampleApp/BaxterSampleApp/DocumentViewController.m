//
//  DocumentViewController.m
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import "DocumentViewController.h"
#import "PageViewController.h"
#import <Baxter/Baxter.h>

@interface DocumentViewController ()

/**
 Tablew view used for UI display
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 The last page selected in the table view (used for segue)
 */
@property (nonatomic, strong) BXPage *lastSelectedPage;

@end


/**
 Basic table view controller that displays the list of baxter pages in the document. Tapping on a page will take you to the list of fields for that page
 */
@implementation DocumentViewController

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PageViewController *target = [segue destinationViewController];
    target.baxterPage = self.lastSelectedPage;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) { //This is the docuemnt details section, we we list the the document level defines
        return(4);
    } else { //This is the page section, so list the pages
        return([[self.baxterDoc getPages] count]);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return(2);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return(@"Document Level Details");
    } else {
        return (@"Page List (Tap to examine page)");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DOCCELL"];
    
    if(indexPath.section == 0) { //Document level
        cell.accessoryType = UITableViewCellAccessoryNone;

        switch (indexPath.row) {
            case 0: {//Authoring tool
                BXAuthoringTool *tool = [self.baxterDoc getAuthoringTool];
                cell.textLabel.text = @"Authoring Tool Version";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[Version]:%@   [Name]:%@",[tool getVersion], [tool getName]];
                break;
            }
            case 1: { //Document completion time
                cell.textLabel.text = @"Document Completion Time";
                NSString *completeTime = [self.baxterDoc getDocumentCompletionTime];
                if([completeTime length] > 0) {
                    cell.detailTextLabel.text = [self.baxterDoc getDocumentCompletionTime];
                } else {
                    cell.detailTextLabel.text = @"No data";
                }
                break;
            }
            case 2: { //Smart pad
                BXSmartPad *pad = [self.baxterDoc getSmartPad];
                
                cell.textLabel.text = @"Smart Pad Details";
                if([[pad getName] length] > 1 && [[pad padID] length] > 1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"[Name]:%@   [UUID]:%@", [pad getName], [pad padID]];
                } else {
                    cell.detailTextLabel.text = @"No data";
                }
                
                break;
            }
            case 3: { //Client app
                BXClientApp *app = [self.baxterDoc getClientApp];
                cell.textLabel.text = @"Client App Details";
                if([[app getName] length] > 1) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[Name]:%@   [OS]:%@   [Version]:%@", [app getName], [app os], [app version]];
                } else {
                    cell.detailTextLabel.text = @"No data";
                }
                break;
            }
        }
    } else { //Page list
        BXPage *pg = [self.baxterDoc getPages][indexPath.row];
        cell.textLabel.text = [pg uuid]; //Set the page barcode as the cell title
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return(cell);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1) { //browse to page view
        self.lastSelectedPage = [self.baxterDoc getPages][indexPath.row];
        [self performSegueWithIdentifier:@"page" sender:self];
    }
}


@end
