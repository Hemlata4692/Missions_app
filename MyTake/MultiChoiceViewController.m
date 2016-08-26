//
//  MultiChoiceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MultiChoiceViewController.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "MultiChoiceCell.h"
#import "BSKeyboardControls.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MultiChoiceViewController ()<UITextViewDelegate,BSKeyboardControlsDelegate,UICollectionViewDelegate>{
    
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    NSMutableArray *multiChoiceListData;
    NSMutableArray *selectedIndex;
    int currentSelectedIndex;
    BOOL isExclusive;
    float attachmentViewHeight;
}
@property (strong, nonatomic) IBOutlet UITableView *multiChoiceTableView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (strong, nonatomic) IBOutlet UIScrollView *multiChoiceScrollView;
@property (strong, nonatomic) IBOutlet UIView *multiChoiceView;
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation MultiChoiceViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 28, [[UIScreen mainScreen] bounds].size.width-40, 35);
    //initially set values
    attachmentViewHeight=0.0f;
    selectedIndex=[NSMutableArray new];
    isExclusive=false;
    currentSelectedIndex=-1;
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    multiChoiceListData=[NSMutableArray new];
    //fetch singleChoice data from dataBase array and set in local initialize multiChoiceListData
    for (int i=0; i<questionData.answerOptions.count; i++)
    {
        NSDictionary * answerOptionsDict=[questionData.answerOptions objectAtIndex:i];
        AnswerOptionsModel * answerOptionsData=[[AnswerOptionsModel alloc]init];
        answerOptionsData.answerId=answerOptionsDict[@"AnswerID"];
        answerOptionsData.answerText=answerOptionsDict[@"AnswerText"];
        answerOptionsData.answerImage=answerOptionsDict[@"Image"];
        answerOptionsData.answerThumbnailImage=answerOptionsDict[@"ImageThumbnail "];
        answerOptionsData.isExclusive=answerOptionsDict[@"IsExclusive "];
        answerOptionsData.isOther=answerOptionsDict[@"IsOther"];
        answerOptionsData.isSelected=NO;    //Intially set unselected cells
        [multiChoiceListData addObject:answerOptionsData];
    }
    
    //Add global image/video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];

    [self viewCustomization];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    [self removeAutolayouts];   //remove autolayout of resizing objects
    [self viewObjectsResize];   //change framing according to cases and list count
}

- (void)removeAutolayouts {
    self.multiChoiceView.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    self.multiChoiceTableView.translatesAutoresizingMaskIntoConstraints=YES;
}

- (void)viewObjectsResize {
    self.multiChoiceView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-163);
    self.attachmentView.frame= CGRectMake(0, 0, self.multiChoiceView.frame.size.width, 140);
    //show and global image view according to attachments is available or not
    if (0==questionData.answerAttachments.count) {
        attachmentViewHeight=0.0f;
        //if no attachments available
        CGRect frame = self.attachmentView.frame;
        frame.size = CGSizeMake(0, 0);
        self.attachmentView.frame = frame;
    }
    else {
        if (([[UIDevice currentDevice] userInterfaceIdiom]!= UIUserInterfaceIdiomPad)) {
            //if current device is iPhone then set frame
            attachmentViewHeight=120.0f;
            globalImageView.view.frame = CGRectMake(10, 0, self.multiChoiceView.frame.size.width-20, attachmentViewHeight);
        }
        else {
            //if current device is iPad then set frame
            attachmentViewHeight=220.0f;
            self.attachmentView.frame= CGRectMake(0, 0, self.multiChoiceView.frame.size.width, 250);
            globalImageView.view.frame = CGRectMake(10, 0, self.multiChoiceView.frame.size.width-20, attachmentViewHeight);
        }
        [self.attachmentView addSubview:globalImageView.view];
        globalImageView.imageVideoCollectionView.delegate=self; //add collection view delegate
    }
    //set single choice table view size according to choice is selected or not
    if ((-1!=currentSelectedIndex)&&(1==[[[multiChoiceListData objectAtIndex:currentSelectedIndex] isOther] intValue])) {
        //If single choice is selected
        self.multiChoiceTableView.frame= CGRectMake(0, self.attachmentView.frame.size.height, self.multiChoiceView.frame.size.width, ((multiChoiceListData.count-1)*60.0f)+143.0f);
    }
    else {
        //if no single choice is selected
        self.multiChoiceTableView.frame= CGRectMake(0, self.attachmentView.frame.size.height, self.multiChoiceView.frame.size.width, (multiChoiceListData.count*60.0f)+5.0f);
    }
    self.multiChoiceView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, self.multiChoiceTableView.frame.origin.y+self.multiChoiceTableView.frame.size.height);
    self.multiChoiceScrollView.contentSize = CGSizeMake(0,self.multiChoiceView.frame.size.height);
}

