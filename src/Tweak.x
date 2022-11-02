#import "../headers/HeadersTweak.h"

Velvet2PrefsManager *prefsManager;

%hook NCNotificationShortLookViewController
%property (nonatomic,retain) UIView *velvetView;

-(void)viewDidLoad {
    %orig;

    NCNotificationShortLookView *view = (NCNotificationShortLookView *)self.viewForPreview;

    UIView *velvetView = [UIView new];
    [velvetView.layer insertSublayer:[CALayer layer] atIndex:0];
    [velvetView.layer insertSublayer:[CALayer layer] atIndex:0];
    [view.backgroundMaterialView.superview insertSubview:velvetView atIndex:1];

    self.velvetView = velvetView;
    self.velvetView.clipsToBounds = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}

-(void)viewDidLayoutSubviews {
    %orig;

    if (self.viewForPreview.frame.size.width == 0) return;

    [self velvetUpdateStyle];
}

-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    
    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:self.notificationRequest.sectionIdentifier];
    NCNotificationShortLookView *view                       = (NCNotificationShortLookView *)self.viewForPreview;
    NCNotificationSeamlessContentView *contentView          = [view valueForKey:@"notificationContentView"];
    NCBadgedIconView *badgedIconView                        = [contentView valueForKey:@"badgedIconView"];
    UIImageView *appIconView                                = (UIImageView *)badgedIconView.iconView;
    colorizer.appIcon = appIconView.image;

    // For some reason, dateLabel isn't fully initialized yet after viewDidLayoutSubviews
    [colorizer colorDate:[contentView valueForKey:@"dateLabel"]];
}

%new
-(void)velvetUpdateStyle {
    NSString *identifier = self.notificationRequest.sectionIdentifier;

    // Initialize content variables
    NCNotificationShortLookView *view                       = (NCNotificationShortLookView *)self.viewForPreview;
    MTMaterialView *materialView                            = view.backgroundMaterialView;
    NCNotificationViewControllerView *controllerView        = [self valueForKey:@"contentSizeManagingView"];
    UIView *stackDimmingView                                = [controllerView valueForKey:@"stackDimmingView"];
    NCNotificationSeamlessContentView *contentView          = [view valueForKey:@"notificationContentView"];
    UILabel *title                                          = [contentView valueForKey:@"primaryTextLabel"];
    UILabel *message                                        = [contentView valueForKey:@"secondaryTextElement"];
    UILabel *dateLabel                                      = [contentView valueForKey:@"dateLabel"];
    NCBadgedIconView *badgedIconView                        = [contentView valueForKey:@"badgedIconView"];
    UIImageView *appIconView                                = (UIImageView *)badgedIconView.iconView;

    self.velvetView.frame = materialView.frame;

    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:identifier];
    colorizer.appIcon = appIconView.image;

    CGFloat cornerRadius = [[prefsManager settingForKey:@"cornerRadiusEnabled" withIdentifier:identifier] boolValue] ? [[prefsManager settingForKey:@"cornerRadiusCustom" withIdentifier:identifier] floatValue] : 19;
	materialView.layer.continuousCorners = cornerRadius < materialView.frame.size.height / 2;
	materialView.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    self.velvetView.layer.continuousCorners = cornerRadius < self.velvetView.frame.size.height / 2;
	self.velvetView.layer.cornerRadius = MIN(cornerRadius, self.velvetView.frame.size.height / 2);

    view.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    materialView.superview.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    stackDimmingView.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);

    [colorizer colorBackground:self.velvetView];
    [colorizer colorBorder:self.velvetView];
    [colorizer colorShadow:materialView];
    [colorizer colorLine:self.velvetView inFrame:materialView.frame];
    [colorizer colorTitle:title];
    [colorizer colorMessage:message];
    [colorizer colorDate:dateLabel];

    // Icon
    // appIcon.layer.cornerRadius = 19;
    // appIcon.clipsToBounds = YES;
}
%end

%hook NCNotificationStructuredListViewController
-(void)viewDidLoad {
    %orig;
    // self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
}
%end

%ctor {
    prefsManager = [NSClassFromString(@"Velvet2PrefsManager") sharedInstance];

    if ([[prefsManager objectForKey:@"enabled"] boolValue]) {
        %init;
    }
}