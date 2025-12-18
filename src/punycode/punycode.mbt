// --- Punycode 常量（RFC 3492） ---

///|
const BASE : Int = 36

///|
const TMIN : Int = 1

///|
const TMAX : Int = 26

///|
const SKEW : Int = 38

///|
const DAMP : Int = 700

///|
const INITIAL_BIAS : Int = 72

///|
const INITIAL_N : Int = 0x80 // 128

///|
const DELIMITER : Int = 0x2D // '-'

///|
const INT_MAX : Int = 0x7fffffff // 简单的整型上界，用于溢出保护

// === 对外 API ===
// 把一个 Unicode label 编成 punycode label（不加 xn-- 前缀）

///|
pub fn encode(label : StringView) -> Result[String, PunycodeError] {
  // Convert string directly to codepoints using to_array()
  let chars = label.to_string().to_array()
  let cps = chars.map(fn(c) { c.to_int() })
  let res = encode_codepoints(cps)
  res
}
// 把一个 punycode label 解码成 Unicode label（不处理 xn-- 前缀）

///|
pub fn decode(label : StringView) -> Result[String, PunycodeError] {
  let res = match decode_to_codepoints(label) {
    Ok(v) => v
    Err(e) => return Err(e)
  }
  let s = codepoints_to_string(res)
  s
}

// === 核心：编码 / 解码算法 ===
// 内部使用：编码 code point 数组为 punycode 字符串

///|
fn encode_codepoints(cps : Array[Int]) -> Result[String, PunycodeError] {
  let input_len = cps.length()
  if input_len == 0 {
    return Ok("".to_string())
  }
  let out_bytes : Array[Byte] = []
  let mut b : Int = 0
  let mut i = 0
  while i < input_len {
    let cp = cps[i]
    if cp < 0x80 {
      out_bytes.push(cp.to_byte())
      b += 1
    }
    i += 1
  }
  let mut h = b
  if b > 0 && b < input_len {
    out_bytes.push(DELIMITER.to_byte())
  }
  let mut n : Int = INITIAL_N
  let mut delta : Int = 0
  let mut bias : Int = INITIAL_BIAS
  while h < input_len {
    let mut m : Int = INT_MAX
    let mut j = 0
    while j < input_len {
      let cp = cps[j]
      if cp >= n && cp < m {
        m = cp
      }
      j += 1
    }
    if m == INT_MAX {
      return Err(PunycodeError::InvalidInput)
    }
    if m - n > (INT_MAX - delta) / (h + 1) {
      return Err(PunycodeError::Overflow)
    }
    delta += (m - n) * (h + 1)
    n = m
    j = 0
    while j < input_len {
      let cp = cps[j]
      if cp < n {
        delta += 1
        if delta < 0 {
          return Err(PunycodeError::Overflow)
        }
      } else if cp == n {
        let mut q = delta
        let mut k = BASE
        while true {
          let t = threshold(k, bias)
          if q < t {
            break
          }
          let code = t + (q - t) % (BASE - t)
          let bch = match encode_digit(code) {
            Ok(v) => v
            Err(e) => return Err(e)
          }
          out_bytes.push(bch.to_byte())
          q = (q - t) / (BASE - t)
          k += BASE
        }
        let last = match encode_digit(q) {
          Ok(v) => v
          Err(e) => return Err(e)
        }
        out_bytes.push(last.to_byte())
        bias = adapt(delta, h + 1, h == b)
        delta = 0
        h += 1
      }
      j += 1
    }
    delta += 1
    n += 1
  }
  Ok(bytes_to_ascii_string(out_bytes))
}

// 内部使用：从 punycode 字符串解码成 code point 数组

