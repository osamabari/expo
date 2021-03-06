#import <ReactABI20_0_0/ABI20_0_0RCTView.h>
#import <ReactABI20_0_0/ABI20_0_0RCTComponent.h>

@interface ABI20_0_0EXBannerView : ABI20_0_0RCTView

@property (nonatomic, copy) ABI20_0_0RCTBubblingEventBlock onAdPress;
@property (nonatomic, copy) ABI20_0_0RCTBubblingEventBlock onAdError;

@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSString *placementId;

@end
