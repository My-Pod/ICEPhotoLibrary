//
//  ViewController.m
//  Example
//
//  Created by WLY on 16/7/12.
//  Copyright © 2016年 WLY. All rights reserved.
//

#import "ViewController.h"
#import "ICEPhotoLibrary.h"


@interface ViewController ()
@property (nonatomic, copy) NSString *text;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)openCarmer:(id)sender {
    
    
    [ICEPhotoLibrary saveImage:[UIImage imageNamed:@"屏幕快照 2016-08-06 14.50.04"] toAlbum:nil success:^(NSString *imageURL) {
        NSLog(@"%@",imageURL);
        self.text = imageURL;
    } failure:^(NSString *errMsg) {
        
    }];
}

- (IBAction)GetImage:(id)sender{
    [ICEPhotoLibrary getImage:self.text success:^(UIImage *image) {
        NSLog(@"%@",image);
    } faliure:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
