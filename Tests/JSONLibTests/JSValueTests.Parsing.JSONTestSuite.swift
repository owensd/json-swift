/* --------------------------------------------------------------------------------------------
 * Copyright (c) Kiad Studios, LLC. All rights reserved.
 * Licensed under the MIT License. See License in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import XCTest
import JSONLib

class JSValueParsingJSONTestSuiteTests : XCTestCase {

    override func setUp() {
        self.continueAfterFailure = false
    }
    
// TODO(owensd): This should be redone to support Linux as well.
#if os(macOS)
    // SwiftBug(SR-4725) - Support test collateral properly
    func collateral(file name: String) -> String {
        return "/Users/owensd/Projects/json-swift/TestCollateral/JSONTestSuite/test_parsing/\(name)"
//
//        return NSString.path(withComponents: [Bundle(for: JSValueParsingJSONTestSuiteTests.self).bundlePath, "..", "..", "..", "TestCollateral", "JSONTestSuite", "test_parsing", name])
    }

    func parse(file name: String, expectation shouldParse: Bool = true) {
        let path = collateral(file: name)
        XCTAssertNotNil(path)

        let string: NSString?
        do {
            string = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        } catch _ {
            string = nil
        }
        XCTAssertNotNil(string)

        let json = JSON.parse(string! as String)
        if (shouldParse) {
            XCTAssertTrue(json.error == nil, json.error!.userInfo!.description)
        }
        else {
            XCTAssertTrue(json.error != nil, "Should have failed to parse.")
        }
    }

    func test_i_number_double_huge_neg_exp() {
        parse(file: "i_number_double_huge_neg_exp.json", expectation: false)
    }

    func test_i_number_huge_exp() {
        parse(file: "i_number_huge_exp.json", expectation: false)
    }

    func test_i_number_neg_int_huge_exp() {
        parse(file: "i_number_neg_int_huge_exp.json", expectation: false)
    }

    func test_i_number_pos_double_huge_exp() {
        parse(file: "i_number_pos_double_huge_exp.json", expectation: false)
    }

    func test_i_number_real_neg_overflow() {
        parse(file: "i_number_real_neg_overflow.json", expectation: false)
    }

    func test_i_number_real_pos_overflow() {
        parse(file: "i_number_real_pos_overflow.json", expectation: false)
    }

    func test_i_number_real_underflow() {
        parse(file: "i_number_real_underflow.json", expectation: false)
    }

    func test_i_number_too_big_neg_int() {
        parse(file: "i_number_too_big_neg_int.json", expectation: true /* potential precision loss only */)
    }

    func test_i_number_too_big_pos_int() {
        parse(file: "i_number_too_big_pos_int.json", expectation: true /* potential precision loss only */)
    }

    func test_i_number_very_big_negative_int() {
        parse(file: "i_number_very_big_negative_int.json", expectation: true /* potential precision loss only */)
    }

    func test_i_object_key_lone_2nd_surrogate() {
        parse(file: "i_object_key_lone_2nd_surrogate.json", expectation: false)
    }

    func test_i_string_1st_surrogate_but_2nd_missing() {
        parse(file: "i_string_1st_surrogate_but_2nd_missing.json", expectation: false)
    }

    func test_i_string_1st_valid_surrogate_2nd_invalid() {
        parse(file: "i_string_1st_valid_surrogate_2nd_invalid.json", expectation: false)
    }

    func test_i_string_UTF_16LE_with_BOM() {
        parse(file: "i_string_UTF-16LE_with_BOM.json", expectation: false)
    }

    func test_i_string_UTF_8_invalid_sequence() {
        parse(file: "i_string_UTF-8_invalid_sequence.json", expectation: false)
    }

    func test_i_string_UTF8_surrogate_UD800() {
        parse(file: "i_string_UTF8_surrogate_U+D800.json", expectation: false)
    }

    func test_i_string_incomplete_surrogate_and_escape_valid() {
        parse(file: "i_string_incomplete_surrogate_and_escape_valid.json", expectation: false)
    }

    func test_i_string_incomplete_surrogate_pair() {
        parse(file: "i_string_incomplete_surrogate_pair.json", expectation: false)
    }

    func test_i_string_incomplete_surrogates_escape_valid() {
        parse(file: "i_string_incomplete_surrogates_escape_valid.json", expectation: false)
    }

    func test_i_string_invalid_lonely_surrogate() {
        parse(file: "i_string_invalid_lonely_surrogate.json", expectation: false)
    }

    func test_i_string_invalid_surrogate() {
        parse(file: "i_string_invalid_surrogate.json", expectation: false)
    }

    func test_i_string_invalid_utf_8() {
        parse(file: "i_string_invalid_utf-8.json", expectation: false)
    }

    func test_i_string_inverted_surrogates_U1D11E() {
        parse(file: "i_string_inverted_surrogates_U+1D11E.json", expectation: false)
    }

    func test_i_string_iso_latin_1() {
        parse(file: "i_string_iso_latin_1.json", expectation: false)
    }

    func test_i_string_lone_second_surrogate() {
        parse(file: "i_string_lone_second_surrogate.json", expectation: false)
    }

    func test_i_string_lone_utf8_continuation_byte() {
        parse(file: "i_string_lone_utf8_continuation_byte.json", expectation: false)
    }

    func test_i_string_not_in_unicode_range() {
        parse(file: "i_string_not_in_unicode_range.json", expectation: false)
    }

    func test_i_string_overlong_sequence_2_bytes() {
        parse(file: "i_string_overlong_sequence_2_bytes.json", expectation: false)
    }

    func test_i_string_overlong_sequence_6_bytes() {
        parse(file: "i_string_overlong_sequence_6_bytes.json", expectation: false)
    }

    func test_i_string_overlong_sequence_6_bytes_null() {
        parse(file: "i_string_overlong_sequence_6_bytes_null.json", expectation: false)
    }

    func test_i_string_truncated_utf_8() {
        parse(file: "i_string_truncated-utf-8.json", expectation: false)
    }

    func test_i_string_utf16BE_no_BOM() {
        parse(file: "i_string_utf16BE_no_BOM.json", expectation: false)
    }

    func test_i_string_utf16LE_no_BOM() {
        parse(file: "i_string_utf16LE_no_BOM.json", expectation: false)
    }

    func test_i_structure_500_nested_arrays() {
        parse(file: "i_structure_500_nested_arrays.json", expectation: false)
    }

    func test_i_structure_UTF_8_BOM_empty_object() {
        parse(file: "i_structure_UTF-8_BOM_empty_object.json", expectation: false)
    }

    func test_n_array_1_true_without_comma() {
        parse(file: "n_array_1_true_without_comma.json", expectation: false)
    }

    func test_n_array_a_invalid_utf8() {
        parse(file: "n_array_a_invalid_utf8.json", expectation: false)
    }

    func test_n_array_colon_instead_of_comma() {
        parse(file: "n_array_colon_instead_of_comma.json", expectation: false)
    }

    func test_n_array_comma_after_close() {
        parse(file: "n_array_comma_after_close.json", expectation: false)
    }

    func test_n_array_comma_and_number() {
        parse(file: "n_array_comma_and_number.json", expectation: false)
    }

    func test_n_array_double_comma() {
        parse(file: "n_array_double_comma.json", expectation: false)
    }

    func test_n_array_double_extra_comma() {
        parse(file: "n_array_double_extra_comma.json", expectation: false)
    }

    func test_n_array_extra_close() {
        parse(file: "n_array_extra_close.json", expectation: false)
    }

    func test_n_array_extra_comma() {
        parse(file: "n_array_extra_comma.json", expectation: false)
    }

    func test_n_array_incomplete() {
        parse(file: "n_array_incomplete.json", expectation: false)
    }

    func test_n_array_incomplete_invalid_value() {
        parse(file: "n_array_incomplete_invalid_value.json", expectation: false)
    }

    func test_n_array_inner_array_no_comma() {
        parse(file: "n_array_inner_array_no_comma.json", expectation: false)
    }

    func test_n_array_invalid_utf8() {
        parse(file: "n_array_invalid_utf8.json", expectation: false)
    }

    func test_n_array_items_separated_by_semicolon() {
        parse(file: "n_array_items_separated_by_semicolon.json", expectation: false)
    }

    func test_n_array_just_comma() {
        parse(file: "n_array_just_comma.json", expectation: false)
    }

    func test_n_array_just_minus() {
        parse(file: "n_array_just_minus.json", expectation: false)
    }

    func test_n_array_missing_value() {
        parse(file: "n_array_missing_value.json", expectation: false)
    }

    func test_n_array_newlines_unclosed() {
        parse(file: "n_array_newlines_unclosed.json", expectation: false)
    }

    func test_n_array_number_and_comma() {
        parse(file: "n_array_number_and_comma.json", expectation: false)
    }

    func test_n_array_number_and_several_commas() {
        parse(file: "n_array_number_and_several_commas.json", expectation: false)
    }

    func test_n_array_spaces_vertical_tab_formfeed() {
        parse(file: "n_array_spaces_vertical_tab_formfeed.json", expectation: false)
    }

    func test_n_array_star_inside() {
        parse(file: "n_array_star_inside.json", expectation: false)
    }

    func test_n_array_unclosed() {
        parse(file: "n_array_unclosed.json", expectation: false)
    }

    func test_n_array_unclosed_trailing_comma() {
        parse(file: "n_array_unclosed_trailing_comma.json", expectation: false)
    }

    func test_n_array_unclosed_with_new_lines() {
        parse(file: "n_array_unclosed_with_new_lines.json", expectation: false)
    }

    func test_n_array_unclosed_with_object_inside() {
        parse(file: "n_array_unclosed_with_object_inside.json", expectation: false)
    }

    func test_n_incomplete_false() {
        parse(file: "n_incomplete_false.json", expectation: false)
    }

    func test_n_incomplete_null() {
        parse(file: "n_incomplete_null.json", expectation: false)
    }

    func test_n_incomplete_true() {
        parse(file: "n_incomplete_true.json", expectation: false)
    }

    func test_n_multidigit_number_then_00() {
        parse(file: "n_multidigit_number_then_00.json", expectation: false)
    }

    func test_n_number_plus_plus() {
        parse(file: "n_number_++.json", expectation: false)
    }

    func test_n_number_plus_1() {
        parse(file: "n_number_+1.json", expectation: false)
    }

    func test_n_number_plus_Inf() {
        parse(file: "n_number_+Inf.json", expectation: false)
    }

    func test_n_number_minus_01() {
        parse(file: "n_number_-01.json", expectation: false)
    }

    func test_n_number_minus_1_dot_0_dot() {
        parse(file: "n_number_-1.0..json", expectation: false)
    }

    func test_n_number_minus_2_dot() {
        parse(file: "n_number_-2..json", expectation: false)
    }

    func test_n_number_minus_NaN() {
        parse(file: "n_number_-NaN.json", expectation: false)
    }

    func test_n_number_dot_minus_1() {
        parse(file: "n_number_.-1.json", expectation: false)
    }

    func test_n_number_dot_2e_minus_3() {
        parse(file: "n_number_.2e-3.json", expectation: false)
    }

    func test_n_number_0_dot_1_dot_2() {
        parse(file: "n_number_0.1.2.json", expectation: false)
    }

    func test_n_number_0_dot_3e_plus() {
        parse(file: "n_number_0.3e+.json", expectation: false)
    }

    func test_n_number_0_dot_3e() {
        parse(file: "n_number_0.3e.json", expectation: false)
    }

    func test_n_number_0_dot_e1() {
        parse(file: "n_number_0.e1.json", expectation: false)
    }

    func test_n_number_0_capital_E_plus() {
        parse(file: "n_number_0_capital_E+.json", expectation: false)
    }

    func test_n_number_0_capital_E() {
        parse(file: "n_number_0_capital_E.json", expectation: false)
    }

    func test_n_number_0e_plus() {
        parse(file: "n_number_0e+.json", expectation: false)
    }

    func test_n_number_0e() {
        parse(file: "n_number_0e.json", expectation: false)
    }

    func test_n_number_1_dot_0e_plus() {
        parse(file: "n_number_1.0e+.json", expectation: false)
    }

    func test_n_number_1_dot_0e_minus() {
        parse(file: "n_number_1.0e-.json", expectation: false)
    }

    func test_n_number_1_dot_0e() {
        parse(file: "n_number_1.0e.json", expectation: false)
    }

    func test_n_number_1_000() {
        parse(file: "n_number_1_000.json", expectation: false)
    }

    func test_n_number_1eE2() {
        parse(file: "n_number_1eE2.json", expectation: false)
    }

    func test_n_number_2_dot_e_plus_3() {
        parse(file: "n_number_2.e+3.json", expectation: false)
    }

    func test_n_number_2_dot_e_minus_3() {
        parse(file: "n_number_2.e-3.json", expectation: false)
    }

    func test_n_number_2_dot_e3() {
        parse(file: "n_number_2.e3.json", expectation: false)
    }

    func test_n_number_9_dot_e_plus() {
        parse(file: "n_number_9.e+.json", expectation: false)
    }

    func test_n_number_Inf() {
        parse(file: "n_number_Inf.json", expectation: false)
    }

    func test_n_number_NaN() {
        parse(file: "n_number_NaN.json", expectation: false)
    }

    func test_n_number_UFF11_fullwidth_digit_one() {
        parse(file: "n_number_U+FF11_fullwidth_digit_one.json", expectation: false)
    }

    func test_n_number_expression() {
        parse(file: "n_number_expression.json", expectation: false)
    }

    func test_n_number_hex_1_digit() {
        parse(file: "n_number_hex_1_digit.json", expectation: false)
    }

    func test_n_number_hex_2_digits() {
        parse(file: "n_number_hex_2_digits.json", expectation: false)
    }

    func test_n_number_infinity() {
        parse(file: "n_number_infinity.json", expectation: false)
    }

    func test_n_number_invalid_plus_minus() {
        parse(file: "n_number_invalid+-.json", expectation: false)
    }

    func test_n_number_invalid_negative_real() {
        parse(file: "n_number_invalid-negative-real.json", expectation: false)
    }

    func test_n_number_invalid_utf_8_in_bigger_int() {
        parse(file: "n_number_invalid_utf_8_in_bigger-int.json", expectation: false)
    }

    func test_n_number_invalid_utf_8_in_exponent() {
        parse(file: "n_number_invalid_utf_8_in_exponent.json", expectation: false)
    }

    func test_n_number_invalid_utf_8_in_int() {
        parse(file: "n_number_invalid_utf_8_in_int.json", expectation: false)
    }

    func test_n_number_minus_infinity() {
        parse(file: "n_number_minus_infinity.json", expectation: false)
    }

    func test_n_number_minus_sign_with_trailing_garbage() {
        parse(file: "n_number_minus_sign_with_trailing_garbage.json", expectation: false)
    }

    func test_n_number_minus_space_1() {
        parse(file: "n_number_minus_space_1.json", expectation: false)
    }

    func test_n_number_neg_int_starting_with_zero() {
        parse(file: "n_number_neg_int_starting_with_zero.json", expectation: false)
    }

    func test_n_number_neg_real_without_int_part() {
        parse(file: "n_number_neg_real_without_int_part.json", expectation: false)
    }

    func test_n_number_neg_with_garbage_at_end() {
        parse(file: "n_number_neg_with_garbage_at_end.json", expectation: false)
    }

    func test_n_number_real_garbage_after_e() {
        parse(file: "n_number_real_garbage_after_e.json", expectation: false)
    }

    func test_n_number_real_with_invalid_utf8_after_e() {
        parse(file: "n_number_real_with_invalid_utf8_after_e.json", expectation: false)
    }

    func test_n_number_real_without_fractional_part() {
        parse(file: "n_number_real_without_fractional_part.json", expectation: false)
    }

    func test_n_number_starting_with_dot() {
        parse(file: "n_number_starting_with_dot.json", expectation: false)
    }

    func test_n_number_with_alpha() {
        parse(file: "n_number_with_alpha.json", expectation: false)
    }

    func test_n_number_with_alpha_char() {
        parse(file: "n_number_with_alpha_char.json", expectation: false)
    }

    func test_n_number_with_leading_zero() {
        parse(file: "n_number_with_leading_zero.json", expectation: false)
    }

    func test_n_object_bad_value() {
        parse(file: "n_object_bad_value.json", expectation: false)
    }

    func test_n_object_bracket_key() {
        parse(file: "n_object_bracket_key.json", expectation: false)
    }

    func test_n_object_comma_instead_of_colon() {
        parse(file: "n_object_comma_instead_of_colon.json", expectation: false)
    }

    func test_n_object_double_colon() {
        parse(file: "n_object_double_colon.json", expectation: false)
    }

    func test_n_object_emoji() {
        parse(file: "n_object_emoji.json", expectation: false)
    }

    func test_n_object_garbage_at_end() {
        parse(file: "n_object_garbage_at_end.json", expectation: false)
    }

    func test_n_object_key_with_single_quotes() {
        parse(file: "n_object_key_with_single_quotes.json", expectation: false)
    }

    func test_n_object_missing_colon() {
        parse(file: "n_object_missing_colon.json", expectation: false)
    }

    func test_n_object_missing_key() {
        parse(file: "n_object_missing_key.json", expectation: false)
    }

    func test_n_object_missing_semicolon() {
        parse(file: "n_object_missing_semicolon.json", expectation: false)
    }

    func test_n_object_missing_value() {
        parse(file: "n_object_missing_value.json", expectation: false)
    }

    func test_n_object_no_colon() {
        parse(file: "n_object_no-colon.json", expectation: false)
    }

    func test_n_object_non_string_key() {
        parse(file: "n_object_non_string_key.json", expectation: false)
    }

    func test_n_object_non_string_key_but_huge_number_instead() {
        parse(file: "n_object_non_string_key_but_huge_number_instead.json", expectation: false)
    }

    func test_n_object_pi_in_key_and_trailing_comma() {
        parse(file: "n_object_pi_in_key_and_trailing_comma.json", expectation: false)
    }

    func test_n_object_repeated_null_null() {
        parse(file: "n_object_repeated_null_null.json", expectation: false)
    }

    func test_n_object_several_trailing_commas() {
        parse(file: "n_object_several_trailing_commas.json", expectation: false)
    }

    func test_n_object_single_quote() {
        parse(file: "n_object_single_quote.json", expectation: false)
    }

    func test_n_object_trailing_comma() {
        parse(file: "n_object_trailing_comma.json", expectation: false)
    }

    func test_n_object_trailing_comment() {
        parse(file: "n_object_trailing_comment.json", expectation: false)
    }

    func test_n_object_trailing_comment_open() {
        parse(file: "n_object_trailing_comment_open.json", expectation: false)
    }

    func test_n_object_trailing_comment_slash_open() {
        parse(file: "n_object_trailing_comment_slash_open.json", expectation: false)
    }

    func test_n_object_trailing_comment_slash_open_incomplete() {
        parse(file: "n_object_trailing_comment_slash_open_incomplete.json", expectation: false)
    }

    func test_n_object_two_commas_in_a_row() {
        parse(file: "n_object_two_commas_in_a_row.json", expectation: false)
    }

    func test_n_object_unquoted_key() {
        parse(file: "n_object_unquoted_key.json", expectation: false)
    }

    func test_n_object_unterminated_value() {
        parse(file: "n_object_unterminated-value.json", expectation: false)
    }

    func test_n_object_with_single_string() {
        parse(file: "n_object_with_single_string.json", expectation: false)
    }

    func test_n_object_with_trailing_garbage() {
        parse(file: "n_object_with_trailing_garbage.json", expectation: false)
    }

    func test_n_single_space() {
        parse(file: "n_single_space.json", expectation: false)
    }

    func test_n_string_1_surrogate_then_escape() {
        parse(file: "n_string_1_surrogate_then_escape.json", expectation: false)
    }

    func test_n_string_1_surrogate_then_escape_u() {
        parse(file: "n_string_1_surrogate_then_escape_u.json", expectation: false)
    }

    func test_n_string_1_surrogate_then_escape_u1() {
        parse(file: "n_string_1_surrogate_then_escape_u1.json", expectation: false)
    }

    func test_n_string_1_surrogate_then_escape_u1x() {
        parse(file: "n_string_1_surrogate_then_escape_u1x.json", expectation: false)
    }

    func test_n_string_accentuated_char_no_quotes() {
        parse(file: "n_string_accentuated_char_no_quotes.json", expectation: false)
    }

    func test_n_string_backslash_00() {
        parse(file: "n_string_backslash_00.json", expectation: false)
    }

    func test_n_string_escape_x() {
        parse(file: "n_string_escape_x.json", expectation: false)
    }

    func test_n_string_escaped_backslash_bad() {
        parse(file: "n_string_escaped_backslash_bad.json", expectation: false)
    }

    func test_n_string_escaped_ctrl_char_tab() {
        parse(file: "n_string_escaped_ctrl_char_tab.json", expectation: false)
    }

    func test_n_string_escaped_emoji() {
        parse(file: "n_string_escaped_emoji.json", expectation: false)
    }

    func test_n_string_incomplete_escape() {
        parse(file: "n_string_incomplete_escape.json", expectation: false)
    }

    func test_n_string_incomplete_escaped_character() {
        parse(file: "n_string_incomplete_escaped_character.json", expectation: false)
    }

    func test_n_string_incomplete_surrogate() {
        parse(file: "n_string_incomplete_surrogate.json", expectation: false)
    }

    func test_n_string_incomplete_surrogate_escape_invalid() {
        parse(file: "n_string_incomplete_surrogate_escape_invalid.json", expectation: false)
    }

    func test_n_string_invalid_utf_8_in_escape() {
        parse(file: "n_string_invalid_utf_8_in_escape.json", expectation: false)
    }

    func test_n_string_invalid_backslash_esc() {
        parse(file: "n_string_invalid_backslash_esc.json", expectation: false)
    }

    func test_n_string_invalid_unicode_escape() {
        parse(file: "n_string_invalid_unicode_escape.json", expectation: false)
    }

    func test_n_string_invalid_utf8_after_escape() {
        parse(file: "n_string_invalid_utf8_after_escape.json", expectation: false)
    }

    func test_n_string_leading_uescaped_thinspace() {
        parse(file: "n_string_leading_uescaped_thinspace.json", expectation: false)
    }

    func test_n_string_no_quotes_with_bad_escape() {
        parse(file: "n_string_no_quotes_with_bad_escape.json", expectation: false)
    }

    func test_n_string_single_doublequote() {
        parse(file: "n_string_single_doublequote.json", expectation: false)
    }

    func test_n_string_single_quote() {
        parse(file: "n_string_single_quote.json", expectation: false)
    }

    func test_n_string_single_string_no_double_quotes() {
        parse(file: "n_string_single_string_no_double_quotes.json", expectation: false)
    }

    func test_n_string_start_escape_unclosed() {
        parse(file: "n_string_start_escape_unclosed.json", expectation: false)
    }

    func test_n_string_unescaped_crtl_char() {
        parse(file: "n_string_unescaped_crtl_char.json", expectation: false)
    }

    func test_n_string_unescaped_newline() {
        parse(file: "n_string_unescaped_newline.json", expectation: false)
    }

    func test_n_string_unescaped_tab() {
        parse(file: "n_string_unescaped_tab.json", expectation: false)
    }

    func test_n_string_unicode_CapitalU() {
        parse(file: "n_string_unicode_CapitalU.json", expectation: false)
    }

    func test_n_string_with_trailing_garbage() {
        parse(file: "n_string_with_trailing_garbage.json", expectation: false)
    }
