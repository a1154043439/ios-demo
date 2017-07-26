//
//  Items.h
//  demo4
//
//  Created by test on 2017/7/15.
//  Copyright © 2017年 test. All rights reserved.
//

#ifndef Items_h
#define Items_h


#endif /* Items_h */
#import <Foundation/Foundation.h>

@interface Items:NSObject
/** 每段标题 */
@property (copy , nonatomic) NSString *header;
/** 每行标题 */
@property (strong , nonatomic) NSArray *titles;
/** 对应的控制器 */
@property (strong , nonatomic) NSArray *classes;
@end
