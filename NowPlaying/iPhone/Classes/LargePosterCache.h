// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@interface LargePosterCache : NSObject {
    NSLock* gate;
    NSDictionary* indexData;
}

@property (retain) NSLock* gate;
@property (retain) NSDictionary* indexData;

+ (LargePosterCache*) cache;

- (UIImage*) firstPosterForMovie:(Movie*) movie;
- (UIImage*) posterForMovie:(Movie*) movie index:(NSInteger) index;

- (void) downloadFirstPosterForMovie:(Movie*) movie;
- (void) downloadPosterForMovie:(Movie*) movie index:(NSInteger) index;
- (NSInteger) posterCountForMovie:(Movie*) movie;

@end