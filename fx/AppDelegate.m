//
//  AppDelegate.m
//  fx
//
//  Created by Tom Newton on 13/10/2015.
//  Copyright © 2015 Tom Newton. All rights reserved.
//


#import "AppDelegate.h"
#import "CurrencyPairVO.h"


#define USDCAD @"USD/CAD"
#define GBPCAD @"GBP/CAD"
#define GBPUSD @"GBP/USD"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenu *menu;
@property (strong, nonatomic) NSImage *image;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *vos;
@property (strong, nonatomic) NSMenuItem *lastUpdatedMenuItem;
@property (strong, nonatomic) NSMenuItem *quitMenuItem;
@property (strong, nonatomic) NSDate *lastUpdatedDate;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    //init
    [self initStatusBar];
    [self initMenu];
    
    //setup timer.
    self.timer = [NSTimer timerWithTimeInterval:300.0 target:self selector:@selector(getFX) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    //get data.
    [self getFX];
    
}


-(void)initStatusBar {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusItem.image = [NSImage imageNamed:@"icon_20x20"];
    _statusItem.highlightMode = NO;
    _statusItem.toolTip = @"command-click to quit";
    
    [_statusItem.image setTemplate:NO];
    [_statusItem setAction:@selector(itemClicked:)];
}

-(void)initMenu{
    
    //Supported Currency Pairs.
    NSArray *currencyPairs = [NSArray arrayWithObjects:USDCAD, GBPCAD, GBPUSD, nil];
    
    self.menu = [[NSMenu alloc] initWithTitle:@"FX"];
    self.vos = [NSMutableArray array];
    
    for ( int i = 0; i < [currencyPairs count]; i++ ){
        CurrencyPairVO *vo = [[CurrencyPairVO alloc] initWithCode:[currencyPairs objectAtIndex:i]];
        [self.vos addObject:vo];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:vo.pairCode action:@selector(visitChart:) keyEquivalent:@""];
        [self.menu addItem:item];
        vo.menuItem = item;
    }
    
    self.lastUpdatedMenuItem = [[NSMenuItem alloc] initWithTitle:@"Last Updated:" action:nil keyEquivalent:@""];
    self.quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    
    [self.menu addItem: self.lastUpdatedMenuItem];
    [self.menu addItem: self.quitMenuItem];
    
    self.statusItem.menu = self.menu;
}


-(void)getFX {
    
    for ( CurrencyPairVO* vo in self.vos ){
        NSString* rate = [self getRateForPair:[vo getCodeForYahoo]];
        vo.rate = rate;
        [self.menu itemChanged:vo.menuItem];
        
        float inverse = 1.0f / [vo.getRateAsNumber floatValue];
        vo.menuItem.toolTip =  [NSString stringWithFormat:@"Inverse: %f", inverse];
    }
    
    self.lastUpdatedDate = [NSDate date];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm z"];
    
    NSString *timeString = [format stringFromDate:self.lastUpdatedDate];
    
    self.lastUpdatedMenuItem.title = [NSString stringWithFormat:@"%@: %@", @"Last Update: ",timeString];
    
    [self.menu itemChanged:self.lastUpdatedMenuItem];
}


-(NSString*)getRateForPair:(NSString*)pair{
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=%@=X", pair]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    NSString *data = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSArray *components = [data componentsSeparatedByString:@","];
    
    if ( error != nil ){
        
        return @"Error";
    }
    
    self.statusItem.toolTip = [NSString stringWithFormat:@"Last updated: %@", [components objectAtIndex:3]];
    
    return [components objectAtIndex:1];
}

-(void)visitChart:(NSMenuItem*)menu{
    
    NSString* from = [menu.title substringWithRange:NSMakeRange(0,3)];
    NSString* to = [menu.title substringWithRange:NSMakeRange(4,3)];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.xe.com/currencycharts/?from=%@&to=%@&view=1W", from, to]]];
}


- (void)itemClicked:(id)sender {
    NSEvent *event = [NSApp currentEvent];
    if([event modifierFlags] & NSControlKeyMask) {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


-(void)quit{
    [[NSApplication sharedApplication] terminate:self];
    return;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self.timer invalidate];
    self.timer = nil;
}

@end