///|
fn decode_to_codepoints(
  label : StringView,
) -> Result[Array[Int], PunycodeError] {
  let bytes = string_to_ascii_bytes(label)
  let out : Array[Int] = []
  let mut n : Int = INITIAL_N
  let mut i : Int = 0
  let mut bias : Int = INITIAL_BIAS

  // 处理 basic 部分（直到最后一个 '-'）
  let mut last_delim : Int = -1
  let mut idx = 0
  while idx < bytes.length() {
    if bytes[idx].to_int() == DELIMITER {
      last_delim = idx
    }
    idx += 1
  }
  idx = 0
  if last_delim != -1 {
    while idx < last_delim {
      let bch = bytes[idx].to_int()
      if bch >= 0x80 {
        return Err(PunycodeError::InvalidInput)
      }
      out.push(bch)
      idx += 1
    }
    idx = last_delim + 1
  }
  while idx < bytes.length() {
    let oldi = i
    let mut w : Int = 1
    let mut k : Int = BASE
    while true {
      if idx >= bytes.length() {
        return Err(PunycodeError::InvalidInput)
      }
      let digit = match decode_digit(bytes[idx].to_int()) {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      idx += 1
      if digit > (INT_MAX - i) / w {
        return Err(PunycodeError::Overflow)
      }
      i += digit * w
      let t = threshold(k, bias)
      if digit < t {
        break
      }
      if w > INT_MAX / (BASE - t) {
        return Err(PunycodeError::Overflow)
      }
      w *= BASE - t
      k += BASE
    }
    let out_len = out.length() + 1
    bias = adapt(i - oldi, out_len, oldi == 0)
    let q = i / out_len
    if n + q > 0x10FFFF {
      return Err(PunycodeError::Overflow)
    }
    n += q
    let pos = i % out_len
    out.insert(pos, n)
    i = pos
  }
  Ok(out)
}

// === Bootstring 辅助函数 ===

///|
fn threshold(k : Int, bias : Int) -> Int {
  if k <= bias + TMIN {
    TMIN
  } else if k >= bias + TMAX {
    TMAX
  } else {
    k - bias
  }
}

///|
fn adapt(delta : Int, numpoints : Int, first_time : Bool) -> Int {
  // 简化版：不做额外溢出检查，按 RFC 3492 公式实现
  let mut d = delta
  if first_time {
    d = d / DAMP
  } else {
    d = d / 2
  }
  d = d + d / numpoints
  let mut k : Int = 0
  while d > (BASE - TMIN) * TMAX / 2 {
    d = d / (BASE - TMIN)
    k += BASE
  }
  k + (BASE - TMIN + 1) * d / (d + SKEW)
}

///|
fn encode_digit(d : Int) -> Result[Int, PunycodeError] {
  if d >= 0 && d < 26 {
    Ok(0x61 + d) // 'a'..'z'
  } else if d >= 26 && d < 36 {
    Ok(0x30 + (d - 26)) // '0'..'9'
  } else {
    Err(PunycodeError::InvalidInput)
  }
}

///|
fn decode_digit(c : Int) -> Result[Int, PunycodeError] {
  if c >= 0x30 && c <= 0x39 {
    Ok(c - 0x30 + 26) // '0'..'9'
  } else if c >= 0x41 && c <= 0x5A {
    Ok(c - 0x41) // 'A'..'Z'
  } else if c >= 0x61 && c <= 0x7A {
    Ok(c - 0x61) // 'a'..'z'
  } else {
    Err(PunycodeError::InvalidInput)
  }
}

// === String 与 code point 转换 ===
// 直接使用 String::to_array() 和 Char::from_int() 避免 UTF-8 roundtrip

///|
fn codepoints_to_string(cps : Array[Int]) -> Result[String, PunycodeError] {
  let chars : Array[Char] = []
  let mut i = 0
  while i < cps.length() {
    let cp = cps[i]
    if cp < 0 || cp > 0x10FFFF {
      return Err(PunycodeError::InvalidInput)
    }
    if cp >= 0xD800 && cp <= 0xDFFF {
      return Err(PunycodeError::InvalidInput)
    }
    chars.push(cp.unsafe_to_char())
    i += 1
  }
  Ok(String::from_array(chars))
}

// 把 ASCII 字符串直接转为 bytes

///|
fn string_to_ascii_bytes(s : StringView) -> Array[Byte] {
  let chars = s.to_string().to_array()
  chars.map(fn(c) { c.to_int().to_byte() })
}

// bytes -> ASCII String（假设是合法 ASCII）

///|
fn bytes_to_ascii_string(bs : Array[Byte]) -> String {
  let chars = bs.map(fn(b) { b.to_int().unsafe_to_char() })
  String::from_array(chars)
}
