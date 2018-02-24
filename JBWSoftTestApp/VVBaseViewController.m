//
//  ViewController.m
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 14.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import "VVBaseViewController.h"
#import "ActionSheetPicker.h"
#import "VVStoregeManager.h"
#import "VVLoginViewController.h"

@interface VVBaseViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>{
    NSArray *locale;
    NSDictionary *outputDictionary;
    NSDictionary *outputGlobalDictionary;
    NSArray *allKeysFromOutputDictionary;
    NSArray *allKeysFromOutputGlobalDictionary;
    NSArray *allKeysBeforeSorting;
    NSArray *allKeysBeforeSortingGlobal;
    NSString *choosenLocale;
    NSLocale *jpLocale;
//    BOOL AlertFix;
};



- (IBAction)getTextAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textFieldOutput;
@property (weak, nonatomic) IBOutlet UIButton *localeButtonOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *getTextButtonOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableViewG;

- (IBAction)sortAction:(UISegmentedControl *)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortArraySegmentedOutlet;

- (IBAction)localeButtonAction:(id)sender;

- (IBAction)logOff:(UIButton *)sender;



@end

@implementation VVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self initClassObjects];
  
}

- (IBAction)getTextAction:(id)sender {
    [[VVServerManager sharedManager] getTextWithLocale:choosenLocale
                                             OnSuccess:^(NSDictionary *responce) {
        
        if ([responce objectForKey:@"success"]) {
            static dispatch_once_t onceToken;
            
                self.tableView.hidden = NO;
                self.tableViewG.hidden = NO;
            
            
            NSString *text = [responce objectForKey:@"data"];
//            NSLog(@"text is:%@", text);
            self.textFieldOutput.text =  text;
            outputDictionary = [self countCharackters:text];
            allKeysFromOutputDictionary = [outputDictionary allKeys];
            [self addTextToGlobalRecordForCurrentUser:outputDictionary];
            outputGlobalDictionary = [[VVStoregeManager sharedManager] getHistoryRecord];
            allKeysFromOutputGlobalDictionary = [outputGlobalDictionary allKeys];
            if (self.sortArraySegmentedOutlet.selectedSegmentIndex == 1) {
                allKeysBeforeSorting = allKeysFromOutputDictionary;
               allKeysFromOutputDictionary = [allKeysFromOutputDictionary sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                allKeysBeforeSortingGlobal = allKeysFromOutputGlobalDictionary;
                allKeysFromOutputGlobalDictionary = [allKeysFromOutputGlobalDictionary sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            }
            
            NSLog(@"OUTPUT GLOBAL \n\n\n\n%@\n\n\n" , outputGlobalDictionary);
            //add code for store manager
            [self.tableView reloadData];
            [self.tableViewG reloadData];
        }
        else{
            self.tableView.hidden = YES;
            self.textFieldOutput.text =  @"Some data transfer error\n Not success";
        }
       
    } onFailure:^(NSError *error, NSInteger statusCode) {
        self.textFieldOutput.text = [NSString stringWithFormat:@"Some data transfer error\nError:%@\nStatus Code:%ld", error, statusCode];
    }];
}

- (NSDictionary*) countCharackters:(NSString*) text {
    
    NSString *buferString;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
     for (NSInteger index = 0; index != [text length]; index++) {
         buferString = [text substringWithRange:NSMakeRange(index, 1)];
         [mutableArray addObject:buferString];
     }
    NSArray *sortedArray = [mutableArray sortedArrayUsingSelector:@selector(compare:)];
//    NSLog(@"%@", sortedArray);
    NSLog(@"%ld == %ld", text.length, mutableArray.count);
    
    NSInteger counter = 1;
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSInteger index = 0; index != [sortedArray count] -1; index++) {
        
        if ([sortedArray[index] isEqual:sortedArray[index + 1]]){
            counter++;
        }
        else{
            NSString *key = sortedArray[index];
            [mutableDictionary setObject:[NSString stringWithFormat:@"%ld", counter] forKey:key];
            counter = 1;
        }
    }
    return mutableDictionary;
    
}

- (void) addTextToGlobalRecordForCurrentUser:(NSDictionary*) dictionary{
    [[VVStoregeManager sharedManager] updateHistoryRecordWithDictionary:dictionary];
}



- (IBAction)localeButtonAction:(id)sender {

    [ActionSheetStringPicker showPickerWithTitle:@"Choose local"
                                            rows:locale
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@",
                                                 picker, (long)selectedIndex, selectedValue);
                                           choosenLocale = locale[selectedIndex];
                                           self.localeButtonOutlet.titleLabel.text = locale[selectedIndex];
                                           
                                           //updateCity
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.view];
}

