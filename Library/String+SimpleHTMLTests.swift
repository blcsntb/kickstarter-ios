@testable import Library
import XCTest

final class StringSimpleHTMLTests: XCTestCase {
  func testHtmlParsing() {
    let font = UIFont.ksr_caption1()
    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"
    let stripped = "Hello Brandon, how are you?"

    guard let string = html.simpleHtmlAttributedString(font: font) else {
      XCTAssert(false, "Couldn't parse HTML string.")
      return
    }

    XCTAssertEqual(string.string, stripped)
  }

  func testHtmlWithAllFontsSpecified() {
    let font = UIFont.ksr_caption1()
    let bold = UIFont.ksr_caption1(size: 14.0).bolded
    let italic = UIFont.ksr_caption1(size: 16.0).italicized

    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"

    guard let string = html.simpleHtmlAttributedString(font: font, bold: bold, italic: italic) else {
      XCTAssert(false, "Couldn't parse HTML string")
      return
    }

    let extractedBold = string.attribute(NSAttributedString.Key.font, at: 1, effectiveRange: nil) as? UIFont

    if let testBold = extractedBold {
      XCTAssertEqual(testBold.pointSize, bold.pointSize)
      XCTAssert(testBold.fontDescriptor.symbolicTraits.contains(.traitBold))
    } else {
      XCTAssertTrue(false, "Couldn't find font in attributed string")
    }

    let extractedItalic = string.attribute(NSAttributedString.Key.font, at: 7, effectiveRange: nil) as? UIFont
    if let testItalic = extractedItalic {
      XCTAssertEqual(testItalic.pointSize, italic.pointSize)
      XCTAssert(testItalic.fontDescriptor.symbolicTraits.contains(.traitItalic))
    } else {
      XCTAssertTrue(false, "Couldn't find font in attributed string")
    }

    let extractedBase = string.attribute(NSAttributedString.Key.font, at: 16, effectiveRange: nil) as? UIFont
    if let testBase = extractedBase {
      XCTAssertEqual(testBase.pointSize, font.pointSize)
      XCTAssertFalse(testBase.fontDescriptor.symbolicTraits.contains(.traitBold))
      XCTAssertFalse(testBase.fontDescriptor.symbolicTraits.contains(.traitItalic))
    } else {
      XCTAssertTrue(false, "Couldn't find font in attributed string")
    }
  }

  func testHtmlWithFallbackFonts() {
    let font = UIFont.ksr_caption1()

    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"

    let string = html.simpleHtmlAttributedString(font: font)
    if string == nil {
      XCTAssert(false, "Couldn't parse HTML string")
    }

    let extractedBold = string?.attribute(NSAttributedString.Key.font, at: 1, effectiveRange: nil) as? UIFont
    if let testBold = extractedBold {
      XCTAssertEqual(testBold.pointSize, font.pointSize)
      XCTAssert(testBold.fontDescriptor.symbolicTraits.contains(.traitBold))
    } else {
      XCTAssert(false, "Couldn't find font in attributed string")
    }

    let extractedItalic = string?.attribute(
      NSAttributedString.Key.font,
      at: 7,
      effectiveRange: nil
    ) as? UIFont
    if let testItalic = extractedItalic {
      XCTAssertEqual(testItalic.pointSize, font.pointSize)
      XCTAssert(testItalic.fontDescriptor.symbolicTraits.contains(.traitItalic))
    } else {
      XCTAssertTrue(false, "Couldn't find font in attributed string")
    }

    let extractedBase = string?.attribute(
      NSAttributedString.Key.font,
      at: 16,
      effectiveRange: nil
    ) as? UIFont
    if let testBase = extractedBase {
      XCTAssertEqual(testBase.pointSize, font.pointSize)
      XCTAssertFalse(testBase.fontDescriptor.symbolicTraits.contains(.traitBold))
      XCTAssertFalse(testBase.fontDescriptor.symbolicTraits.contains(.traitItalic))
    } else {
      XCTAssertTrue(false, "Couldn't find font in attributed string")
    }
  }

  func test_htmlStripped_WithSimpleHtml() {
    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"
    XCTAssertEqual("Hello Brandon, how are you?", html.htmlStripped())
  }

  func test_htmlStripped_WithParagraphTags() {
    let html = "<b>Hello</b> <i>Brandon</i>,<p>how are you?</p>"
    XCTAssertEqual("Hello Brandon,\nhow are you?", html.htmlStripped())
    XCTAssertEqual("Hello Brandon,\nhow are you?\n", html.htmlStripped(trimWhitespace: false))
  }
}
