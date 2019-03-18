// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@testable import FacebookCore
import XCTest

class ErrorConfigurationBuilderTests: XCTestCase {
  func testBuildingWithRemoteList() {
    let remoteConfig = RemoteErrorConfigurationEntry()
    let remoteList = RemoteErrorConfigurationEntryList(configurations: [remoteConfig])
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 3)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testCreatingWithIdenticalRemoteConfigurations() {
    let remoteList = RemoteErrorConfigurationEntryList(
      configurations: Array(repeating: RemoteErrorConfigurationEntry(), count: 3)
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 3)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testCreatingWithDifferentRemoteConfigurations() {
    let remoteConfig1 = RemoteErrorConfigurationEntry(items: [RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1)])
    let remoteConfig2 = RemoteErrorConfigurationEntry(items: [RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 2)])
    let remoteList = RemoteErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: nil)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testCreatingWithItemlessConfiguration() {
    let remoteConfig = RemoteErrorConfigurationEntry(items: [])
    let remoteList = RemoteErrorConfigurationEntryList(configurations: [remoteConfig])
    XCTAssertNil(ErrorConfigurationBuilder.build(from: remoteList),
                 "Should not be able to build an error configuration from an entry with empty items")
  }

  func testCreatingFromConfigurationiWithIdenticalCodeAndSubcode() {
    let remoteConfig = RemoteErrorConfigurationEntry(
      items: [RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [1, 2])]
    )
    let remoteList = RemoteErrorConfigurationEntryList(configurations: [remoteConfig])
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testCreatingWithDuplicateSubcodesInSingleEntry() {
    let remoteConfig = RemoteErrorConfigurationEntry(
      items: [RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [2, 2])]
    )
    let remoteList = RemoteErrorConfigurationEntryList(configurations: [remoteConfig])

    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  func testCreatingWithDuplicateSubcodesAcrossItems() {
    let remoteConfig = RemoteErrorConfigurationEntry(
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [1, 2]),
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 2, subcodes: [1, 2])
      ]
    )
    let remoteList = RemoteErrorConfigurationEntryList(configurations: [remoteConfig])

    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: nil)),
                    "A config should contain an entry for the major code it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: 1)),
                    "A config should contain an entry for the major/minor code pair it was created with")
    XCTAssertNotNil(config.configuration(for: ErrorConfiguration.Key(majorCode: 2, minorCode: 2)),
                    "A config should contain an entry for the major/minor code pair it was created with")
  }

  //  // | old code | old subcodes | new code | new subcodes | override topLevel | override second level |
  //  //    1           [ ]           1           [ ]                yes                  n/a
  func testCreatingFromDuplicateEntriesWithIdenticalCodes() {
    let remoteConfig1 = RemoteErrorConfigurationEntry(
      name: .other,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1)
      ]
    )
    let remoteConfig2 = RemoteErrorConfigurationEntry(
      name: .transient,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1)
      ]
    )
    let remoteList = RemoteErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .transient,
      "An entry with no subcodes should override the configuration for its primary code"
    )
  }

  //  // | old code | old subcodes | new code | new subcodes | override topLevel | override second level |
  //  //    1           [ ]           1           [ 2 ]              no                   yes
  func testCreatingWithSameMajorCodeDifferentMinorCodes() {
    let remoteConfig1 = RemoteErrorConfigurationEntry(
      name: .other,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1)
      ]
    )
    let remoteConfig2 = RemoteErrorConfigurationEntry(
      name: .transient,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteList = RemoteErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .other,
      "A more specific config should not override a previously created less specific config with the same primary code"
    )
    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1))?.category,
      .transient,
      "A remote configuration with a code and subcode should create a new entry in the configuration map"
    )
  }

  //  // | old code | old subcodes | new code | new subcodes | override topLevel | override second level |
  //  //    1           [ 2 ]         1           [ 2 ]              no                   yes
  func testCreatingWithMultitpleEntriesIdenticalCodeAndSubcode() {
    let remoteConfig1 = RemoteErrorConfigurationEntry(
      name: .other,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteConfig2 = RemoteErrorConfigurationEntry(
      name: .transient,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteList = RemoteErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .other,
      "A more specific config should not override the top level error"
    )
    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1))?.category,
      .transient,
      "A config should override the secondary configuration when the code and subcode match"
    )
  }

  //  // | old code | old subcodes | new code | new subcodes | override topLevel | override second level |
  //  //    1           [ 2 ]         1           [ ]                yes                  no
  func testCreatingWitMultipleEntriesWithIdenticalCodeDifferentSubcodes() {
    let remoteConfig1 = RemoteErrorConfigurationEntry(
      name: .other,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [1])
      ]
    )
    let remoteConfig2 = RemoteErrorConfigurationEntry(
      name: .transient,
      items: [
        RemoteErrorConfigurationEntry.ErrorCodeGroup(code: 1, subcodes: [])
      ]
    )
    let remoteList = RemoteErrorConfigurationEntryList(
      configurations: [
        remoteConfig1,
        remoteConfig2
      ]
    )
    guard let config = ErrorConfigurationBuilder.build(from: remoteList) else {
      return XCTFail("Should be able to build an error configuration from a valid list of remote entries")
    }

    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: nil))?.category,
      .transient,
      "A less specific config should override a more specific error"
    )
    XCTAssertEqual(
      config.configuration(for: ErrorConfiguration.Key(majorCode: 1, minorCode: 1))?.category,
      .other,
      "A config should override the secondary configuration when the code and subcode match"
    )
  }
}
