//
//  SingleChoiceViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "SingleChoiceViewController.h"
#import "QuestionModel.h"
#import "SingleChoiceViewCell.h"
#import "BSKeyboardControls.h"
#import "AnswerOptionsModel.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "MultiChoiceViewController.h"
#import "ImagePreviewViewController.h"
#import "GlobalImageVideoViewController.h"
#import "AttachmentsModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SingleChoiceViewController ()<UITextViewDelegate,BSKeyboardControlsDelegate,UICollectionViewDelegate>{
    
    GlobalImageVideoViewController *globalImageView;
    QuestionModel *questionData;
    NSMutableArray *singleChoiceListData;
    int selectedIndex;
    float attachmentViewHeight;
}
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (strong, nonatomic) IBOutlet UITableView *singleChoiceTableView;
@property (weak, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet UIView *attachmentView;
@property (strong, nonatomic) IBOutlet UIScrollView *singleChoiceScrollView;
@property (strong, nonatomic) IBOutlet UIView *singleChoiceView;
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;

@end

@implementation SingleChoiceViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.questionTextView.translatesAutoresizingMaskIntoConstraints=YES;
    self.questionTextView.frame=CGRectMake(10, 28, [[UIScreen mainScreen] bounds].size.width-40, 35);
    //initially set values
    attachmentViewHeight=0.0f;
    selectedIndex=-1;
    //display question from database
    questionData=[questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    self.questionTextView.text=questionData.questionTitle;
    //set text alignment to vertical centre
    [self setTextViewAlignment:self.questionTextView];
    singleChoiceListData=[NSMutableArray new];
    //fetch singleChoice data from dataBase array and set in local initialize singleChoiceListData
    for (int i=0; i<questionData.answerOptions.count; i++)
    {
        NSDictionary * answerOptionsDict=[questionData.answerOptions objectAtIndex:i];
        AnswerOptionsModel * answerOptionsData=[[AnswerOptionsModel alloc]init];
        answerOptionsData.answerId=answerOptionsDict[@"AnswerID"];
        answerOptionsData.answerText=answerOptionsDict[@"AnswerText"];
        answerOptionsData.answerImage=answerOptionsDict[@"Image"];
        answerOptionsData.answerThumbnailImage=answerOptionsDict[@"ImageThumbnail "];
        answerOptionsData.isOther=answerOptionsDict[@"IsOther"];
        answerOptionsData.isSelected=NO;    //Intially set unselected cells
        [singleChoiceListData addObject:answerOptionsData];
    }
    //add global image/video view
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    globalImageView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageVideoViewController"];
    //add border and corner radius on objects
    [self viewCustomization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
//add border and corner radius on objects
- (void)viewCustomization {
    [self.mainContainerView addShadowWithCornerRadius:self.mainContainerView color:[UIColor lightGrayColor] borderColor:[UIColor whiteColor] radius:5.0f];
    [self removeAutolayouts];   //remove autolayout of resizing objects
    [self viewObjectsResize];   //change framing according to cases and list count
}

- (void)removeAutolayouts {
    self.singleChoiceView.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachmentView.translatesAutoresizingMaskIntoConstraints=YES;
    self.singleChoiceTableView.translatesAutoresizingMaskIntoConstraints=YES;
}

- (void)viewObjectsResize {
    self.singleChoiceView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, [[UIScreen mainScreen] bounds].size.height-163);
    self.attachmentView.frame= CGRectMake(0, 0, self.singleChoiceView.frame.size.width, 140);
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
            globalImageView.view.frame = CGRectMake(10, 0, self.singleChoiceView.frame.size.width-20, attachmentViewHeight);
        }
        else {
            //if current device is iPad then set frame
             attachmentViewHeight=220.0f;
            self.attachmentView.frame= CGRectMake(0, 0, self.singleChoiceView.frame.size.width, 250);
            globalImageView.view.frame = CGRectMake(10, 0, self.singleChoiceView.frame.size.width-20, attachmentViewHeight);
        }
        [self.attachmentView addSubview:globalImageView.view];
        globalImageView.imageVideoCollectionView.delegate=self; //add collection view delegate
    }
    //set single choice table view size according to choice is selected or not
    if ((-1!=selectedIndex)&&(1==[[[singleChoiceListData objectAtIndex:selectedIndex] isOther] intValue])) {
        //if single choice is selected
       self.singleChoiceTableView.frame= CGRectMake(0, self.attachmentView.frame.size.height, self.singleChoiceView.frame.size.width, ((singleChoiceListData.count-1)*60.0f)+143.0f);
    }
    else {
        //if no single choice is selected
        self.singleChoiceTableView.frame= CGRectMake(0, self.attachmentView.frame.size.height, self.singleChoiceView.frame.size.width, (singleChoiceListData.count*60.0f)+5.0f);
    }
    self.singleChoiceView.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-20, self.singleChoiceTableView.frame.origin.y+self.singleChoiceTableView.frame.size.height);
    self.singleChoiceScrollView.contentSize = CGSizeMake(0,self.singleChoiceView.frame.size.height);
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
    //when user click on next save answer in database
    [self.view endEditing:YES];
    [self.singleChoiceScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.singleChoiceScrollView.scrollEnabled = true;
    
    if (selectedIndex<0) {
        SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:self title:@"Alert" subTitle:@"You need to first answer this question to proceed." closeButtonTitle:@"Done" duration:0.0f];
    }
    else {
        NSIndexPath *index=[NSIndexPath indexPathForRow:selectedIndex inSection:0];
        SingleChoiceViewCell *cell=(SingleChoiceViewCell *)[self.singleChoiceTableView cellForRowAtIndexPath:index];
        if (([[[singleChoiceListData objectAtIndex:selectedIndex] isOther] intValue]==1)&&[cell.pleaseSpecifyAnswerTextView.text isEqualToString:@""]) {
            
            SCLAlertView *alert=[[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:self title:@"Alert" subTitle:@"You need to first answer this question to proceed." closeButtonTitle:@"Done" duration:0.0f];
        }
        else {
            AnswerModel *answerData=[AnswerModel new];
            answerData.stepId=questionData.questionId;
            if ([[[singleChoiceListData objectAtIndex:selectedIndex] isOther] intValue]==1) {
                answerData.singleAnswer=[NSString stringWithFormat:@"%@,%@",[[singleChoiceListData objectAtIndex:selectedIndex] answerId],cell.pleaseSpecifyAnswerTextView.text];
            }
            else {
                answerData.singleAnswer=[[singleChoiceListData objectAtIndex:selectedIndex] answerId];
            }
            //save answer in database
            [AnswerDatabase insertDataInAnswerTable:answerData];
            [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
            //navigate to screen according to the question
            [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
        }
    }
}

#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[singleChoiceListData objectAtIndex:indexPath.row] isSelected]&&([[[singleChoiceListData objectAtIndex:indexPath.row] isOther] intValue]==1)) {
        return 138.0f;//return 60(text view height) + 79.0f(60(above view height)+9(top space of textView)+10(bottom space of textView));
    }
    else {
        return 60.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return singleChoiceListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SingleChoiceViewCell *cell;
    NSString *simpleTableIdentifier=@"SingleChoiceCell";
    cell=[self.singleChoiceTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [cell displayCellData:[singleChoiceListData objectAtIndex:indexPath.row]];
    cell.thumbnailImageView.userInteractionEnabled=YES;
    cell.thumbnailImageView.tag=(int)indexPath.row;
    //Add gesture to show image in full size
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    [cell.thumbnailImageView addGestureRecognizer:singleTap];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Set other cells are unselected
    for (int i=0; i<singleChoiceListData.count; i++) {
        if (i!=(int)indexPath.row) {
            AnswerOptionsModel *answerOptionsData=[singleChoiceListData objectAtIndex:i];
            answerOptionsData.isSelected=NO;
            [singleChoiceListData replaceObjectAtIndex:i withObject:answerOptionsData];
        }
    }
    //select and deselect cell
    if (![[singleChoiceListData objectAtIndex:indexPath.row] isSelected]) {
        AnswerOptionsModel *answerOptionsData=[singleChoiceListData objectAtIndex:indexPath.row];
        self.singleChoiceScrollView.scrollEnabled=YES;
        [self.singleChoiceTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        SingleChoiceViewCell *cell = [self.singleChoiceTableView cellForRowAtIndexPath:indexPath];
        [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[cell.pleaseSpecifyAnswerTextView]]];
        [self.keyboardControls setDelegate:self];
        selectedIndex=(int)indexPath.row;
        answerOptionsData.isSelected=YES;
        cell.pleaseSpecifyAnswerTextView.text=@"";
        [singleChoiceListData replaceObjectAtIndex:indexPath.row withObject:answerOptionsData];
        [self.singleChoiceTableView reloadData];
        [self viewObjectsResize];
    }
}
#pragma mark - end

#pragma mark - UIGestureRecognizer action
//tap image and preview in preview view
-(void)singleTapping:(UIGestureRecognizer *)recognizer {
    if ((nil!=[[singleChoiceListData objectAtIndex:(int)recognizer.view.tag] answerThumbnailImage])&&![[[singleChoiceListData objectAtIndex:(int)recognizer.view.tag] answerThumbnailImage] isEqualToString:@""]) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.imageURL=[[singleChoiceListData objectAtIndex:(int)recognizer.view.tag] answerImage];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
}
#pragma mark - end

#pragma mark - TextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.keyboardControls setActiveField:textView];
    if([[UIScreen mainScreen] bounds].size.height<=568)
    {
        [self.singleChoiceScrollView setContentOffset:CGPointMake(0, (selectedIndex*60.0f)+70+attachmentViewHeight) animated:YES];
    }
    else
    {
        [self.singleChoiceScrollView setContentOffset:CGPointMake(0, (selectedIndex*60.0f)+attachmentViewHeight) animated:YES];
    }
    self.singleChoiceScrollView.scrollEnabled=NO;
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls1 selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)bskeyboardControls {
    self.singleChoiceScrollView.scrollEnabled=YES;
    [self.singleChoiceScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [bskeyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Collection view delegate and datasource methods
//Preview image view using collection view delegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AttachmentsModel * attachments=[globalImageView.attachmentsArray objectAtIndex:indexPath.row];
    if ([attachments.attachmentType isEqualToString:@"image"]) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImagePreviewViewController *imagePreviewView =[storyboard instantiateViewControllerWithIdentifier:@"ImagePreviewViewController"];
        imagePreviewView.selectedIndex=(int)indexPath.row;
        imagePreviewView.attachmentArray=[globalImageView.attachmentsArray mutableCopy];
        [self.navigationController pushViewController:imagePreviewView animated:YES];
    }
    else {
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
