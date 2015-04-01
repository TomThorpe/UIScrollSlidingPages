//
//  TabOneViewController.m
//  UITableViewZoomController
//
//  Created by Thomas Thorpe on 25/02/2013.
//  Copyright (c) 2013 Thomas Thorpe. All rights reserved.
//

#import "TabTwoViewController.h"

@implementation TabTwoViewController

-(void)viewDidLoad{
    self.cellZoomInitialAlpha = [NSNumber numberWithFloat:1.0];
    self.cellZoomAnimationDuration = [NSNumber numberWithFloat:0.5];
    self.cellZoomXScaleFactor = [NSNumber numberWithFloat:0.9];
    self.cellZoomYScaleFactor = [NSNumber numberWithFloat:0.9];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"This is cell number %ld", (long)indexPath.row];
    cell.detailTextLabel.text = @"Some more text here";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cell Tapped" message:[NSString stringWithFormat:@"Cell %ld tapped", (long)indexPath.row] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

- (void)dealloc {
    NSLog(@"Tab Two Dealloc");
}



@end
