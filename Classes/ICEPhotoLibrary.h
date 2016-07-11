//
//  ICEPhotoLibrary.h
//  ICEGitSet
//
//  Created by WLY on 16/5/6.
//  Copyright © 2016年 ICE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * 相册访问权限状态
 */
typedef NS_ENUM(NSInteger, ICEPhotoAuthorizationStatus) {
    /**
     *   还未请求用户许可
     */
    ICEPhotoAuthorizationStatusNotDetermined,
    /**
     *  系统原因获取未授权
     */
   ICEPhotoAuthorizationStatusRestricted,
    /**
     *  禁止请求
     */
     ICEPhotoAuthorizationStatusDenied,
    /**
     *  允许
     */
     ICEPhotoAuthorizationStatusAutiorized,
};






/**
 *  创建相册成功的回调
 */
typedef void (^CreatNewGroupBlock) ();

@interface ICEPhotoLibrary : NSObject 
/**
 *  通过相册中图片的url 获取相册中指定的图片
 *
 *  @param imageURL  图片在相册中的url
 *  @param options   获取图片的策略 主要参数为一下参数(ios 8 及以后有效,默认原图大小)
 * synchronous：指定请求是否同步执行。
 * resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
 * deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
 这个属性只有在 synchronous 为 true 时有效。
 * normalizedCropRect：用于对原始尺寸的图像进行裁剪，基于比例坐标。只在 resizeMode 为 Exact 时有效。}
 *  @param success   获取成功的回调
 *  @param falied    获取失败的回调
 */
+ (void)getImage:(nonnull NSString *)imageURL
         options:(nullable PHImageRequestOptions *)options
   withImageSize:(CGSize)imageSize
         success:(void (^) (UIImage *image))success
         faliure:(void (^) ())falied;

/**
 *  获取缩略图
 *
 *  @param imageURL 图片地址
 *  @param success  获取成功的回调
 *  @param falied   获取失败的回调
 */
+ (void)getImage:(nonnull NSString *)imageURL
         success:(void (^) (UIImage *image))success
         faliure:(void (^) ())falied;

/**
 *  保存图片到指定的相册
 *
 *  @param image     要保存的图片
 *  @param albumName 相册名
 *  @param success   成功的回调
 *  @param falied    失败的回调
 */
+ (void)saveImage:(nonnull UIImage *)image
          toAlbum:(NSString *)albumName
          success:(void (^) (NSString *imageURL))success
          failure:(void (^) (NSString *errMsg))falied;


/**
 *  创建相册
 *
 *  @param albumName 新相册名
 *  @param reslut    创建结果
 */
+ (void)creatNewAssetsGroupAlbunWithName:(nonnull NSString *)albumName
                                 success:(void (^) (id PhotoAlubm))success
                                    fail:(void (^) (NSString *errMsg))fail;

/**
 *  获取相机访问权限状态(是否可访问)
 *
 *  @param success 可访问
 *  @param fail     不可访问
 */
+ (void)requestAuthorized:(void (^) ())success
                     fail:(void (^) (ICEPhotoAuthorizationStatus status))fail;

/**
 *  获取指定名称的相册, 如果不存在则创建,存在则返回
 *
 *  @param albumName 相册名称
 *  @param success   获取成功则返回相册  (ios 8 之前 photoAlubm是 ALAssetsGroup iOS 8 之后是 )
 *  @param fail      获取失败无返回
 */
+ (void)getPhotoAlbum:(nonnull NSString *)albumName
              success:(void (^) (id PhotoAlubm))success
                 fail:(void (^) (NSString *errMsg))fail;
@end


NS_ASSUME_NONNULL_END
