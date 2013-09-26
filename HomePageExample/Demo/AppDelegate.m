
#import "AppDelegate.h"
#import "ListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	ListViewController *listViewController1 = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
	ListViewController *listViewController2 = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
	ListViewController *listViewController3 = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
	
	listViewController1.title = @"1";
	listViewController2.title = @"2";
	listViewController3.title = @"3";

    listViewController1.tabBarItem.image = [UIImage imageNamed:@"hoton"];
	listViewController2.tabBarItem.image = [UIImage imageNamed:@"nearoff"];
    listViewController3.tabBarItem.image = [UIImage imageNamed:@"loveoff"];
        
	listViewController2.tabBarItem.imageInsets = UIEdgeInsetsMake(0.0f, -4.0f, 0.0f, 0.0f);
	listViewController2.tabBarItem.titlePositionAdjustment = UIOffsetMake(4.0f, 0.0f);

	NSArray *viewControllers = @[listViewController1, listViewController2, listViewController3];
	MHTabBarController *tabBarController = [[MHTabBarController alloc] init];

	tabBarController.delegate = self;
	tabBarController.viewControllers = viewControllers;

	// Uncomment this to select "Tab 2".
	tabBarController.selectedIndex = 1;
    tabBarController.selectedViewController = listViewController2;
    tabBarController.selectedViewController.tabBarItem.image = [UIImage imageNamed:@"nearon"];

	// Uncomment this to select "Tab 3".
	//tabBarController.selectedViewController = listViewController3;

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = tabBarController;
	[self.window makeKeyAndVisible];
	return YES;
}

- (BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
	NSLog(@"mh_tabBarController %@ shouldSelectViewController %@ at index %u", tabBarController, viewController, index);

	// Uncomment this to prevent "Tab 3" from being selected.
	//return (index != 2);

	return YES;
}

- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
	NSLog(@"mh_tabBarController %@ didSelectViewController %@ at index %u", tabBarController, viewController, index);
    NSLog(@"here!!!");
    
    if(index == 0){
        NSLog(@"here1!!!");
        //viewController.tabBarItem.image = [UIImage imageNamed:@"hoton"];
        ListViewController *selectedListViewController = [tabBarController.viewControllers objectAtIndex:0];
        NSLog(@"title? %@", selectedListViewController.title);
        selectedListViewController.tabBarItem.image = [UIImage imageNamed:@"hoton"];
    }
    else if(index == 1){
        NSLog(@"here2!!!");
        ListViewController *selectedListViewController = [tabBarController.viewControllers objectAtIndex:1];
        NSLog(@"title? %@", selectedListViewController.title);
        selectedListViewController.tabBarItem.image = [UIImage imageNamed:@"nearon"];
    }
    else{
        NSLog(@"here3!!!");
        ListViewController *selectedListViewController = [tabBarController.viewControllers objectAtIndex:2];
        NSLog(@"title? %@", selectedListViewController.title);
        selectedListViewController.tabBarItem.image = [UIImage imageNamed:@"loveon"];
    }
    
}

@end