#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[multiChoiceListData objectAtIndex:indexPath.row] isSelected]&&([[[multiChoiceListData objectAtIndex:indexPath.row] isOther] intValue]==1)&&(currentSelectedIndex==(int)indexPath.row)) {
        return 138.0f;//return 60(text view height) + 79.0f(60(above view height)+9(top space of textView)+10(bottom space of textView));
    }
    else {
        return 60.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return multiChoiceListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultiChoiceCell *cell;
    NSString *simpleTableIdentifier=@"MultiChoiceCell";
    cell=[self.multiChoiceTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [cell displayCellData:[multiChoiceListData objectAtIndex:indexPath.row] isCurrentSelectedIndex:((currentSelectedIndex==(int)indexPath.row) ? true : false) isExclusive:isExclusive];
    cell.thumbnailImageView.userInteractionEnabled=YES;
    cell.thumbnailImageView.tag=(int)indexPath.row;
    //Add gesture to show image in full size
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    [cell.thumbnailImageView addGestureRecognizer:singleTap];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //select and deselect table view cell
    [self.view endEditing:YES];
    self.multiChoiceScrollView.scrollEnabled = true;
    AnswerOptionsModel *answerOptionsDataObject=[multiChoiceListData objectAtIndex:indexPath.row];
    if (![[multiChoiceListData objectAtIndex:indexPath.row] isSelected]) {
        MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:indexPath];
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[cell.pleaseSpecifyAnswerTextView]]];
        [self.keyboardControls setDelegate:self];
        currentSelectedIndex=(int)indexPath.row;
        if ([[[multiChoiceListData objectAtIndex:indexPath.row] isExclusive] intValue]==1) {
            [selectedIndex removeAllObjects];
            isExclusive=true;
            for (int i=0; i<multiChoiceListData.count; i++) {
                if (i!=(int)indexPath.row) {
                    MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:indexPath];
                    cell.pleaseSpecifyAnswerTextView.text=@"";
                    AnswerOptionsModel *answerOptionsData=[multiChoiceListData objectAtIndex:i];
                    answerOptionsData.isSelected=NO;
                    [multiChoiceListData replaceObjectAtIndex:i withObject:answerOptionsData];
                }
            }
        }
        else {
            isExclusive=false;
        }
        answerOptionsDataObject.isSelected=YES;
        [selectedIndex addObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }
    else {
        isExclusive=false;
        currentSelectedIndex=-1;
        MultiChoiceCell *cell = [self.multiChoiceTableView cellForRowAtIndexPath:indexPath];
        answerOptionsDataObject.isSelected=NO;
        cell.pleaseSpecifyAnswerTextView.text=@"";
        [selectedIndex removeObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }
    [multiChoiceListData replaceObjectAtIndex:indexPath.row withObject:answerOptionsDataObject];
    [self.multiChoiceTableView reloadData];
    [self viewObjectsResize];
}
#pragma mark - end

