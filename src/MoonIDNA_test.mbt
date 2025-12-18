// --- 基础用例：纯 ASCII 域名应该原样通过 ---

///|
test "idna: ascii passthrough" {
  let input = "example.com"
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(input)
  assert_eq(out_ascii, "example.com")
  assert_eq(out_unicode, "example.com")
}

// --- 非 ASCII 域名：应被 punycode 到 ASCII，并能正确回转 ---

///|
test "idna: non-ascii punycode roundtrip" {
  let input = "bücher.example"
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(out_ascii)

  // bücher -> xn--bcher-kva
  assert_eq(out_ascii, "xn--bcher-kva.example")
  assert_eq(out_unicode, input.to_string())
}

// --- Punycode 基本测试 ---

///|
test "punycode: encode buecher" {
  let s = "bücher"
  let enc = try @punycode.encode(s) catch {
    _ => {
      let a = true
      assert_eq(a, false)
      "".to_string()
    }
  } noraise {
    v => v
  }
  // RFC 3492 / 各种资料中的标准结果：bücher -> bcher-kva
  assert_eq(enc, "bcher-kva")
}

///|
test "punycode: decode bcher-kva" {
  let enc = "bcher-kva"
  let dec = try @punycode.decode(enc) catch {
    _ => {
      let a = true
      assert_eq(a, false)
      "".to_string()
    }
  } noraise {
    v => v
  }
  assert_eq(dec, "bücher")
}

///|
test "idna: ascii case fold" {
  let input = "EXAMPLE.Com"
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(input)
  assert_eq(out_ascii, "example.com")
  assert_eq(out_unicode, "example.com")
}

///|
test "idna: transitional sharp s mapping" {
  let input = "Straße.de"
  let out_default = to_ascii(input)
  let out_tr = to_ascii(input, transitional_processing=true)

  // 默认模式：含非 ASCII，走 punycode
  assert_eq(out_default, "xn--strae-oqa.de")

  // transitional 模式：ß 被映射为 ss，不再 punycode
  assert_eq(out_tr, "strasse.de")
}

///|
test "idna: ignore invalid punycode" {
  // payload = "abc_"，下划线不是 punycode 允许的字符，会触发 decode 失败
  let input = "xn--abc_"
  let strict_res = to_unicode(input)
  // 严格模式：解析失败，记录错误，但输出按我们当前实现仍保持原 label
  assert_eq(strict_res, input.to_string())
  let ignore_res = to_unicode(input, ignore_invalid_punycode=true)
  // 忽略模式：同样返回原字符串，只是不会记录 InvalidPunycode
  assert_eq(ignore_res, input.to_string())
}

///|
test "idna: top-level api basic" {
  let ascii = to_ascii("bücher.example")
  let uni = to_unicode("xn--bcher-kva.example")
  assert_eq(ascii, "xn--bcher-kva.example")
  assert_eq(uni, "bücher.example")
}

///|
test "idna: ascii trailing dot preserved" {
  let input = "example.com."
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(out_ascii)
  assert_eq(out_ascii, "example.com.")
  assert_eq(out_unicode, "example.com.")
}

///|
test "idna: non-ascii trailing dot preserved" {
  let input = "bücher.example."
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(out_ascii)
  assert_eq(out_ascii, "xn--bcher-kva.example.")
  assert_eq(out_unicode, "bücher.example.")
}

///|
test "idna: leading dot preserved ascii" {
  let input = ".example.com"
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(out_ascii)
  assert_eq(out_ascii, ".example.com")
  assert_eq(out_unicode, ".example.com")
}

///|
test "idna: leading dot preserved idn" {
  let input = ".bücher.example"
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(out_ascii)
  assert_eq(out_ascii, ".xn--bcher-kva.example")
  assert_eq(out_unicode, ".bücher.example")
}

///|
test "idna: mixed labels roundtrip" {
  let input = "www.bücher.example"
  let out_ascii = to_ascii(input)
  let out_unicode = to_unicode(out_ascii)
  assert_eq(out_unicode, input.to_string())
}

///|
test "idna: punycode prefix case-insensitive" {
  let lower = to_unicode("xn--bcher-kva.example")
  let upper = to_unicode("XN--BCHER-KVA.EXAMPLE")
  assert_eq(lower, "bücher.example")
  // ASCII 部分会被统一小写，punycode 前缀大小写不敏感
  assert_eq(upper, "bücher.example")
}

///|
test "punycode: encode ascii-only label unchanged" {
  let s = "example"
  let enc = try @punycode.encode(s) catch {
    _ => {
      let a = true
      assert_eq(a, false)
      "".to_string()
    }
  } noraise {
    v => v
  }
  assert_eq(enc, "example")
}

///|
test "punycode: encode empty label" {
  let s = ""
  let enc = try @punycode.encode(s) catch {
    _ => {
      let a = true
      assert_eq(a, false)
      "".to_string()
    }
  } noraise {
    v => v
  }
  assert_eq(enc, "")
}

///|
test "punycode: decode empty label" {
  let enc = ""
  let dec = try @punycode.decode(enc) catch {
    _ => {
      let a = true
      assert_eq(a, false)
      "".to_string()
    }
  } noraise {
    v => v
  }
  assert_eq(dec, "")
}
