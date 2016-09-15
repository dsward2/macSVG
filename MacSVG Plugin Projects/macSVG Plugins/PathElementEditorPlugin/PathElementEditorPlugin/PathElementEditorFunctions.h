//
//  PathElementEditorFunctions.h
//  PathElementEditor
//
//  Created by Douglas Ward on 8/7/16.
//
//

#import <Foundation/Foundation.h>

@class PathElementEditor;

@interface PathElementEditorFunctions : NSObject

@property (strong) IBOutlet PathElementEditor * pathElementEditor;

- (void)setInputFieldsForFunction;
- (void)performPathFunction;

@end
