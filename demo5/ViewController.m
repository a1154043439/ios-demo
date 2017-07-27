//
//  ViewController.m
//  demo5
//
//  Created by test on 2017/7/21.
//  Copyright © 2017年 test. All rights reserved.
//

#import "ViewController.h"
#import "Items.h"
#import "Masonry.h"

@interface ViewController ()<UITableViewDelegate , UITableViewDataSource>
/** tableView */
@property (nonatomic , weak) UITableView *tableView;

/** examples */
@property (nonatomic , strong) NSMutableArray *examples;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化
    [self _setup];
    
    // 设置导航栏
    [self _setupNavigationItem];
    
    // 设置子控件
    [self _setupSubViews];
    
}
#pragma mark - 公共方法


#pragma mark - 私有方法

#pragma mark - Getter
- (NSMutableArray *)examples
{
    if (_examples == nil) {
        
        _examples = [[NSMutableArray alloc] init];
        /**
         一、iOS常用控件的使用，ableView的使用
         */
        Items *paternityExample = [[Items alloc] init];
        paternityExample.header = @"OC高级语法的实践";
        paternityExample.titles = @[@"1.1 block的使用",@"1.2 block在ARC/MRC中的区别 "
                                    ,@"1.3 RunLoop",@"1.4 RunLoop中的model"
                                    ,@"1.5 RunLoop中的timer",@"1.6 NSThread"
                                    ,@"1.7 UISwitch",@"1.8 Runtime"
                                    ,@"1.9 GCDController",@"1.10 ScrollViewController"
                                    ,@"1.11 TableViewController",@"1.12 PageViewController"
                                    ,@"1.13 NetEaseNewsController",@"1.14 TableViewController"];
        paternityExample.classes = @[@"BlockViewController",@"BlockDiffViewController",@"RunLoopController"
                                     ,@"RunLoopModelViewController",@"RunLoopTimerViewController"
                                     ,@"NSThreadController"
                                     ,@"SwitchViewController",@"RuntimeController"
                                     ,@"GCDController",@"ScrollViewController"
                                     ,@"TableViewController",@"PageViewController"
                                     ,@"NetEaseNewsController",@"ThirdViewController"
                                     ,@"ThirdViewController"];
        [_examples addObject:paternityExample];
        
    }
    return _examples;
}

#pragma mark - 初始化
- (void)_setup
{
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 设置导航栏
- (void)_setupNavigationItem
{
    self.title = @"demo";
}

#pragma mark - 设置子控件
- (void)_setupSubViews
{
    // 创建tableView
    [self _setupTableView];
}

// 创建tableView
- (void)_setupTableView
{
    // 初始化tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.rowHeight = 55;
    tableView.delegate = self;
    tableView.dataSource = self;
    //tableView的背景颜色
    tableView.backgroundColor = [UIColor whiteColor];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
     //auto 布局,masonry add constraints,
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
//Asks the data source to return the number of sections in the table view.
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView is :%lu",self.examples.count);
    return self.examples.count;
    
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection is :%lu", [[self.examples[section] titles] count]);
    return [[self.examples[section] titles] count];
}


//Asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    Items *example = self.examples[indexPath.section];
    cell.textLabel.text = example.titles[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"详情请参照%@",example.classes[indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Items *example = self.examples[section];
    return example.header;
}
//Tells the delegate that the specified row is now selected.,The delegate handles selections in this method. One of the things it can do is exclusively assign the check-mark image
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //不加此句时，在二级目录点击返回时，此行会由选中状态慢慢变为非选中状态
    //加上此句时，返回时直接就是非选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Items *example = self.examples[indexPath.section];
    
    NSString* vcClassString = example.classes[indexPath.row];
    //    NSString* vcClassString = example.classes[0];
    
    UIViewController *vc = [[NSClassFromString(vcClassString) alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
