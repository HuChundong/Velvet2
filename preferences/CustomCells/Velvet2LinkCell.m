#import "../../headers/HeadersPreferences.h"

@implementation Velvet2LinkCell
-(void)layoutSubviews {
    [super layoutSubviews];

    if (self.specifier.properties[@"systemIcon"]) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithFont:[UIFont systemFontOfSize:24]];
        self.imageView.image = [UIImage systemImageNamed:self.specifier.properties[@"systemIcon"] withConfiguration:config];
        self.imageView.tintColor = kVelvetColor;

        self.textLabel.frame = CGRectMake(60, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    }
}
@end