#pragma mark - UIGestureRecognizer action
//tap image and preview in preview view
-(void)singleTapping:(UIGestureRecognizer *)recognizer {
    if ((nil!=[[multiChoiceListData objectAtIndex:(int)recognizer.view.tag] answerThumbnailImage])&&![[[multiChoiceListData objectAtIndex:(int)recognizer.view.tag] answerThumbnailImage] isEqualToString:@""]) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.imageURL=[[multiChoiceListData objectAtIndex:(int)recognizer.view.tag] answerImage];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
}
#pragma mark - end

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.keyboardControls setActiveField:textView];
    if([[UIScreen mainScreen] bounds].size.height<=568) {
        [self.multiChoiceScrollView setContentOffset:CGPointMake(0, (currentSelectedIndex*60.0f)+70+attachmentViewHeight) animated:YES];
    }
    else {
        [self.multiChoiceScrollView setContentOffset:CGPointMake(0, (currentSelectedIndex*60.0f)+attachmentViewHeight) animated:YES];
    }
    self.multiChoiceScrollView.scrollEnabled=NO;
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls1 selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls {
    self.multiChoiceScrollView.scrollEnabled=YES;
    [self.multiChoiceScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [bskeyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    //When user click on next save answer in database
    [self.view endEditing:YES];
    [self.multiChoiceScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.multiChoiceScrollView.scrollEnabled = true;
    if ([self performValidation]) {
        NSMutableDictionary* setJsonAnswerDictObject=[NSMutableDictionary new];
        for (int i=0; i<selectedIndex.count; i++) {
            NSIndexPath *index=[NSIndexPath indexPathForRow:[[selectedIndex objectAtIndex:i] intValue] inSection:0];
            MultiChoiceCell *cell=(MultiChoiceCell *)[self.multiChoiceTableView cellForRowAtIndexPath:index];
            if ([[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] integerValue]] isOther] intValue]==1) {
                [setJsonAnswerDictObject setObject:cell.pleaseSpecifyAnswerTextView.text forKey:[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] integerValue]] answerId]];
            }
            else {
                [setJsonAnswerDictObject setObject:@"" forKey:[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] integerValue]] answerId]];
            }
        }
        //When user click on next save answer in database
        AnswerModel *answerData=[AnswerModel new];
        answerData.stepId=questionData.questionId;
        answerData.multiAnswerDict=[setJsonAnswerDictObject mutableCopy];;
        [AnswerDatabase insertDataInAnswerTable:answerData];

        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    }
    else {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"You need to first answer this question to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
}
#pragma mark - end

#pragma mark - Perform validations
- (BOOL)performValidation {
    if (([selectedIndex count] == 0)) {
        return NO;
    }
    else {
        NSIndexPath *index;
        MultiChoiceCell *cell;
        int flag=0;
        for (int i=0; i<selectedIndex.count; i++) {
            index=[NSIndexPath indexPathForRow:[[selectedIndex objectAtIndex:i] intValue] inSection:0];
            cell=(MultiChoiceCell *)[self.multiChoiceTableView cellForRowAtIndexPath:index];
            if (([[[multiChoiceListData objectAtIndex:[[selectedIndex objectAtIndex:i] intValue]] isOther] intValue]==1)&&[cell.pleaseSpecifyAnswerTextView.text isEqualToString:@""]) {
                flag=1;
                break;
            }
        }
        if (flag) {
            return NO;
        }
        else{
            return YES;
        }
    }
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
//Preview image view using collection view delegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
    if ([attachments.attachmentType isEqualToString:@"image"]) {
        //show image on preview view
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.selectedIndex=(int)indexPath.row;
        imagePreviewView.attachmentArray=[globalImageView.attachmentsArray mutableCopy];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
    else {
        //play video in movie player
        AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
        // NSString* strurl =@"https://s3.amazonaws.com/adplayer/colgate.mp4";
        NSString* strUrl =attachments.attachmentURL;
        NSURL *fileURL = [NSURL URLWithString: strUrl];
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
        [self presentViewController:moviePlayer animated:YES completion:NULL];
    }
}
#pragma mark - end
@end
