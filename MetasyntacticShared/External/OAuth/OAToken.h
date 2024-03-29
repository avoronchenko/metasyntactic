//
//  OAToken.h
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

@interface OAToken : NSObject {
@protected
  NSString* key;
  NSString* secret;
  NSDictionary* fields;
}

@property (readonly, copy) NSString* key;
@property (readonly, copy) NSString* secret;
@property (readonly, retain) NSDictionary* fields;

//- (id) initWithKey:(NSString*) key secret:(NSString*) secret;
//- (id) initWithUserDefaultsUsingServiceProviderName:(NSString*) provider prefix:(NSString*) prefix;
//- (id) initWithHTTPResponseBody:(NSString*) body;
//- (NSInteger) storeInUserDefaultsWithServiceProviderName:(NSString*) provider prefix:(NSString*) prefix;

+ (OAToken*) tokenWithKey:(NSString*) key secret:(NSString*) secret;
+ (OAToken*) tokenWithHTTPResponseBody:(NSString*) body;

@end
