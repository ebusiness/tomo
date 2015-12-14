// Generated by Apple Swift version 2.1.1 (swiftlang-700.1.101.15 clang-700.1.81)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if defined(__has_include) && __has_include(<uchar.h>)
# include <uchar.h>
#elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif

typedef struct _NSZone NSZone;

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted) 
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
#endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
#if defined(__has_feature) && __has_feature(modules)
@import ObjectiveC;
#endif

#import <WechatKit/WechatKit.h>

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class NSURL;

SWIFT_CLASS("_TtC9WechatKit13WechatManager")
@interface WechatManager : NSObject

/// 微信开放平台,注册的应用程序id
+ (NSString * __null_unspecified)appid;
+ (void)setAppid:(NSString * __null_unspecified)newValue;

/// 微信开放平台,注册的应用程序Secret
+ (NSString * __null_unspecified)appSecret;
+ (void)setAppSecret:(NSString * __null_unspecified)value;

/// openid
+ (NSString * __null_unspecified)openid;
+ (void)setOpenid:(NSString * __null_unspecified)value;

/// access token
+ (NSString * __null_unspecified)access_token;
+ (void)setAccess_token:(NSString * __null_unspecified)value;

/// refresh token
+ (NSString * __null_unspecified)refresh_token;
+ (void)setRefresh_token:(NSString * __null_unspecified)value;

/// csrf
+ (NSString * __nonnull)csrf_state;
+ (void)setCsrf_state:(NSString * __nonnull)value;

/// A shared instance
+ (WechatManager * __nonnull)sharedInstance;

/// 检查微信是否已被用户安装
///
/// \returns  微信已安装返回true，未安装返回false
- (BOOL)isInstalled;

/// 处理微信通过URL启动App时传递的数据
///
/// 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
///
/// \param url 微信启动第三方应用时传递过来的URL
///
/// \returns  成功返回true，失败返回false
- (BOOL)handleOpenURL:(NSURL * __nonnull)url;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


@interface WechatManager (SWIFT_EXTENSION(WechatKit))

/// 微信认证
- (void)checkAuth;
@end


@interface WechatManager (SWIFT_EXTENSION(WechatKit))

/// 微信认证成功
///
/// \param res 用户信息
- (void)success:(id __nonnull)res;

/// 微信认证失败
///
/// \param errCode 返回认证错误码
/// 详见 https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419318634&token=&lang=zh_CN
- (void)failure:(NSInteger)errCode;
@end

@class BaseReq;
@class BaseResp;

@interface WechatManager (SWIFT_EXTENSION(WechatKit)) <WXApiDelegate>

/// 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
///
/// <ul><li>收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。</li><li>可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。</li></ul>
/// \param req 具体请求内容，是自动释放的
- (void)onReq:(BaseReq * __nonnull)req;

/// 发送一个sendReq后，收到微信的回应
///
/// <ul><li>收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。</li><li>可能收到的处理结果有SendMessageToWXResp、SendAuthResp等</li></ul>
/// \param resp 具体的回应内容，是自动释放的
- (void)onResp:(BaseResp * __nonnull)resp;
@end

@class UIImage;

@interface WechatManager (SWIFT_EXTENSION(WechatKit))

/// 分享
///
/// \param scence 请求发送场景
///
/// \param image 消息缩略图
///
/// \param title 标题
///
/// \param description 描述内容
///
/// \param url 地址
///
/// \param extInfo app分享信息(点击分享内容返回程序时,会传给WechatManagerShareDelegate.showMessage(message: String)
- (void)share:(enum WXScene)scence image:(UIImage * __nullable)image title:(NSString * __nonnull)title description:(NSString * __nonnull)description url:(NSString * __nullable)url extInfo:(NSString * __nullable)extInfo;
@end


@interface WechatManager (SWIFT_EXTENSION(WechatKit))
@end

#pragma clang diagnostic pop
