//
//  ATLControlChannel.h
//  AdjustTestLibrary
//
//  Created by Pedro on 23.08.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLTestLibrary.h"

@interface ATLControlChannel : NSObject

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary;

- (void)teardown;

@end
