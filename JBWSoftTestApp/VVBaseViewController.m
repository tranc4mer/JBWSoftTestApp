//
//  ViewController.m
//  JBWSoftTestApp
//
//  Created by Viacheslav Varusha on 14.02.2018.
//  Copyright © 2018 Viacheslav Varusha. All rights reserved.
//

#import "VVBaseViewController.h"
#import "AbstractActionSheetPicker.h"

@interface VVBaseViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>{
    NSArray *locale;
    NSDictionary *outputDictionary;
    NSArray *allKeysFromOutputDictionary;
    NSString *choosenLocale;
    NSLocale *jpLocale;
};


- (IBAction)getTextAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textFieldOutput;
@property (weak, nonatomic) IBOutlet UIButton *localeButtonOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)localeButtonAction:(id)sender;
- (IBAction)statisticSegmentedControl:(id)sender;



@end

@implementation VVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    locale = [[NSArray alloc] init];
//    choosenLocale = @"he_IL";
//    NSLocaleLanguageCode
//    jpLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    NSString *localeString = @"bg_BG,da_DK,el_GR,en_NG,en_ZA,fi_FI,he_IL,ka_GE,me_ME,nl_NL,pt_PT,sr_Cyrl_RS,tr_TR,zh_TW,ar_JO,en_AU,en_NZ,es_AR,hr_HR,kk_KZ,ro_MD,sr_Latn_RS,uk_UA,ar_SA, bn_BD,de_AT,en_CA,en_PH,es_ES,fr_BE,is_IS,ko_KR,mn_MN,ro_RO,sr_RS,at_AT,de_CH,en_GB,en_SG,es_PE,fr_CA,hu_HU,it_CH,nb_NO,ru_RU,sv_SE,de_DE,en_HK,en_UG,es_VE,fr_CH,hy_AM,it_IT,lt_LT,ne_NP,pl_PL,sk_SK,vi_VN,cs_CZ,el_CY,en_IN,en_US,fa_IR,fr_FR,id_ID,ja_JP,lv_LV,nl_BE,pt_BR,sl_SI,th_TH,zh_CN";
    locale = [localeString componentsSeparatedByString:@","];
    self.tableView.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)getTextAction:(id)sender {
    [[VVServerManager sharedManager] getTextWithLocale:choosenLocale
                                             OnSuccess:^(NSDictionary *responce) {
        
        if ([responce objectForKey:@"success"]) {
            self.tableView.hidden = NO;
            NSString *text = [responce objectForKey:@"data"];
//            NSLog(@"text is:%@", text);
            self.textFieldOutput.text =  text;
            outputDictionary = [self countCharackters:text];
            [self.tableView reloadData];
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
    
//    NSLog(@"dictionary: %@", mutableDictionary);
    

    return mutableDictionary;
    
}

- (IBAction)localeButtonAction:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Choose local"
                                            rows:rows
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@",
                                                 picker, (long)selectedIndex, selectedValue);
                                           choosenLocale = locale[selectedIndex];
                                           
                                           //updateCity
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.view];
}

- (IBAction)statisticSegmentedControl:(id)sender {
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    allKeysFromOutputDictionary = [outputDictionary allKeys];
    NSLog(@"cells %ld", [allKeysFromOutputDictionary count]);
    return [allKeysFromOutputDictionary count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"Cell";
    NSInteger row = indexPath.row;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *currentKey = [allKeysFromOutputDictionary objectAtIndex:row];
    NSString *valuetimes = [NSString stringWithFormat:@" - %@ Times", [outputDictionary objectForKey:currentKey]];
    cell.textLabel.text = [currentKey stringByAppendingString:valuetimes];
    
    return cell;
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


@end
