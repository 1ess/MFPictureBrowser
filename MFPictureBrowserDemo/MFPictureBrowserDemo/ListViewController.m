

#import "ListViewController.h"
#import "RemoteImageViewController.h"
#import "LocalImageViewController.h"
@interface ListViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ListViewController

- (NSArray *)list {
    if (!_list) {
        _list = @[
                  @"网络图片",
                  @"本地图片"
                  ];
    }
    return _list;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (!indexPath.row) {
        RemoteImageViewController *remote = [[RemoteImageViewController alloc] init];
        [self.navigationController pushViewController:remote animated:true];
    }else {
        LocalImageViewController *local = [[LocalImageViewController alloc] init];
        [self.navigationController pushViewController:local animated:true];
    }
    
}

@end
