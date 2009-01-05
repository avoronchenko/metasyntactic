//
//  QuestionsViewController.m
//  YourRights
//
//  Created by Cyrus Najmabadi on 1/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ToughQuestionsViewController.h"

#import "AnswerViewController.h"
#import "Model.h"
#import "ToughAnswerViewController.h"
#import "ViewControllerUtilities.h"
#import "WrappableCell.h"

@interface ToughQuestionsViewController()
@end


@implementation ToughQuestionsViewController

- (void) dealloc {
    [super dealloc];
}


- (id) init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.navigationItem.titleView = [ViewControllerUtilities viewControllerTitleLabel:NSLocalizedString(@"Tough Questions", nil)];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease]] autorelease];
    }
    
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void) majorRefresh {
    [self.tableView reloadData];
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    [self majorRefresh];
}


- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self majorRefresh];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger)section {
    return [Model toughQuestions].count;
}


- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    NSString* text = [[Model toughQuestions] objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[[WrappableCell alloc] initWithTitle:text] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (CGFloat)         tableView:(UITableView*) tableView
      heightForRowAtIndexPath:(NSIndexPath*) indexPath {
    return [WrappableCell height:[[Model toughQuestions] objectAtIndex:indexPath.row] accessoryType:UITableViewCellAccessoryDisclosureIndicator];
}


- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    NSString* question = [[Model toughQuestions] objectAtIndex:indexPath.row];
    NSString* answer = [Model answerForToughQuestion:question];
    ToughAnswerViewController* controller = [[[ToughAnswerViewController alloc] initWithQuestion:question answer:answer] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