//
//    func test_n_structure_100000_opening_arrays() {
//        parse(file: "n_structure_100000_opening_arrays.json", expectation: false)
//    }

    func test_n_structure_U2060_word_joined() {
        parse(file: "n_structure_U+2060_word_joined.json", expectation: false)
    }

    func test_n_structure_UTF8_BOM_no_data() {
        parse(file: "n_structure_UTF8_BOM_no_data.json", expectation: false)
    }

    func test_n_structure_angle_bracket_() {
        parse(file: "n_structure_angle_bracket_..json", expectation: false)
    }

    func test_n_structure_angle_bracket_null() {
        parse(file: "n_structure_angle_bracket_null.json", expectation: false)
    }

    func test_n_structure_array_trailing_garbage() {
        parse(file: "n_structure_array_trailing_garbage.json", expectation: false)
    }

    func test_n_structure_array_with_extra_array_close() {
        parse(file: "n_structure_array_with_extra_array_close.json", expectation: false)
    }

    func test_n_structure_array_with_unclosed_string() {
        parse(file: "n_structure_array_with_unclosed_string.json", expectation: false)
    }

    func test_n_structure_ascii_unicode_identifier() {
        parse(file: "n_structure_ascii-unicode-identifier.json", expectation: false)
    }

    func test_n_structure_capitalized_True() {
        parse(file: "n_structure_capitalized_True.json", expectation: false)
    }

    func test_n_structure_close_unopened_array() {
        parse(file: "n_structure_close_unopened_array.json", expectation: false)
    }

    func test_n_structure_comma_instead_of_closing_brace() {
        parse(file: "n_structure_comma_instead_of_closing_brace.json", expectation: false)
    }

    func test_n_structure_double_array() {
        parse(file: "n_structure_double_array.json", expectation: false)
    }

    func test_n_structure_end_array() {
        parse(file: "n_structure_end_array.json", expectation: false)
    }

    func test_n_structure_incomplete_UTF8_BOM() {
        parse(file: "n_structure_incomplete_UTF8_BOM.json", expectation: false)
    }

    func test_n_structure_lone_invalid_utf_8() {
        parse(file: "n_structure_lone-invalid-utf-8.json", expectation: false)
    }

    func test_n_structure_lone_open_bracket() {
        parse(file: "n_structure_lone-open-bracket.json", expectation: false)
    }

    func test_n_structure_no_data() {
        parse(file: "n_structure_no_data.json", expectation: false)
    }

    func test_n_structure_null_byte_outside_string() {
        parse(file: "n_structure_null-byte-outside-string.json", expectation: false)
    }

    func test_n_structure_number_with_trailing_garbage() {
        parse(file: "n_structure_number_with_trailing_garbage.json", expectation: false)
    }

    func test_n_structure_object_followed_by_closing_object() {
        parse(file: "n_structure_object_followed_by_closing_object.json", expectation: false)
    }

    func test_n_structure_object_unclosed_no_value() {
        parse(file: "n_structure_object_unclosed_no_value.json", expectation: false)
    }

    func test_n_structure_object_with_comment() {
        parse(file: "n_structure_object_with_comment.json", expectation: false)
    }

    func test_n_structure_object_with_trailing_garbage() {
        parse(file: "n_structure_object_with_trailing_garbage.json", expectation: false)
    }

    func test_n_structure_open_array_apostrophe() {
        parse(file: "n_structure_open_array_apostrophe.json", expectation: false)
    }

    func test_n_structure_open_array_comma() {
        parse(file: "n_structure_open_array_comma.json", expectation: false)
    }

