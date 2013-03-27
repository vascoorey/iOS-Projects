//
//  FriendDetailCVC.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "FriendPageLikesCVC.h"
#import "SVProgressHUD.h"
#import "PageCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FriendPageLikesCVC ()
@property (nonatomic, strong) NSArray *data;
@end

@implementation FriendPageLikesCVC

-(void)setData:(NSArray *)data
{
    _data = data;
    [self.collectionView reloadData];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self.title stringByAppendingString:@"'s Liked Pages"];
    NSString *query = [NSString stringWithFormat:
                       @"{"
                       @"'friendLikes':'SELECT uid, page_id FROM page_fan WHERE uid = %@',"
                       @"'pages':'SELECT page_id, name, pic FROM page WHERE page_id IN (SELECT page_id FROM #friendLikes)',"
                       @"}", self.friendUID];
    
    [self executeFacebookQuery:query usingIndex:1];
}

#warning Reused code.
-(void)executeFacebookQuery:(NSString *)query usingIndex:(NSUInteger)index
{
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q" : query };
    CFTimeInterval old = CACurrentMediaTime();
    [SVProgressHUD showWithStatus:@"Fetching Data..." maskType:SVProgressHUDMaskTypeGradient];
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              NSLog(@"Time taken for query: %g", CACurrentMediaTime() - old);
                              [SVProgressHUD popActivity];
                              if (error) {
                                  NSLog(@"Error: %@", error);
                              } else {
                                  self.data = result[@"data"][index][@"fql_result_set"];
                              }
                          }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.data count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Page" forIndexPath:indexPath];
    PageCollectionViewCell *pcvCell = (PageCollectionViewCell *)cell;
    pcvCell.imageView.image = nil;
    pcvCell.pageID = self.data[indexPath.row][@"page_id"];
    
    // Fetch the image asynchronously
    dispatch_queue_t pictureQ = dispatch_queue_create("Page Picture Fetcher", NULL);
    dispatch_async(pictureQ, ^{
        NSData *pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.data[indexPath.row][@"pic"]]];
        // Go back to the main queue to do UIKit calls
        dispatch_async(dispatch_get_main_queue(), ^{
            if([pcvCell.pageID isEqualToNumber:self.data[indexPath.row][@"page_id"]])
            {
                UIImage *pageImage = [UIImage imageWithData:pictureData];
                pcvCell.imageView.image = pageImage;
                pcvCell.alpha = 0.0f;
                // 0.2f is just an example...
                [UIView animateWithDuration:0.2f animations:^{
                    // In this case just change the alpha
                    pcvCell.alpha = 1.0f;
                }];
            }
            else
            {
                // The cell has been scrolled off-screen
                NSLog(@"Throwing away %@", self.data[indexPath.row][@"page_id"]);
            }
        });
    });
    
    return cell;
}

@end
