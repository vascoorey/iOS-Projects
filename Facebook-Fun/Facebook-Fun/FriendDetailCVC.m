//
//  FriendDetailCVC.m
//  Facebook-Fun
//
//  Created by Vasco Orey on 3/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "FriendDetailCVC.h"
#import "SVProgressHUD.h"
#import "PageCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FriendDetailCVC ()
@property (nonatomic, strong) NSArray *data;
@end

@implementation FriendDetailCVC

-(void)setData:(NSArray *)data
{
    _data = data;
    [self.collectionView reloadData];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *query = [NSString stringWithFormat:
                       @"{"
                       @"'friendLikes':'SELECT uid, page_id FROM page_fan WHERE uid = %@',"
                       @"'pages':'SELECT page_id, name, pic FROM page WHERE page_id IN (SELECT page_id FROM #friendLikes)',"
                       @"}", self.friendUID];
    
    [self executeFacebookQuery:query usingIndex:1];
}

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
    dispatch_queue_t pictureQ = dispatch_queue_create("Page Picture Fetcher", NULL);
    dispatch_async(pictureQ, ^{
        NSData *pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.data[indexPath.row][@"pic"]]];
        UIImage *pageImage = [UIImage imageWithData:pictureData];
        dispatch_async(dispatch_get_main_queue(), ^{
            pcvCell.imageView.image = pageImage;
            [pcvCell setNeedsLayout];
        });
    });
    
    return cell;
}

@end