//    func test_n_structure_open_array_object() {
//        parse(file: "n_structure_open_array_object.json", expectation: false)
//    }
//
    func test_n_structure_open_array_open_object() {
        parse(file: "n_structure_open_array_open_object.json", expectation: false)
    }

    func test_n_structure_open_array_open_string() {
        parse(file: "n_structure_open_array_open_string.json", expectation: false)
    }

    func test_n_structure_open_array_string() {
        parse(file: "n_structure_open_array_string.json", expectation: false)
    }

    func test_n_structure_open_object() {
        parse(file: "n_structure_open_object.json", expectation: false)
    }

    func test_n_structure_open_object_close_array() {
        parse(file: "n_structure_open_object_close_array.json", expectation: false)
    }

    func test_n_structure_open_object_comma() {
        parse(file: "n_structure_open_object_comma.json", expectation: false)
    }

    func test_n_structure_open_object_open_array() {
        parse(file: "n_structure_open_object_open_array.json", expectation: false)
    }

    func test_n_structure_open_object_open_string() {
        parse(file: "n_structure_open_object_open_string.json", expectation: false)
    }

    func test_n_structure_open_object_string_with_apostrophes() {
        parse(file: "n_structure_open_object_string_with_apostrophes.json", expectation: false)
    }

    func test_n_structure_open_open() {
        parse(file: "n_structure_open_open.json", expectation: false)
    }

    func test_n_structure_single_eacute() {
        parse(file: "n_structure_single_eacute.json", expectation: false)
    }

    func test_n_structure_single_star() {
        parse(file: "n_structure_single_star.json", expectation: false)
    }

    func test_n_structure_trailing_hash() {
        parse(file: "n_structure_trailing_#.json", expectation: false)
    }

    func test_n_structure_uescaped_LF_before_string() {
        parse(file: "n_structure_uescaped_LF_before_string.json", expectation: false)
    }

    func test_n_structure_unclosed_array() {
        parse(file: "n_structure_unclosed_array.json", expectation: false)
    }

    func test_n_structure_unclosed_array_partial_null() {
        parse(file: "n_structure_unclosed_array_partial_null.json", expectation: false)
    }

    func test_n_structure_unclosed_array_unfinished_false() {
        parse(file: "n_structure_unclosed_array_unfinished_false.json", expectation: false)
    }

    func test_n_structure_unclosed_array_unfinished_true() {
        parse(file: "n_structure_unclosed_array_unfinished_true.json", expectation: false)
    }

    func test_n_structure_unclosed_object() {
        parse(file: "n_structure_unclosed_object.json", expectation: false)
    }

    func test_n_structure_unicode_identifier() {
        parse(file: "n_structure_unicode-identifier.json", expectation: false)
    }

    func test_n_structure_whitespace_U2060_word_joiner() {
        parse(file: "n_structure_whitespace_U+2060_word_joiner.json", expectation: false)
    }

    func test_n_structure_whitespace_formfeed() {
        parse(file: "n_structure_whitespace_formfeed.json", expectation: false)
    }

    func test_y_array_arraysWithSpaces() {
        parse(file: "y_array_arraysWithSpaces.json", expectation: true)
    }

    func test_y_array_empty_string() {
        parse(file: "y_array_empty-string.json", expectation: true)
    }

    func test_y_array_empty() {
        parse(file: "y_array_empty.json", expectation: true)
    }

    func test_y_array_ending_with_newline() {
        parse(file: "y_array_ending_with_newline.json", expectation: true)
    }

    func test_y_array_false() {
        parse(file: "y_array_false.json", expectation: true)
    }

    func test_y_array_heterogeneous() {
        parse(file: "y_array_heterogeneous.json", expectation: true)
    }

    func test_y_array_null() {
        parse(file: "y_array_null.json", expectation: true)
    }

    func test_y_array_with_1_and_newline() {
        parse(file: "y_array_with_1_and_newline.json", expectation: true)
    }

    func test_y_array_with_leading_space() {
        parse(file: "y_array_with_leading_space.json", expectation: true)
    }

    func test_y_array_with_several_null() {
        parse(file: "y_array_with_several_null.json", expectation: true)
    }

    func test_y_array_with_trailing_space() {
        parse(file: "y_array_with_trailing_space.json", expectation: true)
    }

    func test_y_number() {
        parse(file: "y_number.json", expectation: true)
    }

    func test_y_number_0e_plus_1() {
        parse(file: "y_number_0e+1.json", expectation: true)
    }

    func test_y_number_0e1() {
        parse(file: "y_number_0e1.json", expectation: true)
    }

    func test_y_number_after_space() {
        parse(file: "y_number_after_space.json", expectation: true)
    }

    func test_y_number_double_close_to_zero() {
        parse(file: "y_number_double_close_to_zero.json", expectation: true)
    }

    func test_y_number_int_with_exp() {
        parse(file: "y_number_int_with_exp.json", expectation: true)
    }

    func test_y_number_minus_zero() {
        parse(file: "y_number_minus_zero.json", expectation: true)
    }

    func test_y_number_negative_int() {
        parse(file: "y_number_negative_int.json", expectation: true)
    }

    func test_y_number_negative_one() {
        parse(file: "y_number_negative_one.json", expectation: true)
    }

    func test_y_number_negative_zero() {
        parse(file: "y_number_negative_zero.json", expectation: true)
    }

    func test_y_number_real_capital_e() {
        parse(file: "y_number_real_capital_e.json", expectation: true)
    }

    func test_y_number_real_capital_e_neg_exp() {
        parse(file: "y_number_real_capital_e_neg_exp.json", expectation: true)
    }

    func test_y_number_real_capital_e_pos_exp() {
        parse(file: "y_number_real_capital_e_pos_exp.json", expectation: true)
    }

    func test_y_number_real_exponent() {
        parse(file: "y_number_real_exponent.json", expectation: true)
    }

    func test_y_number_real_fraction_exponent() {
        parse(file: "y_number_real_fraction_exponent.json", expectation: true)
    }

    func test_y_number_real_neg_exp() {
        parse(file: "y_number_real_neg_exp.json", expectation: true)
    }

    func test_y_number_real_pos_exponent() {
        parse(file: "y_number_real_pos_exponent.json", expectation: true)
    }

    func test_y_number_simple_int() {
        parse(file: "y_number_simple_int.json", expectation: true)
    }

    func test_y_number_simple_real() {
        parse(file: "y_number_simple_real.json", expectation: true)
    }

    func test_y_object() {
        parse(file: "y_object.json", expectation: true)
    }

    func test_y_object_basic() {
        parse(file: "y_object_basic.json", expectation: true)
    }

    func test_y_object_duplicated_key() {
        parse(file: "y_object_duplicated_key.json", expectation: true)
    }

    func test_y_object_duplicated_key_and_value() {
        parse(file: "y_object_duplicated_key_and_value.json", expectation: true)
    }

    func test_y_object_empty() {
        parse(file: "y_object_empty.json", expectation: true)
    }

    func test_y_object_empty_key() {
        parse(file: "y_object_empty_key.json", expectation: true)
    }

    func test_y_object_escaped_null_in_key() {
        parse(file: "y_object_escaped_null_in_key.json", expectation: true)
    }

    func test_y_object_extreme_numbers() {
        parse(file: "y_object_extreme_numbers.json", expectation: true)
    }

    func test_y_object_long_strings() {
        parse(file: "y_object_long_strings.json", expectation: true)
    }

    func test_y_object_simple() {
        parse(file: "y_object_simple.json", expectation: true)
    }

    func test_y_object_string_unicode() {
        parse(file: "y_object_string_unicode.json", expectation: true)
    }

    func test_y_object_with_newlines() {
        parse(file: "y_object_with_newlines.json", expectation: true)
    }

    func test_y_string_1_2_3_bytes_UTF_8_sequences() {
        parse(file: "y_string_1_2_3_bytes_UTF-8_sequences.json", expectation: true)
    }

    func test_y_string_accepted_surrogate_pair() {
        parse(file: "y_string_accepted_surrogate_pair.json", expectation: true)
    }

    func test_y_string_accepted_surrogate_pairs() {
        parse(file: "y_string_accepted_surrogate_pairs.json", expectation: true)
    }

    func test_y_string_allowed_escapes() {
        parse(file: "y_string_allowed_escapes.json", expectation: true)
    }

    func test_y_string_backslash_and_u_escaped_zero() {
        parse(file: "y_string_backslash_and_u_escaped_zero.json", expectation: true)
    }

    func test_y_string_backslash_doublequotes() {
        parse(file: "y_string_backslash_doublequotes.json", expectation: true)
    }

    func test_y_string_comments() {
        parse(file: "y_string_comments.json", expectation: true)
    }

    func test_y_string_double_escape_a() {
        parse(file: "y_string_double_escape_a.json", expectation: true)
    }

    func test_y_string_double_escape_n() {
        parse(file: "y_string_double_escape_n.json", expectation: true)
    }

    func test_y_string_escaped_control_character() {
        parse(file: "y_string_escaped_control_character.json", expectation: true)
    }

    func test_y_string_escaped_noncharacter() {
        parse(file: "y_string_escaped_noncharacter.json", expectation: true)
    }

    func test_y_string_in_array() {
        parse(file: "y_string_in_array.json", expectation: true)
    }

    func test_y_string_in_array_with_leading_space() {
        parse(file: "y_string_in_array_with_leading_space.json", expectation: true)
    }

    func test_y_string_last_surrogates_1_and_2() {
        parse(file: "y_string_last_surrogates_1_and_2.json", expectation: true)
    }

    func test_y_string_nbsp_uescaped() {
        parse(file: "y_string_nbsp_uescaped.json", expectation: true)
    }

    func test_y_string_nonCharacterInUTF_8_U10FFFF() {
        parse(file: "y_string_nonCharacterInUTF-8_U+10FFFF.json", expectation: true)
    }

    func test_y_string_nonCharacterInUTF_8_U1FFFF() {
        parse(file: "y_string_nonCharacterInUTF-8_U+1FFFF.json", expectation: true)
    }

    func test_y_string_nonCharacterInUTF_8_UFFFF() {
        parse(file: "y_string_nonCharacterInUTF-8_U+FFFF.json", expectation: true)
    }

    func test_y_string_null_escape() {
        parse(file: "y_string_null_escape.json", expectation: true)
    }

    func test_y_string_one_byte_utf_8() {
        parse(file: "y_string_one-byte-utf-8.json", expectation: true)
    }

    func test_y_string_pi() {
        parse(file: "y_string_pi.json", expectation: true)
    }

    func test_y_string_simple_ascii() {
        parse(file: "y_string_simple_ascii.json", expectation: true)
    }

    func test_y_string_space() {
        parse(file: "y_string_space.json", expectation: true)
    }

    func test_y_string_surrogates_U1D11E_MUSICAL_SYMBOL_G_CLEF() {
        parse(file: "y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF.json", expectation: true)
    }

    func test_y_string_three_byte_utf_8() {
        parse(file: "y_string_three-byte-utf-8.json", expectation: true)
    }

    func test_y_string_two_byte_utf_8() {
        parse(file: "y_string_two-byte-utf-8.json", expectation: true)
    }

    func test_y_string_u2028_line_sep() {
        parse(file: "y_string_u+2028_line_sep.json", expectation: true)
    }

    func test_y_string_u2029_par_sep() {
        parse(file: "y_string_u+2029_par_sep.json", expectation: true)
    }

    func test_y_string_uEscape() {
        parse(file: "y_string_uEscape.json", expectation: true)
    }

    func test_y_string_uescaped_newline() {
        parse(file: "y_string_uescaped_newline.json", expectation: true)
    }

    func test_y_string_unescaped_char_delete() {
        parse(file: "y_string_unescaped_char_delete.json", expectation: true)
    }

    func test_y_string_unicode() {
        parse(file: "y_string_unicode.json", expectation: true)
    }

    func test_y_string_unicodeEscapedBackslash() {
        parse(file: "y_string_unicodeEscapedBackslash.json", expectation: true)
    }

    func test_y_string_unicode_2() {
        parse(file: "y_string_unicode_2.json", expectation: true)
    }

    func test_y_string_unicode_U10FFFE_nonchar() {
        parse(file: "y_string_unicode_U+10FFFE_nonchar.json", expectation: true)
    }

    func test_y_string_unicode_U1FFFE_nonchar() {
        parse(file: "y_string_unicode_U+1FFFE_nonchar.json", expectation: true)
    }

    func test_y_string_unicode_U200B_ZERO_WIDTH_SPACE() {
        parse(file: "y_string_unicode_U+200B_ZERO_WIDTH_SPACE.json", expectation: true)
    }

    func test_y_string_unicode_U2064_invisible_plus() {
        parse(file: "y_string_unicode_U+2064_invisible_plus.json", expectation: true)
    }

    func test_y_string_unicode_UFDD0_nonchar() {
        parse(file: "y_string_unicode_U+FDD0_nonchar.json", expectation: true)
    }

    func test_y_string_unicode_UFFFE_nonchar() {
        parse(file: "y_string_unicode_U+FFFE_nonchar.json", expectation: true)
    }

    func test_y_string_unicode_escaped_double_quote() {
        parse(file: "y_string_unicode_escaped_double_quote.json", expectation: true)
    }

    func test_y_string_utf8() {
        parse(file: "y_string_utf8.json", expectation: true)
    }

    func test_y_string_with_del_character() {
        parse(file: "y_string_with_del_character.json", expectation: true)
    }

    func test_y_structure_lonely_false() {
        parse(file: "y_structure_lonely_false.json", expectation: true)
    }

    func test_y_structure_lonely_int() {
        parse(file: "y_structure_lonely_int.json", expectation: true)
    }

    func test_y_structure_lonely_negative_real() {
        parse(file: "y_structure_lonely_negative_real.json", expectation: true)
    }

    func test_y_structure_lonely_null() {
        parse(file: "y_structure_lonely_null.json", expectation: true)
    }

    func test_y_structure_lonely_string() {
        parse(file: "y_structure_lonely_string.json", expectation: true)
    }

    func test_y_structure_lonely_true() {
        parse(file: "y_structure_lonely_true.json", expectation: true)
    }

    func test_y_structure_string_empty() {
        parse(file: "y_structure_string_empty.json", expectation: true)
    }

    func test_y_structure_trailing_newline() {
        parse(file: "y_structure_trailing_newline.json", expectation: true)
    }

    func test_y_structure_true_in_array() {
        parse(file: "y_structure_true_in_array.json", expectation: true)
    }

    func test_y_structure_whitespace_array() {
        parse(file: "y_structure_whitespace_array.json", expectation: true)
    }

#endif

}
