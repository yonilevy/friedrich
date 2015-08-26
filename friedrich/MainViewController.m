#import "MainViewController.h"
#import "PureLayout.h"
#import "PTEConsoleTableView.h"
#import "UIControl+BlocksKit.h"
#import "DDLogMacros.h"
#import "FRUtils.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

static const int DIRECTION_BUTTON_WIDTH = 80;
static const int DIRECTION_BUTTON_HEIGHT = 60;
static const int DIRECTION_BUTTON_OFFSET = 15;

@interface MainViewController ()

@property(nonatomic) BOOL didSetupConstraints;
@property(nonatomic) UIButton *openClawButton;
@property(nonatomic) UIButton *closeClawButton;
@property(nonatomic) UIButton *forwardButton;
@property(nonatomic) UIButton *backwardButton;
@property(nonatomic) UIButton *leftButton;
@property(nonatomic) UIButton *rightButton;
@property(nonatomic) UIButton *stopButton;

@property(nonatomic, strong) NSArray *clawButtons;
@property(nonatomic, strong) NSArray *directionButtons;

@property(nonatomic, strong) PTEConsoleTableView *consoleTableView;

@end

@implementation MainViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x143D3D);
    
    self.clawButtons = @[self.openClawButton, self.closeClawButton];
    [self.clawButtons enumerateObjectsUsingBlock:^(id button, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:button];
    }];

    self.directionButtons = @[self.forwardButton, self.backwardButton, self.leftButton, self.rightButton, self.stopButton];
    [self.directionButtons enumerateObjectsUsingBlock:^(id button, NSUInteger idx, BOOL *stop) {
        [self.view addSubview:button];
    }];
    
    [self.view addSubview:self.consoleTableView];
}

- (void)updateViewConstraints
{
    if (!self.didSetupConstraints) {
        [self.clawButtons autoSetViewsDimension:ALDimensionHeight toSize:60];
        [self.clawButtons autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSize:120];

        [self.closeClawButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:60];
        [self.openClawButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:60];

        [self.directionButtons autoSetViewsDimensionsToSize:CGSizeMake(DIRECTION_BUTTON_WIDTH, DIRECTION_BUTTON_HEIGHT)];

        [self.forwardButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.closeClawButton withOffset:40];
        [self.forwardButton autoAlignAxisToSuperviewAxis:ALAxisVertical];

        [self.stopButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.forwardButton withOffset:DIRECTION_BUTTON_OFFSET];
        [self.stopButton autoAlignAxis:ALAxisVertical toSameAxisOfView:self.forwardButton];

        [self.leftButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.forwardButton withOffset:DIRECTION_BUTTON_OFFSET];
        [self.leftButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.stopButton withOffset:-DIRECTION_BUTTON_OFFSET];

        [self.rightButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.forwardButton withOffset:DIRECTION_BUTTON_OFFSET];
        [self.rightButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.stopButton withOffset:DIRECTION_BUTTON_OFFSET];

        [self.backwardButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.backwardButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.stopButton withOffset:DIRECTION_BUTTON_OFFSET];

        [self.consoleTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.consoleTableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.consoleTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.backwardButton withOffset:80];
        [self.consoleTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];

        self.didSetupConstraints = YES;
    }

    [super updateViewConstraints];
}

- (UIButton *)openClawButton
{
    if (!_openClawButton) {
        __weak MainViewController *weakSelf = self;
        _openClawButton = [self createButtonWithTitle:@"Open Claw" action:^(id sender) {
            [weakSelf sendCommand:@"open"];
        }];
    }
    return _openClawButton;
}

- (UIButton *)closeClawButton
{
    if (!_closeClawButton) {
        __weak MainViewController *weakSelf = self;
        _closeClawButton = [self createButtonWithTitle:@"Close Claw" action:^(id sender) {
            [weakSelf sendCommand:@"clos"];
        }];
    }
    return _closeClawButton;
}

- (UIButton *)forwardButton
{
    if (!_forwardButton) {
        __weak MainViewController *weakSelf = self;
        _forwardButton = [self createButtonWithTitle:@"Forward" action:^(id sender) {
            [weakSelf sendCommand:@"frwd"];
        }];
    }
    return _forwardButton;
}

- (UIButton *)backwardButton
{
    if (!_backwardButton) {
        __weak MainViewController *weakSelf = self;
        _backwardButton = [self createButtonWithTitle:@"Backward" action:^(id sender) {
            [weakSelf sendCommand:@"bkwd"];
        }];
    }
    return _backwardButton;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        __weak MainViewController *weakSelf = self;
        _leftButton = [self createButtonWithTitle:@"Left" action:^(id sender) {
            [weakSelf sendCommand:@"left"];
        }];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        __weak MainViewController *weakSelf = self;
        _rightButton = [self createButtonWithTitle:@"Right" action:^(id sender) {
            [weakSelf sendCommand:@"rght"];
        }];
    }
    return _rightButton;
}

- (UIButton *)stopButton
{
    if (!_stopButton) {
        __weak MainViewController *weakSelf = self;
        _stopButton = [self createButtonWithTitle:@"Stop" action:^(id sender) {
            [weakSelf sendCommand:@"stop"];
        }];
    }
    return _stopButton;
}

- (PTEConsoleTableView *)consoleTableView
{
    if (!_consoleTableView) {
        _consoleTableView = [PTEConsoleTableView newAutoLayoutView];
        _consoleTableView.backgroundColor = UIColorFromRGBA(0, 0.3);
    }
    return _consoleTableView;
}

- (UIButton *)createButtonWithTitle:(NSString *)title action:(void (^)(id))action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = UIColorFromRGBA(0, 0.2);
    [button setTitle:title forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    button.layer.cornerRadius = 10.0f;
    button.layer.shadowColor = [[UIColor blackColor] CGColor];
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 2.0f;
    button.layer.shadowOpacity = 0.3f;

    [button bk_addEventHandler:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)sendCommand:(NSString *)command
{
    DDLogInfo(@"Sending command \"%@\"", command);
}

@end
