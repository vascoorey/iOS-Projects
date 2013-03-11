//
//  ImageViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
#import "Utils.h"
#import "NetworkActivity.h"
#import "CacheControl.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *imageTitleBarButtonItem;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ImageViewController

-(void)setTitle:(NSString *)title
{
    super.title = title;
    self.imageTitleBarButtonItem.title = title;
}

// resets the image whenever the URL changes

- (void)setImageURL:(NSURL *)imageURL
{
    NSLog(@"%@", imageURL);
    _imageURL = imageURL;
    [self resetImage];
}

// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.spinner startAnimating];
        NSURL *imageURL = self.imageURL;
        NSString *identifier = [NSString stringWithFormat:@"%@", [imageURL lastPathComponent]];
        dispatch_queue_t imageFetchQ = dispatch_queue_create("Image Fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            UIImage *image;
            if([CacheControl containsIdentifier:identifier])
            {
                image = [[UIImage alloc] initWithData:[CacheControl getDataFromCache:identifier]];
            }
            else
            {
                NSLog(@"Not cached... Fetching!");
                [NetworkActivity addRequest];
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
                [NetworkActivity removeRequest];
                [CacheControl pushDataToCache:imageData identifier:identifier];
                image = [[UIImage alloc] initWithData:imageData];
            }
            if(imageURL == self.imageURL)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Can only do UIKit calls in the main thread.
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        // Need to fit the image here because viewDidLayoutSubviews has probably already been called while we were loading the image from the network.
                        [self fitImageToScrollview];
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self fitImageToScrollview];
}

-(void)fitImageToScrollview
{
    CGFloat xScale = self.scrollView.bounds.size.width / self.imageView.bounds.size.width;
    CGFloat yScale = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
    CGFloat scale = MAX(xScale, yScale);
    [self.scrollView setZoomScale:scale animated:NO];
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

// add the image view to the scroll view's content area
// setup zooming by setting min and max zoom scale
//   and setting self to be the scroll view's delegate
// resets the image in case URL was set before outlets (e.g. scroll view) were set

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = MIN_ZOOM_SCALE;
    self.scrollView.maximumZoomScale = MAX_ZOOM_SCALE;
    self.scrollView.delegate = self;
    [self resetImage];
    self.imageTitleBarButtonItem.title = self.title;
}

@end
