//
//  SelectPlaceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SelectPlaceViewController.h"

@interface SelectPlaceViewController ()

@end

@implementation SelectPlaceViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    //When user click on next
}
#pragma mark - end

#pragma mark - Table view delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;//arary count
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%li%li",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
    //display data in cell
}
#pragma mark - end

@end
