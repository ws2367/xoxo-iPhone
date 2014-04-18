//
//  MultiplePeoplePickerViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/15/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

#import "MultiplePeoplePickerViewController.h"

#import "UIColor+MSColor.h"

@interface MultiplePeoplePickerViewController()
@property (nonatomic, strong) NSArray *arrayOfPeople;
@property (nonatomic, assign) CFArrayRef people;
@property (nonatomic, strong) NSMutableSet *selectedPeople;
@end

static NSString *CellIdentifier = @"ContactCell";

@implementation MultiplePeoplePickerViewController
@synthesize arrayOfPeople = _arrayOfPeople;
@synthesize people = _people;
@synthesize selectedPeople = _selectedPeople;

- (NSMutableSet *) selectedPeople {
    if (_selectedPeople == nil) {
        _selectedPeople = [[NSMutableSet alloc] init];
    }
    return _selectedPeople;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    view.backgroundColor = [UIColor colorForYoursOrange];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //alloc done button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorForYoursWhite] forState:UIControlStateNormal];
    [doneButton setFrame:CGRectMake(260, 20, 50, 40)];
    [self.view addSubview:doneButton];
    [doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    //alloc table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, 498)
                                                          style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    self.people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    self.arrayOfPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    [tableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    int index = indexPath.row;
    ABRecordRef person = CFArrayGetValueAtIndex(self.people, index);
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                         kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                        kABPersonLastNameProperty);

    NSMutableString *name = [NSMutableString stringWithString:@""];
    if (firstName) {[name appendString:firstName];}
    if (lastName) {
        if ([name isEqualToString:@""]) {
            [name appendString:lastName];
        } else{
            [name appendFormat:@" %@", lastName];
        }
    }
    cell.textLabel.text = name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfPeople count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id person = [self.arrayOfPeople objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedPeople addObject:person];
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedPeople removeObject:person];
    }
}

- (void)doneButtonClicked:(id)sender{
    MSDebug(@"done selecting contacts clicked");
    NSMutableSet *phoneNumbers = [[NSMutableSet alloc] init];
    for(id person in _selectedPeople) {
        ABMultiValueRef numbers = (ABMultiValueRef)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
        NSString* phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(numbers, 0);
        NSCharacterSet *onlyAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:onlyAllowedChars] componentsJoinedByString:@""];
        [phoneNumbers addObject:phoneNumber];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(donePickingMutiplePeople: senderIndexPath:)]){
        [_delegate donePickingMutiplePeople:phoneNumbers senderIndexPath:_senderIndexPath];
    }
}
@end
