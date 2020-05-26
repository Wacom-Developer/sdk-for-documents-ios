//
//  PageViewController.m
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import "PageViewController.h"
#import "FieldViewController.h"


@interface PageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) BXField *selectedField;

@end

@implementation PageViewController

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
    FieldViewController *target = [segue destinationViewController];
    target.field = self.selectedField;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) { //This is the docuemnt details section, we we list the the document level defines
        return(2);
    } else { //This is the page section, so list the pages
        return([[self.baxterPage getFields] count]);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return(2);
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
    
    if(indexPath.section == 0) { //Page level
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        switch (indexPath.row) {
            case 0: {//Page UUID Info. This is the PDF page and barcode data
                BXPageID *pgid = [self.baxterPage getPageID]; //Tuple containing PDF ID and Barcode
                
                cell.textLabel.text = @"Page UUID";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"[PDFID]:%@   [Barcode]:%@",[pgid pdfpage], [pgid uuid]];
                break;
            }
            case 1: { //Any pen data captured outside of the field region
                cell.textLabel.text = @"Pen Data";
                BXPenData *penData = [self.baxterPage getPenData];
                unsigned long strokeCount = [[penData getStrokes] count];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu strokes on page", strokeCount];
                break;
            }
        }
    } else { //Field list
        BXField *field = [self.baxterPage getFields][indexPath.row];

        cell.textLabel.text = [field tag]; //Use the user defined tag of the field for the label
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return(cell);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1) { //browse to page view
        self.selectedField = [self.baxterPage getFields][indexPath.row];
        [self performSegueWithIdentifier:@"field" sender:self];
    }
}


@end
