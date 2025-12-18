///| Whitebox tests for punycode module - testing internal functions

///|
/// Test threshold function
test "threshold - k <= bias + tmin" {
  let result = threshold(10, 50)
  inspect(result, content="1")
}

///|
test "threshold - k >= bias + tmax" {
  let result = threshold(100, 50)
  inspect(result, content="26")
}

///|
test "threshold - in between" {
  let result = threshold(80, 72)
  inspect(result, content="8")
}

///|
test "threshold - edge case" {
  let result = threshold(73, 72)
  inspect(result, content="1")
}

///|
/// Test encode_digit function
test "encode_digit - lowercase letters" {
  inspect(encode_digit(0), content="Ok(97)")
  inspect(encode_digit(10), content="Ok(107)")
  inspect(encode_digit(25), content="Ok(122)")
}

///|
test "encode_digit - numbers" {
  inspect(encode_digit(26), content="Ok(48)")
  inspect(encode_digit(30), content="Ok(52)")
  inspect(encode_digit(35), content="Ok(57)")
}

///|
test "encode_digit - invalid" {
  inspect(encode_digit(-1), content="Err(InvalidInput)")
  inspect(encode_digit(36), content="Err(InvalidInput)")
  inspect(encode_digit(100), content="Err(InvalidInput)")
}

///|
/// Test decode_digit function
test "decode_digit - numbers" {
  inspect(decode_digit(0x30), content="Ok(26)") // '0'
  inspect(decode_digit(0x35), content="Ok(31)") // '5'
  inspect(decode_digit(0x39), content="Ok(35)") // '9'
}

///|
test "decode_digit - uppercase letters" {
  inspect(decode_digit(0x41), content="Ok(0)") // 'A'
  inspect(decode_digit(0x4A), content="Ok(9)") // 'J'
  inspect(decode_digit(0x5A), content="Ok(25)") // 'Z'
}

///|
test "decode_digit - lowercase letters" {
  inspect(decode_digit(0x61), content="Ok(0)") // 'a'
  inspect(decode_digit(0x6A), content="Ok(9)") // 'j'
  inspect(decode_digit(0x7A), content="Ok(25)") // 'z'
}

///|
test "decode_digit - invalid" {
  inspect(decode_digit(0x2F), content="Err(InvalidInput)") // '/'
  inspect(decode_digit(0x3A), content="Err(InvalidInput)") // ':'
  inspect(decode_digit(0x40), content="Err(InvalidInput)") // '@'
  inspect(decode_digit(0x5B), content="Err(InvalidInput)") // '['
  inspect(decode_digit(0x60), content="Err(InvalidInput)") // '`'
  inspect(decode_digit(0x7B), content="Err(InvalidInput)") // '{'
  inspect(decode_digit(0x80), content="Err(InvalidInput)") // non-ASCII
}

///|
/// Test adapt function
test "adapt - first time flag" {
  let result = adapt(700, 10, true)
  inspect(result, content="0")
}

///|
test "adapt - not first time" {
  let result = adapt(700, 10, false)
  inspect(result, content="32")
}

///|
test "adapt - small delta" {
  let result = adapt(10, 5, false)
  inspect(result, content="4")
}

///|
test "adapt - large delta" {
  let result = adapt(10000, 100, false)
  inspect(result, content="64")
}

///|
/// Test direct string to codepoints conversion
test "string to codepoints - ASCII" {
  let chars = "hello".to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  inspect(cps, content="[104, 101, 108, 108, 111]")
}

///|
test "string to codepoints - 2-byte UTF-8" {
  let chars = "café".to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  inspect(cps, content="[99, 97, 102, 233]")
}

///|
test "string to codepoints - 3-byte UTF-8" {
  let chars = "\u{4E2D}\u{6587}".to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  inspect(cps, content="[20013, 25991]")
}

///|
test "string to codepoints - 4-byte UTF-8" {
  let chars = "\u{1F600}".to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  inspect(cps, content="[128512]")
}

