//
//  ListViewController.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "ListViewController.h"
#import "Remind.h"
#import "RemindTableViewCell.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
@import CoreData;

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,DetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) NSMutableArray <Remind *>*reminds;

@end

@implementation ListViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.reminds = [[NSMutableArray alloc]init];
        [self reloadCell];
    }
    
    return self;
}

#pragma mark - Core Data

-(void) reloadCell{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Remind"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [context executeRequest:fetchRequest error:nil];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if(error){
        NSLog(@"error %@",error);
    } else {
        self.reminds = [results mutableCopy];
    }
    
}

-(void) saveToCoredata{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    [context save:nil];
}

-(void) deleteCoredata:(NSManagedObject *)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    [context deleteObject:sender];
    
}


#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    NSLog(@"%@",NSHomeDirectory());
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add/Delete/Move Remind
- (IBAction)addRemind:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    Remind *remind = [NSEntityDescription insertNewObjectForEntityForName:@"Remind" inManagedObjectContext:context];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.reminds insertObject:remind atIndex:0];
    [self saveToCoredata];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:YES];
    [self.tableView setEditing:editing animated:YES];
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        Remind *remind = self.reminds[indexPath.row];
        [self.reminds removeObject:remind];
        
        [self deleteCoredata:remind];
        [self saveToCoredata];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    Remind *remind = self.reminds[sourceIndexPath.row];
    [self.reminds removeObject:remind];
    [self.reminds insertObject:remind atIndex:destinationIndexPath.row];
    
    
    
    
}


#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reminds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindCell" forIndexPath:indexPath];
    
    Remind *remind = self.reminds[indexPath.row];
    
    cell.titleLabel.text = remind.title;
    cell.detailLabel.text = remind.detail;
    cell.dateLabel.text = remind.date;
    cell.timeLabel.text = remind.time;
    
    return cell;
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"segue"]){
        
        DetailViewController *detailVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Remind *remind = self.reminds[indexPath.row];
        
        detailVC.remind = remind;
        detailVC.delegate = self;
        
    }
}

#pragma mark - didFinshUpdate
-(void)didFinshUpdate:(Remind *)remind{
    
    NSInteger index = [self.reminds indexOfObject:remind];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}



@end