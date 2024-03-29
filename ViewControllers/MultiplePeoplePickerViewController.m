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
@property (strong,nonatomic) NSMutableSet *selectedPeopleIndices;
@property (strong, nonatomic) UITableView *tableView;
@end

static NSString *CellIdentifier = @"ContactCell";

@implementation MultiplePeoplePickerViewController
@synthesize arrayOfPeople = _arrayOfPeople;
@synthesize people = _people;
@synthesize selectedPeople = _selectedPeople;
@synthesize selectedPeopleIndices = _selectedPeopleIndices;


- (NSMutableSet *) selectedPeople {
    if (_selectedPeople == nil) {
        _selectedPeople = [[NSMutableSet alloc] init];
    }
    return _selectedPeople;
}

- (NSMutableSet *) selectedPeopleIndices {
    if (_selectedPeopleIndices == nil) {
        _selectedPeopleIndices = [[NSMutableSet alloc] init];
    }
    return _selectedPeopleIndices;
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, 498)
                                                          style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                MSDebug(@"granted!");
                // If the app is authorized to access the first time then add the contact
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    [self addContactToAddressBook:addressBook];
                }];
            } else {
                // Show an alert here if user denies access telling that the contact cannot be added because you didn't allow it to access the contacts
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // If the user user has earlier provided the access, then add the contact
        [self addContactToAddressBook:addressBook];
    }
    else {
        // If the user user has NOT earlier provided the access, create an alert to tell the user to go to Settings app and allow access
    }
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    if(nPeople > 0){
        [self addContactToAddressBook:addressBook];
    }
}

- (void) addContactToAddressBook:(ABAddressBookRef) addressBook{
    ABAddressBookRef addressBookNew = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBookNew);
    self.people = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBookNew, source, kABPersonSortByFirstName);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBookNew);
    if(nPeople > 0){
        ABRecordRef person = CFArrayGetValueAtIndex(self.people, 0);
        NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                             kABPersonFirstNameProperty);
        MSDebug(@"%@",firstName);
    }
    self.arrayOfPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBookNew, source, kABPersonSortByFirstName);
    MSDebug(@"%d",[self.arrayOfPeople count]);
    [_tableView reloadData];

    /*
    [_tableView removeFromSuperview];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, 498)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    MSDebug(@"called cell at %d", indexPath.row);
    int index = indexPath.row;
    ABRecordRef person;
    if(index < [self.arrayOfPeople count]){
        person = CFArrayGetValueAtIndex(self.people, index);
    }
    
    if([self.selectedPeopleIndices containsObject:indexPath]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *firstName;
    NSString *lastName;
//    if((__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty) != NULL){
//        firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
//    }
//    if( (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty) != NULL)
    if(person != NULL){
        lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    }
    

    NSMutableString *name = [NSMutableString stringWithString:@""];
    if (firstName != NULL && firstName != nil) {MSDebug(@"got executed!"); [name appendString:firstName];}
    if (lastName != NULL && lastName != nil) {
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
    MSDebug(@"called its number of rows %d", [self.arrayOfPeople count]);
    return [self.arrayOfPeople count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id person = [self.arrayOfPeople objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedPeopleIndices addObject:indexPath];
        [self.selectedPeople addObject:person];
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedPeopleIndices removeObject:indexPath];
        [self.selectedPeople removeObject:person];
    }
}

- (void)doneButtonClicked:(id)sender{
    MSDebug(@"done selecting contacts clicked");
    NSMutableSet *phoneNumbers = [[NSMutableSet alloc] init];
    for(id person in _selectedPeople) {
        ABMultiValueRef numbers = (ABMultiValueRef)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
        NSString* phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(numbers, 0);
        if (phoneNumber == nil) {
            MSDebug(@"The contact has no phone number");
            continue;
        }
            
        NSCharacterSet *onlyAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:onlyAllowedChars] componentsJoinedByString:@""];
        [phoneNumbers addObject:phoneNumber];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(donePickingMutiplePeople: senderIndexPath:)]){
        [_delegate donePickingMutiplePeople:phoneNumbers senderIndexPath:_senderIndexPath];
    }
}
@end