- (IBAction)logOff:(UIButton *)sender {
    
    [[VVServerManager sharedManager] postlogOutOnSuccess:^{
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"Error Logoff");
    }];

    VVLoginViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VVLoginViewController"];
    vc.alertReJoinFix = YES;
    [self presentViewController:vc animated:YES completion:^{
            [[VVServerManager sharedManager] updateAuthorizationHeader:@""];
    }];
     }
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.tableView]) {
//    allKeysFromOutputDictionary = [outputDictionary allKeys];
    
    NSLog(@"cells %ld", [allKeysFromOutputDictionary count]);
    return [allKeysFromOutputDictionary count];
    }
    else if([tableView isEqual:self.tableViewG])
    {

    NSLog(@"cells %ld", [allKeysFromOutputGlobalDictionary count]);
    return [allKeysFromOutputGlobalDictionary count];
    }
    else
    {
    return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSInteger row = indexPath.row;
    UITableViewCell* cell;
    if ([tableView isEqual:self.tableView]) {
        static NSString* identifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    else if([tableView isEqual:self.tableViewG]){
        NSLog(@"G");
         static NSString* identifier1 = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
    }

    NSString *currentKey;
    NSString *valuetimes;
    if ([tableView isEqual:self.tableView]) {
    currentKey = [allKeysFromOutputDictionary objectAtIndex:row];
        
    valuetimes = [NSString stringWithFormat:@" - %@ Times", [outputDictionary objectForKey:currentKey]];
        }
    else if([tableView isEqual:self.tableViewG])
    {
    currentKey = [allKeysFromOutputGlobalDictionary objectAtIndex:row];

    valuetimes = [NSString stringWithFormat:@" - %@ Times", [outputGlobalDictionary objectForKey:currentKey]];
    }
    if ([currentKey isEqualToString:@" "]){
        currentKey = @"SPACE";
    }
    cell.textLabel.text = [currentKey stringByAppendingString:valuetimes];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"Cell %@", cell.textLabel.text);
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20.f;
    
}

#pragma mark - UIPickerView delegate + datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return locale.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    return locale[row];
}
#pragma mark - Initialization
- (void) initClassObjects{
locale = [[NSArray alloc] init];
self.tableView.hidden = YES;
    outputGlobalDictionary = [[VVStoregeManager sharedManager] getHistoryRecord];
    allKeysFromOutputGlobalDictionary = [outputGlobalDictionary allKeys];
    if (allKeysFromOutputGlobalDictionary.count < 1) {
        self.tableViewG.hidden = YES;
    }
self.getTextButtonOutlet.layer.cornerRadius = 10;
self.localeButtonOutlet.titleLabel.textAlignment = NSTextAlignmentCenter;
NSDictionary *testDict = [[VVStoregeManager sharedManager] getHistoryRecord];
NSLog(@"History Record %@", testDict);
NSString *localeString = @"bg_BG,da_DK,el_GR,en_NG,en_ZA,fi_FI,he_IL,ka_GE,me_ME,nl_NL,pt_PT,sr_Cyrl_RS,tr_TR,zh_TW,ar_JO,en_AU,en_NZ,es_AR,hr_HR,kk_KZ,ro_MD,sr_Latn_RS,uk_UA,ar_SA, bn_BD,de_AT,en_CA,en_PH,es_ES,fr_BE,is_IS,ko_KR,mn_MN,ro_RO,sr_RS,at_AT,de_CH,en_GB,en_SG,es_PE,fr_CA,hu_HU,it_CH,nb_NO,ru_RU,sv_SE,de_DE,en_HK,en_UG,es_VE,fr_CH,hy_AM,it_IT,lt_LT,ne_NP,pl_PL,sk_SK,vi_VN,cs_CZ,el_CY,en_IN,en_US,fa_IR,fr_FR,id_ID,ja_JP,lv_LV,nl_BE,pt_BR,sl_SI,th_TH,zh_CN";
locale = [localeString componentsSeparatedByString:@","];
choosenLocale = locale[arc4random() % locale.count-1];

    
}


- (IBAction)sortAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        allKeysBeforeSorting = allKeysFromOutputDictionary;
        allKeysBeforeSortingGlobal = allKeysFromOutputGlobalDictionary;
        allKeysFromOutputGlobalDictionary = [allKeysFromOutputGlobalDictionary sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        allKeysFromOutputDictionary = [allKeysFromOutputDictionary sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
    }
    else if(sender.selectedSegmentIndex == 0){
        allKeysFromOutputDictionary = allKeysBeforeSorting;
        allKeysFromOutputGlobalDictionary = allKeysBeforeSortingGlobal;
    }
    [self.tableViewG reloadData];
    [self.tableView reloadData];
}
@end