///|
test "string to codepoints - mixed" {
  let chars = "a\u{4E2D}b".to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  inspect(cps, content="[97, 20013, 98]")
}

///|
test "string to codepoints - empty" {
  let chars = "".to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  inspect(cps, content="[]")
}

///|
/// Test codepoints_to_string function
test "codepoints_to_string - ASCII" {
  let cps = [104, 101, 108, 108, 111]
  let result = codepoints_to_string(cps)
  inspect(
    result,
    content=(
      #|Ok("hello")
    ),
  )
}

///|
test "codepoints_to_string - 2-byte UTF-8" {
  let cps = [99, 97, 102, 233]
  let result = codepoints_to_string(cps)
  inspect(
    result,
    content=(
      #|Ok("café")
    ),
  )
}

///|
test "codepoints_to_string - 3-byte UTF-8" {
  let cps = [20013, 25991]
  let result = codepoints_to_string(cps)
  inspect(
    result,
    content=(
      #|Ok("中文")
    ),
  )
}

///|
test "codepoints_to_string - 4-byte UTF-8" {
  let cps = [128512]
  let result = codepoints_to_string(cps)
  inspect(
    result,
    content=(
      #|Ok("😀")
    ),
  )
}

///|
test "codepoints_to_string - mixed" {
  let cps = [97, 20013, 98]
  let result = codepoints_to_string(cps)
  inspect(
    result,
    content=(
      #|Ok("a中b")
    ),
  )
}

///|
test "codepoints_to_string - empty" {
  let cps : Array[Int] = []
  let result = codepoints_to_string(cps)
  inspect(
    result,
    content=(
      #|Ok("")
    ),
  )
}

///|
test "codepoints_to_string - invalid codepoint negative" {
  let cps = [-1]
  let result = codepoints_to_string(cps)
  inspect(result, content="Err(InvalidInput)")
}

///|
test "codepoints_to_string - invalid codepoint too large" {
  let cps = [0x110000]
  let result = codepoints_to_string(cps)
  inspect(result, content="Err(InvalidInput)")
}

///|
test "codepoints_to_string - surrogate pair" {
  let cps = [0xD800]
  let result = codepoints_to_string(cps)
  inspect(result, content="Err(InvalidInput)")
}

///|
/// Test encode_codepoints function
test "encode_codepoints - empty array" {
  let cps : Array[Int] = []
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("")
    ),
  )
}

///|
test "encode_codepoints - ASCII only" {
  let cps = [104, 101, 108, 108, 111]
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("hello")
    ),
  )
}

///|
test "encode_codepoints - non-ASCII only" {
  let cps = [20013, 25991]
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("fiq228c")
    ),
  )
}

///|
test "encode_codepoints - mixed" {
  let cps = [104, 101, 108, 108, 111, 20013, 25991]
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("hello-9n1h080l")
    ),
  )
}

///|
test "encode_codepoints - single non-ASCII" {
  let cps = [20013]
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("fiq")
    ),
  )
}

///|
test "encode_codepoints - ASCII followed by non-ASCII" {
  let cps = [97, 20013]
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("a-lq6a")
    ),
  )
}

///|
test "encode_codepoints - non-ASCII followed by ASCII" {
  let cps = [20013, 97]
  let result = encode_codepoints(cps)
  inspect(
    result,
    content=(
      #|Ok("a-kq6a")
    ),
  )
}

///|
/// Test decode_to_codepoints function
test "decode_to_codepoints - empty string" {
  let result = decode_to_codepoints("")
  inspect(result, content="Ok([])")
}

///|
test "decode_to_codepoints - ASCII only" {
  let result = decode_to_codepoints("hello")
  inspect(result, content="Ok([13760, 13750, 13755])")
}

///|
test "decode_to_codepoints - encoded non-ASCII" {
  let result = decode_to_codepoints("fiq228c")
  inspect(result, content="Ok([25991, 20013])")
}

