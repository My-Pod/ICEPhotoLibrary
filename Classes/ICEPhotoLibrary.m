
//
//  ICEPhotoLibrary.m
//  ICEGitSet
//
//  Created by WLY on 16/5/6.
//  Copyright © 2016年 ICE. All rights reserved.
//

#import "ICEPhotoLibrary.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 *  1. 从相册获取图片
    2. 通过相册名字获取相册
    3. 获取相册认证权限
    4. 保存相册
 */


@interface ICEPhotoLibrary ()



@end
@import Photos ;


#define  IS_Greate_Than_iOS8 (  [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)



@implementation ICEPhotoLibrary


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"



+ (void)getImage:(NSString *)imageURL success:(void (^)(UIImage *))success faliure:(void (^)())falied{
    [self getImage:imageURL options:nil withImageSize:CGSizeMake(500, 500) success:success faliure:falied];
}

/**
 *  通过相册中图片的url 获取相册中指定的图片 success 可能会多次回调
 *
 *  @param imageURL  图片在相册中的url
 *  @param options   获取图片的策略 主要参数为一下参数(ios 8 及以后有效)
 * synchronous：指定请求是否同步执行。
 * resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
 * deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
 这个属性只有在 synchronous 为 true 时有效。
 * normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。}
 *  @param success   获取成功的回调 (success 可能会多次回调)
 *  @param falied    获取失败的回调
 */
+ (void)getImage:(NSString *)imageURL
         options:(PHImageRequestOptions *)options
   withImageSize:(CGSize)imageSize
         success:(void (^) (UIImage *image))success
         faliure:(void (^) ())falied{
    
    if (!imageURL) {
        falied();
        return;
    }

    if (IS_Greate_Than_iOS8) {
        PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[[NSURL URLWithString:imageURL]] options:nil].lastObject;
        
        if (!options) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        }
        
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //只要最终结果的返回
            if (result && info[@"PHImageFileURLKey"]) {
                NSLog(@"==================>%p :%@   &&\n%@",self,result,info);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success(result);
                    }
                });
            }

        }];
    }else{
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        
        NSURL *url = [NSURL URLWithString:imageURL];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            // 使用asset来获取本地图片
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            CGImageRef imgRef = [assetRep fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:imgRef scale:assetRep.scale orientation:(UIImageOrientation)assetRep.orientation];
            //回调
            if (success && image) {
                success(image);
            }else{
                falied();
                
            }
            
            
        } failureBlock:^(NSError *error) {
            
            falied();
            
        }];
    }
}



/**
 *  保存图片到指定的相册
 *
 *  @param image     要保存的图片
 *  @param albumName 相册名
 *  @param success   成功的回调
 *  @param falied    失败的回调
 */
+ (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
          success:(void (^) (NSString *imageURL))success
          failure:(void (^) (NSString *errMsg))falied{
   
    if (!image) {
        falied(@"图片不能为空");
        return;
    }
    //判断权限
    [self requestAuthorized:^{
        if (IS_Greate_Than_iOS8) {
            __block PHAssetChangeRequest *changeRequest = nil;
            __block PHAssetCollectionChangeRequest *collectionChangeRequest = nil;
            __block PHObjectPlaceholder *assetPlaceholder = nil;
            //获取指定名称的相册 没有的话就创建
            [self getPhotoAlbum:albumName success:^(id PhotoAlubm) {
                //向指定相册保存图片
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    
                    changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    assetPlaceholder = changeRequest.placeholderForCreatedAsset;
                    if ([PhotoAlubm isKindOfClass:[PHCollection class]]) {
                        collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:PhotoAlubm];
                        [collectionChangeRequest addAssets:@[assetPlaceholder]];
                        

                    }
                } completionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //保存成功返回地址
                        if (isSuccess) {
                            NSString *UUID = [assetPlaceholder.localIdentifier substringToIndex:36];
                            NSString *imgURL  = [NSString stringWithFormat:@"assets-library://asset/asset.PNG?id=%@&ext=JPG", UUID];
                            success(imgURL);
                        }else{
                            falied(@"保存失败");
                        }
                    });
                }];
                
            } fail:^(NSString *errMsg) {
                falied(errMsg);
            }];
            
        }else {
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc]init];
            
            if (!albumName) {
                //保存到系统默认相册

                [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                    if (!error) {
                        if (success) {
                            success(assetURL.absoluteString);
                        }
                    }else{
                        if (falied) {
                            falied(@"保存失败");
                        }
                    }
                }];
            }
        }
    } fail:^(ICEPhotoAuthorizationStatus status) {
        //未获得授权
        falied(@"授权失败"); 
    }];
}


/**
 *  获取相机访问权限状态(是否可访问)
 *
 *  @param success  可访问
 *  @param fail     不可访问
 */
