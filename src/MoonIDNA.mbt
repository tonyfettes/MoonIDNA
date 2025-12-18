///|
pub fn to_ascii(
  domain : StringView,
  check_hyphens? : Bool = true,
  check_bidi? : Bool = true,
  check_joiners? : Bool = true,
  use_std3_ascii_rules? : Bool = false,
  transitional_processing? : Bool = false,
  verify_dns_length? : Bool = true,
  ignore_invalid_punycode? : Bool = false,
) -> String raise {
  match
    to_ascii_core(
      domain,
      check_hyphens~,
      check_bidi~,
      check_joiners~,
      use_std3_ascii_rules~,
      transitional_processing~,
      verify_dns_length~,
      ignore_invalid_punycode~,
    ) {
    Ok(s) => s
    Err(_) =>
      // UTS #46 ToASCII 允许实现选择抛错或返回原字符串；
      domain.to_string()
  }
}

///|
pub fn to_unicode(
  domain : StringView,
  check_hyphens? : Bool = true,
  check_bidi? : Bool = true,
  check_joiners? : Bool = true,
  use_std3_ascii_rules? : Bool = false,
  transitional_processing? : Bool = false,
  verify_dns_length? : Bool = true,
  ignore_invalid_punycode? : Bool = false,
) -> String raise @buf.Utf8DecodeError {
  match
    to_unicode_core(
      domain,
      check_hyphens~,
      check_bidi~,
      check_joiners~,
      use_std3_ascii_rules~,
      transitional_processing~,
      verify_dns_length~,
      ignore_invalid_punycode~,
    ) {
    Ok(s) => s
    Err(_) =>
      // ToUnicode 保证总是返回字符串，出错时原样返回比较安全
      domain.to_string()
  }
}
