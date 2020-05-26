//
//  ViewController.m
//  BaxterSampleApp
//
//  Created by Joss Giffard-Burley on 28/04/2017.
//  Copyright © 2017 Wacom. All rights reserved.
//

#import "ViewController.h"
#import "BaxterSampleApp-Swift.h"
#import "DocumentViewController.h"

#import <Baxter/Baxter.h>

@interface ViewController ()
@property (nonatomic, strong) NSURL *filePath;
@property (nonatomic, strong) NSString *fsRoot;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DirectoryWatcher *dirWatcher;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Select File";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.fsRoot = [paths firstObject];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    __weak ViewController *weakSelf = self;
    //Automatically update table when new PDFs arrive in documents directory
    self.dirWatcher = [DirectoryWatcher directoryWatcher:self.fsRoot startImmediately:YES callback:^{
        if(weakSelf != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    //Init the baxter license
    NSString *licenseData = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"demo" withExtension:@"lic"] encoding:NSUTF8StringEncoding error:NULL];
    [BXLicense.sharedInstance setLicense:licenseData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Load PDF into VC
    if([segue.identifier isEqualToString:@"document"]) {
        DocumentViewController *dc = [segue destinationViewController];
        dc.baxterDoc = [[BXDocument alloc] initWithfile:self.filePath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *fileName = [[tableView cellForRowAtIndexPath:indexPath] textLabel].text;
    
    if([[[fileName pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
        self.filePath = [NSURL fileURLWithPath:filePath];
        [self performSegueWithIdentifier:@"document" sender:self];
    } else {
        UIAlertController *av = [UIAlertController alertControllerWithTitle:@"Error" message:@"Only PDF files are supported" preferredStyle:UIAlertControllerStyleAlert];
        [av addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [av dismissViewControllerAnimated:YES completion:NULL];
        }]];
        [self presentViewController:av animated:YES completion:NULL];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.fsRoot error:NULL];

    return [files count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.fsRoot error:NULL];
    cell.textLabel.text = [files[indexPath.row] lastPathComponent];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return(cell);
}



@end
