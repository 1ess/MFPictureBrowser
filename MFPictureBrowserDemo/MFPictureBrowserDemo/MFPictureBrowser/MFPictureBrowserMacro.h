//
//  MFPictureBrowserMacro.h
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/5/4.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#ifndef MFPictureBrowserMacro_h
#define MFPictureBrowserMacro_h

static inline void _mf_dispatch_async_on_main_queue(void (^block)(void)) {
    dispatch_async(dispatch_get_main_queue(), block);
}

#endif /* MFPictureBrowserMacro_h */
