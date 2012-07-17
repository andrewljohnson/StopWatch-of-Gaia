//
//  SavingDictionary.h
//  TrailTracker
//
//  Created by Anna Hentzel on 3/11/11.
//  Copyright 2011 TrailBehind, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SavingDictionary : NSObject {
  NSString * filePath;
}

@property (nonatomic, retain) NSString* filePath;
@property (nonatomic, retain) NSMutableDictionary * dict;


- (id) initWithPath:(NSString*) path;
- (id) initWithClass:(Class)c;

- (id) objectForKey:(id)aKey;
- (void) setObject:(id)anObject forKey:(id)aKey;
- (void) removeObjectForKey:(id)aKey;
- (void) clearDictionary;
- (NSArray *)allKeys;
- (NSArray *)allValues;

@end
