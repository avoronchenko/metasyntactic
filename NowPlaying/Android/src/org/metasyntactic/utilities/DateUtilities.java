//Copyright 2008 Cyrus Najmabadi
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

package org.metasyntactic.utilities;

import org.joda.time.DateTime;

import java.util.Date;

/** @author cyrusn@google.com (Cyrus Najmabadi) */
public class DateUtilities {
  private static Date today;

  static {
    DateTime dt = new DateTime(new Date());
    today = new DateTime(dt.getYear(), dt.getMonthOfYear(), dt.getDayOfMonth(), 12, 0, 0, 0).toDate();
  }


  public static Date getToday() {
    return today;
  }


  public static boolean use24HourTime() {
    return false;
  }
}