+ (void)requestAuthorized:(void (^) ())success
                     fail:(void (^) (ICEPhotoAuthorizationStatus status))fail{
   
    if (IS_Greate_Than_iOS8) {
        //权限处理
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
                //还未请求用户是否允许访问相册
            case PHAuthorizationStatusNotDetermined: {
                fail(ICEPhotoAuthorizationStatusNotDetermined);
                break;
            }
                //系统原因获取授权失败
            case PHAuthorizationStatusRestricted: {
                fail(ICEPhotoAuthorizationStatusRestricted);
                break;
            }
                //禁止使用
            case PHAuthorizationStatusDenied: {
                fail(ICEPhotoAuthorizationStatusDenied);
                break;
            }
                //允许使用
            case PHAuthorizationStatusAuthorized: {
                success();
                break;
            }
        }
 
    }else{

        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusNotDetermined: {
                fail(ICEPhotoAuthorizationStatusNotDetermined);
                break;
            }
            case ALAuthorizationStatusRestricted: {
                fail(ICEPhotoAuthorizationStatusRestricted);
                break;
            }
            case ALAuthorizationStatusDenied: {
                fail(ICEPhotoAuthorizationStatusDenied);
                break;
            }
            case ALAuthorizationStatusAuthorized: {
                success();
                break;
            }
        }
        
    }
    
}



/**
 *  获取指定名称的相册, 如果不存在则创建,存在则返回
 *
 *  @param albumName 相册名称, 为空则放在默认相册
 *  @param success   获取成功则返回相册  (ios 8 之前 photoAlubm是 ALAssetsGroup iOS 8 之后是 )
 *  @param fail      获取失败无返回
 */
+ (void)getPhotoAlbum:(NSString *)albumName
              success:(void (^) (id PhotoAlubm))success
                 fail:(void (^) (NSString *errMsg))fail{
    
    
    if (!albumName || albumName.length < 1) {
        
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        success(allPhotos);
        return;
    }
    __block BOOL hasExistence = NO;//默认不存在
    

    if (IS_Greate_Than_iOS8) {
        
        PHFetchResult<PHCollection *> *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [topLevelUserCollections enumerateObjectsUsingBlock:^(PHCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.localizedTitle isEqualToString:albumName]) {
                hasExistence = YES;
                *stop = YES;
                if (success) {
                    success(obj);
                }
                return ;
            }
        }];
        
      
    }else{
        
        ALAssetsLibrary *alibrary = [[ALAssetsLibrary alloc] init];
        // enumerate only photos
        NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
        
        [alibrary enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                /**
                 *  
                 // Get all photos assets in the assets group.
                 + (ALAssetsFilter *)allPhotos;
                 // Get all video assets in the assets group.
                 + (ALAssetsFilter *)allVideos;
                 // Get all assets in the group.
                 + (ALAssetsFilter *)allAssets;

                 */
                
                NSString * groupNmae = [group valueForProperty:ALAssetsGroupPropertyName];
                if ([groupNmae isEqualToString:albumName]) {
                    if (success) {
                        success(group);
                    }
                    hasExistence = YES;
                    *stop = YES;
                    return ;
                }
            }
            
        } failureBlock:^(NSError *error) {
            fail(@"检索已存在相册失败.");
        }];
    }
    
    //不存在则创建
    if (!hasExistence) {
        [self creatNewAssetsGroupAlbunWithName:albumName success:^(id PhotoAlubm) {
            success(PhotoAlubm);
        } fail:^(NSString *errMsg) {
            fail(errMsg);
        }];
    }

}






/**
 *  创建相册
 *
 *  @param albumName 新相册名
 *  @param reslut    创建结果
 */
+ (void)creatNewAssetsGroupAlbunWithName:(NSString *)albumName
                                 success:(void (^) (id PhotoAlubm))success
                                    fail:(void (^) (NSString *errMsg))fail{


    if (IS_Greate_Than_iOS8) {
        __block PHAssetCollectionChangeRequest *collectionChangeRequest = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        } completionHandler:^(BOOL createSuccess, NSError * _Nullable error) {
            if (createSuccess) {
                
                PHFetchResult<PHCollection *> *newResutl = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
                [newResutl enumerateObjectsUsingBlock:^(PHCollection * _Nonnull newObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([newObj.localizedTitle isEqualToString:albumName]) {
                        success(newObj);
                        *stop = YES;
                        return ;
                    }
                }];
            }
            if (!createSuccess) {
                fail(@"创建失败");
            }
        }];

    }else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
            if (success) {
                success(group);
            }
        } failureBlock:^(NSError *error) {
            //创建失败
            fail(@"创建相册失败");
        }];
    }

}





@end


#pragma clang diagnostic pop