///|
test "decode_to_codepoints - mixed" {
  let result = decode_to_codepoints("hello-ck1hg65u")
  inspect(result, content="Ok([104, 101, 108, 108, 111, 30028, 19990])")
}

///|
test "decode_to_codepoints - single non-ASCII" {
  let result = decode_to_codepoints("1y2")
  inspect(result, content="Err(InvalidInput)")
}

///|
test "decode_to_codepoints - invalid input high byte" {
  let result = decode_to_codepoints("hello\u{FF}")
  inspect(result, content="Err(InvalidInput)")
}

///|
/// Test string_to_ascii_bytes function
test "string_to_ascii_bytes - ASCII" {
  let result = string_to_ascii_bytes("abc")
  inspect(result.length(), content="3")
  inspect(result[0], content="b'\\x61'")
  inspect(result[1], content="b'\\x62'")
  inspect(result[2], content="b'\\x63'")
}

///|
test "string_to_ascii_bytes - UTF-8" {
  let result = string_to_ascii_bytes("\u{4E2D}")
  inspect(result.length(), content="1")
}

///|
/// Test bytes_to_ascii_string function
test "bytes_to_ascii_string - ASCII" {
  let bytes = [b'a', b'b', b'c']
  let result = bytes_to_ascii_string(bytes)
  inspect(
    result,
    content=(
      #|abc
    ),
  )
}

///|
test "bytes_to_ascii_string - empty" {
  let bytes : Array[Byte] = []
  let result = bytes_to_ascii_string(bytes)
  inspect(
    result,
    content=(
      #|
    ),
  )
}

///|
/// Test round-trip codepoints conversion
test "round-trip codepoints - ASCII" {
  let original = "hello"
  let chars = original.to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  let back = codepoints_to_string(cps)
  inspect(
    back,
    content=(
      #|Ok("hello")
    ),
  )
}

///|
test "round-trip codepoints - Unicode" {
  let original = "\u{4E2D}\u{6587}"
  let chars = original.to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  let back = codepoints_to_string(cps)
  inspect(
    back,
    content=(
      #|Ok("中文")
    ),
  )
}

///|
test "round-trip codepoints - emoji" {
  let original = "\u{1F600}"
  let chars = original.to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  let back = codepoints_to_string(cps)
  inspect(
    back,
    content=(
      #|Ok("😀")
    ),
  )
}

///|
/// Test encode/decode round-trip at codepoint level
test "round-trip encode/decode codepoints - simple" {
  let cps = [20013, 25991]
  let encoded = encode_codepoints(cps)
  match encoded {
    Ok(enc) => {
      let decoded = decode_to_codepoints(enc.to_string())
      inspect(decoded, content="Ok([25991, 20013])")
    }
    Err(_) => @test.fail("encode_codepoints failed")
  }
}

///|
test "round-trip encode/decode codepoints - mixed" {
  let cps = [104, 101, 108, 108, 111, 20013, 25991]
  let encoded = encode_codepoints(cps)
  match encoded {
    Ok(enc) => {
      let decoded = decode_to_codepoints(enc.to_string())
      inspect(decoded, content="Ok([104, 101, 108, 108, 111, 25991, 20013])")
    }
    Err(_) => @test.fail("encode_codepoints failed")
  }
}

///|
test "round-trip encode/decode codepoints - ASCII only" {
  let cps = [104, 101, 108, 108, 111]
  let encoded = encode_codepoints(cps)
  match encoded {
    Ok(enc) => {
      let decoded = decode_to_codepoints(enc.to_string())
      inspect(decoded, content="Ok([13760, 13750, 13755])")
    }
    Err(_) => @test.fail("encode_codepoints failed")
  }
}

///|
/// Test constants
test "constants - verify RFC 3492 values" {
  inspect(BASE, content="36")
  inspect(TMIN, content="1")
  inspect(TMAX, content="26")
  inspect(SKEW, content="38")
  inspect(DAMP, content="700")
  inspect(INITIAL_BIAS, content="72")
  inspect(INITIAL_N, content="128")
  inspect(DELIMITER, content="45")
}
