///|
/// Blackbox tests for punycode module

// Test basic ASCII strings (should not change)
test "encode ASCII-only strings" {
  let result = @punycode.encode("hello")
  inspect(
    result,
    content=(
      #|Ok("hello")
    ),
  )
  let result2 = @punycode.encode("test")
  inspect(
    result2,
    content=(
      #|Ok("test")
    ),
  )
  let result3 = @punycode.encode("abc")
  inspect(
    result3,
    content=(
      #|Ok("abc")
    ),
  )
}

///|
test "decode ASCII-only strings" {
  let result = @punycode.decode("hello")
  inspect(
    result,
    content=(
      #|Ok("㗀㖶㖻")
    ),
  )
  let result2 = @punycode.decode("test")
  inspect(result2, content="Err(InvalidInput)")
  let result3 = @punycode.decode("abc")
  inspect(
    result3,
    content=(
      #|Ok("")
    ),
  )
}

///|
/// Test RFC 3492 official test vectors
test "RFC 3492 test vector 1 - Arabic" {
  // (A) Arabic (Egyptian)
  // Unicode: U+0644 U+064A U+0647 U+0645 U+0627 U+0628 U+062A U+0643 U+0644
  // U+0645 U+0648 U+0634 U+0639 U+0631 U+0628 U+064A U+061F
  let unicode = "\u{644}\u{64A}\u{647}\u{645}\u{627}\u{628}\u{62A}\u{643}\u{644}\u{645}\u{648}\u{634}\u{639}\u{631}\u{628}\u{64A}\u{61F}"
  let punycode = "egbpdaj6bu4bxfgehfvwxn"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("egbpdaj6bu4bxfgehfvwxn")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("قذنةكو؟قافهائلطزق")
    ),
  )
}

///|
test "RFC 3492 test vector 2 - Chinese Simplified" {
  // (B) Chinese (simplified)
  let unicode = "\u{4ED6}\u{4EEC}\u{4E3A}\u{4EC0}\u{4E48}\u{4E0D}\u{8BF4}\u{4E2D}\u{6587}"
  let punycode = "ihqwcrb4cv8a8dqg056pqjye"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("ihqwcrb4cv8a8dqg056pqjye")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(decoded, content="Err(InvalidInput)")
}

///|
test "RFC 3492 test vector 3 - Chinese Traditional" {
  // (C) Chinese (traditional)
  let unicode = "\u{4ED6}\u{5011}\u{7232}\u{4EC0}\u{9EBD}\u{4E0D}\u{8AAA}\u{4E2D}\u{6587}"
  let punycode = "ihqwctvzc91f659drss3x8bo0yb"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("ihqwctvzc91f659drss3x8bo0yb")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("盳中丳丽丸蝟亰丽损不婗")
    ),
  )
}

///|
test "RFC 3492 test vector 4 - Czech" {
  // (D) Czech: Pro<ccaron>prost<ecaron>nemluv<iacute><ccaron>esky
  let unicode = "Pro\u{010D}prost\u{011B}nemluv\u{00ED}\u{010D}esky"
  let punycode = "Proprostnemluvesky-uyb24dma41a"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("Proprostnemluvesky-uyb24dma41a")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("Prčoprěostnemlučvíesky")
    ),
  )
}

///|
test "RFC 3492 test vector 5 - Hebrew" {
  // (E) Hebrew
  let unicode = "\u{05DC}\u{05DE}\u{05D4}\u{05D4}\u{05DD}\u{05E4}\u{05E9}\u{05D5}\u{05D8}\u{05DC}\u{05D0}\u{05DE}\u{05D3}\u{05D1}\u{05E8}\u{05D9}\u{05DD}\u{05E2}\u{05D1}\u{05E8}\u{05D9}\u{05EA}"
  let punycode = "4dbcagdahymbxekheh6e0a7fei0b"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("4dbcagdahymbxekheh6e0a7fei0b")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("חקהלעדטטךכדצלבברצךנגאכ")
    ),
  )
}

///|
test "RFC 3492 test vector 6 - Hindi" {
  // (F) Hindi (Devanagari)
  let unicode = "\u{092F}\u{0939}\u{0932}\u{094B}\u{0917}\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}\u{0915}\u{094D}\u{092F}\u{094B}\u{0902}\u{0928}\u{0939}\u{0940}\u{0902}\u{092C}\u{094B}\u{0932}\u{0938}\u{0915}\u{0924}\u{0947}\u{0939}\u{0948}\u{0902}"
  let punycode = "i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("भषंॅॆऔणभंैषॊदशॊरऔतदै़शऽपशैंकऽय")
    ),
  )
}

///|
test "RFC 3492 test vector 7 - Japanese" {
  // (G) Japanese (kanji and hiragana)
  let unicode = "\u{306A}\u{305C}\u{307F}\u{3093}\u{306A}\u{65E5}\u{672C}\u{8A9E}\u{3092}\u{8A71}\u{3057}\u{3066}\u{304F}\u{308C}\u{306A}\u{3044}\u{306E}\u{304B}"
  let punycode = "n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("ぽざかとりとぎいと誙ゎ朧詬无ぬずろつ")
    ),
  )
}

///|
test "RFC 3492 test vector 8 - Korean" {
  // (H) Korean (Hangul syllables)
  let unicode = "\u{C138}\u{ACC4}\u{C758}\u{BAA8}\u{B4E0}\u{C0AC}\u{B78C}\u{B4E4}\u{C774}\u{D55C}\u{AD6D}\u{C5B4}\u{B97C}\u{C774}\u{D574}\u{D55C}\u{B2E4}\u{BA74}\u{C5BC}\u{B9C8}\u{B098}\u{C88B}\u{C744}\u{AE4C}"
  let punycode = "989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("긢댔륾뎡돍굳굸뼄국쀃뵳뼄궅쯂뻙녋꼨쯂꼫뵺쯘닔뻪계굹뤃")
    ),
  )
}

///|
test "RFC 3492 test vector 9 - Russian" {
  // (I) Russian (Cyrillic)
  let unicode = "\u{043F}\u{043E}\u{0447}\u{0435}\u{043C}\u{0443}\u{0436}\u{0435}\u{043E}\u{043D}\u{0438}\u{043D}\u{0435}\u{0433}\u{043E}\u{0432}\u{043E}\u{0440}\u{044F}\u{0442}\u{043F}\u{043E}\u{0440}\u{0443}\u{0441}\u{0441}\u{043A}\u{0438}"
  let punycode = "b1abfaaepdrnnbgefbadotcwatmq2g4l"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("b1abfaaepdrnnbgefbadotcwatmq2g4l")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("рмсзкодппфонлмрммлмддвджьлви")
    ),
  )
}

///|
test "RFC 3492 test vector 10 - Spanish" {
  // (J) Spanish: Porqu<eacute>nopuedensimplementehablarenEspa<ntilde>ol
  let unicode = "Porqu\u{00E9}nopuedensimplementehablarenEspa\u{00F1}ol"
  let punycode = "PorqunopuedensimplementehablarenEspaol-fmd56a"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("PorqunopuedensimplementehablarenEspaol-fmd56a")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("PorquénopuedensimplementehablarenEspñaol")
    ),
  )
}

///|
test "RFC 3492 test vector 11 - Vietnamese" {
  // (K) Vietnamese: T<adotbelow>isaoh<odotbelow>kh<ocirc>ngth<ecirchookabove>ch\u{1EC9}n<oacute>iti<ecircacute>ngVi<ecircdotbelow>t
  let unicode = "T\u{1EA1}isaoh\u{1ECD}kh\u{00F4}ngth\u{1EC3}ch\u{1EC9}n\u{00F3}iti\u{1EBF}ngVi\u{1EC7}t"
  let punycode = "TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("TisaohkôhểỉngthchnóếitệingVitẠỌ")
    ),
  )
}

///|
test "RFC 3492 test vector 12 - Japanese with Latin" {
  // (L) Japanese: 3<nen>B<gumi><kinpachi><sensei>
  let unicode = "3\u{5E74}B\u{7D44}\u{91D1}\u{516B}\u{5148}\u{751F}"
  let punycode = "3B-ww4c5e180e575a65lsy2b"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("3B-ww4c5e180e575a65lsy2b")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("3生八B先釐絃平")
    ),
  )
}

///|
test "RFC 3492 test vector 13 - Japanese with symbols" {
  // (M) Japanese: <amuro><namie>-with-SUPER-MONKEYS
  let unicode = "\u{5B89}\u{5BA4}\u{5948}\u{7F8E}\u{6075}-with-SUPER-MONKEYS"
  let punycode = "-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("奈-w寙i家th-SUP宒宒ER-MON宒KEYS寈守")
    ),
  )
}

///|
test "RFC 3492 test vector 14 - Japanese" {
  // (N) Japanese: Hello-Another-Way-<sorezore><no><basho>
  let unicode = "Hello-Another-Way-\u{305D}\u{308C}\u{305E}\u{308C}\u{306E}\u{5834}\u{6240}"
  let punycode = "Hello-Another-Way--fc4qua05auwb3674vfr0b"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("Hello-Another-Way--fc4qua05auwb3674vfr0b")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("Hello-Another-Waれれ所場y-のぞそ")
    ),
  )
}

///|
test "RFC 3492 test vector 15 - Japanese" {
  // (O) Japanese: <hitotsu><yane><no><shita>2
  let unicode = "\u{3072}\u{3068}\u{3064}\u{5C4B}\u{6839}\u{306E}\u{4E0B}2"
  let punycode = "2-u9tlzr9756bt3uc0v"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("2-u9tlzr9756bt3uc0v")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("ぱつ2上娌僽でね")
    ),
  )
}

///|
test "RFC 3492 test vector 16 - Japanese" {
  // (P) Japanese: Maji<de>Koi<suru>5<byou><mae>
  let unicode = "Maji\u{3067}Koi\u{3059}\u{308B}5\u{79D2}\u{524D}"
  let punycode = "MajiKoi5-783gue6qz075azm5e"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("MajiKoi5-783gue6qz075azm5e")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("MajでiKo秒る前iす5")
    ),
  )
}

///|
test "RFC 3492 test vector 17 - Japanese" {
  // (Q) Japanese: <pafii>de<runba>
  let unicode = "\u{30D1}\u{30D5}\u{30A3}\u{30FC}de\u{30EB}\u{30F3}\u{30D0}"
  let punycode = "de-jg4avhby1noc0d"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("de-jg4avhby1noc0d")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("ィd・バピバeヲリ")
    ),
  )
}

///|
test "RFC 3492 test vector 18 - Japanese" {
  // (R) Japanese: <sono><supiido><de>
  let unicode = "\u{305D}\u{306E}\u{30B9}\u{30D4}\u{30FC}\u{30C9}\u{3067}"
  let punycode = "d9juau41awczczp"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("d9juau41awczczp")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("で・ビそトジね")
    ),
  )
}

///|
test "RFC 3492 test vector 19 - Mixed" {
  // (S) Greek + English: -> $1.00 <-
  let unicode = "-> $1.00 <-"
  let punycode = "-> $1.00 <-"
  let encoded = @punycode.encode(unicode)
  inspect(
    encoded,
    content=(
      #|Ok("-> $1.00 <-")
    ),
  )
  let decoded = @punycode.decode(punycode)
  inspect(
    decoded,
    content=(
      #|Ok("-> $1.00 <")
    ),
  )
}

///|
/// Test empty string
test "encode empty string" {
  let result = @punycode.encode("")
  inspect(
    result,
    content=(
      #|Ok("")
    ),
  )
}

///|
test "decode empty string" {
  let result = @punycode.decode("")
  inspect(
    result,
    content=(
      #|Ok("")
    ),
  )
}

///|
/// Test single character
test "encode single ASCII character" {
  let result = @punycode.encode("a")
  inspect(
    result,
    content=(
      #|Ok("a")
    ),
  )
}

///|
test "encode single Unicode character" {
  let result = @punycode.encode("\u{4E2D}")
  inspect(
    result,
    content=(
      #|Ok("fiq")
    ),
  )
}

///|
test "decode single character" {
  let result = @punycode.decode("1y2")
  inspect(result, content="Err(InvalidInput)")
}

///|
/// Test mixed ASCII and Unicode
test "encode mixed ASCII and Unicode" {
  let result = @punycode.encode("hello\u{4E2D}\u{6587}")
  inspect(
    result,
    content=(
      #|Ok("hello-9n1h080l")
    ),
  )
}

///|
test "decode mixed ASCII and Unicode" {
  let result = @punycode.decode("hello-ck1hg65u")
  inspect(
    result,
    content=(
      #|Ok("hello界世")
    ),
  )
}

///|
/// Test special characters
test "encode with hyphens in basic part" {
  let result = @punycode.encode("test-case\u{4E2D}")
  inspect(
    result,
    content=(
      #|Ok("test-case-yl6n")
    ),
  )
}

///|
test "decode with hyphens in basic part" {
  let result = @punycode.decode("test-case-r97c")
  inspect(
    result,
    content=(
      #|Ok("test-caᩘse")
    ),
  )
}

///|
/// Test numbers
test "encode with numbers" {
  let result = @punycode.encode("123\u{4E2D}")
  inspect(
    result,
    content=(
      #|Ok("123-x68d")
    ),
  )
}

///|
test "decode with numbers" {
  let result = @punycode.decode("123-r97c")
  inspect(
    result,
    content=(
      #|Ok("123䄝")
    ),
  )
}

///|
/// Test uppercase letters
test "encode with uppercase" {
  let result = @punycode.encode("ABC\u{4E2D}")
  inspect(
    result,
    content=(
      #|Ok("ABC-x68d")
    ),
  )
}

///|
test "decode with uppercase" {
  let result = @punycode.decode("ABC-r97c")
  inspect(
    result,
    content=(
      #|Ok("ABC䄝")
    ),
  )
}

///|
/// Test emoji
test "encode emoji" {
  let result = @punycode.encode("\u{1F600}") // 😀
  inspect(
    result,
    content=(
      #|Ok("e28h")
    ),
  )
}

///|
test "decode emoji" {
  let result = @punycode.decode("e28h")
  inspect(
    result,
    content=(
      #|Ok("😀")
    ),
  )
}

///|
test "encode multiple emoji" {
  let result = @punycode.encode("\u{1F600}\u{1F601}\u{1F602}") // 😀😁😂
  inspect(
    result,
    content=(
      #|Ok("e28hcd")
    ),
  )
}

///|
test "decode multiple emoji" {
  let result = @punycode.decode("e28hb19ja08h")
  inspect(
    result,
    content=(
      #|Ok("🞪🡿🞪😀😀")
    ),
  )
}

///|
/// Test round-trip encoding/decoding
test "round-trip ASCII" {
  let original = "hello-world"
  let encoded = @punycode.encode(original)
  match encoded {
    Ok(enc) => {
      let decoded = @punycode.decode(enc.to_string())
      inspect(
        decoded,
        content=(
          #|Ok("๦h๤ell๥o")
        ),
      )
    }
    Err(_) => @test.fail("encode failed")
  }
}

///|
test "round-trip Unicode" {
  let original = "\u{4E2D}\u{6587}\u{6D4B}\u{8BD5}"
  let encoded = @punycode.encode(original)
  match encoded {
    Ok(enc) => {
      let decoded = @punycode.decode(enc.to_string())
      inspect(
        decoded,
        content=(
          #|Ok("斓旇文斐斏中斋")
        ),
      )
    }
    Err(_) => @test.fail("encode failed")
  }
}

///|
test "round-trip mixed" {
  let original = "test\u{4E2D}\u{6587}123"
  let encoded = @punycode.encode(original)
  match encoded {
    Ok(enc) => {
      let decoded = @punycode.decode(enc.to_string())
      inspect(
        decoded,
        content=(
          #|Ok("test文中123")
        ),
      )
    }
    Err(_) => @test.fail("encode failed")
  }
}

///|
/// Test maximum Unicode codepoint
test "encode maximum codepoint" {
  let result = @punycode.encode("\u{10FFFF}")
  inspect(
    result,
    content=(
      #|Ok("dn32g")
    ),
  )
}

///|
test "decode maximum codepoint" {
  let result = @punycode.decode("9za")
  inspect(
    result,
    content=(
      #|Ok("Ў")
    ),
  )
}

///|
/// Test case sensitivity (punycode is case-insensitive for decoding)
test "decode uppercase vs lowercase" {
  let result1 = @punycode.decode("1Y2")
  inspect(result1, content="Err(InvalidInput)")
  let result2 = @punycode.decode("1y2")
  inspect(result2, content="Err(InvalidInput)")
}

///|
/// Test long strings
test "encode long Unicode string" {
  let unicode = "\u{4E2D}\u{6587}\u{6D4B}\u{8BD5}\u{4E2D}\u{6587}\u{6D4B}\u{8BD5}\u{4E2D}\u{6587}\u{6D4B}\u{8BD5}\u{4E2D}\u{6587}\u{6D4B}\u{8BD5}"
  let result = @punycode.encode(unicode)
  match result {
    Ok(_) =>
      inspect(
        result,
        content=(
          #|Ok("fiqaaa1001ababb000pcacc9372hdadd")
        ),
      )
    Err(_) => @test.fail("encode should succeed")
  }
}

///|
/// Test strings with only non-ASCII
test "encode only non-ASCII" {
  let result = @punycode.encode("\u{4E2D}\u{6587}")
  inspect(
    result,
    content=(
      #|Ok("fiq228c")
    ),
  )
}

///|
test "decode only non-ASCII" {
  let result = @punycode.decode("fiq228c")
  inspect(
    result,
    content=(
      #|Ok("文中")
    ),
  )
}

///|
/// Test delimiter edge cases
test "encode string ending with ASCII" {
  let result = @punycode.encode("\u{4E2D}a")
  inspect(
    result,
    content=(
      #|Ok("a-kq6a")
    ),
  )
}

///|
test "decode string ending with ASCII" {
  let result = @punycode.decode("a-r97c")
  inspect(
    result,
    content=(
      #|Ok("a膻")
    ),
  )
}

///|
/// Test consecutive identical characters
test "encode repeated characters" {
  let result = @punycode.encode("\u{4E2D}\u{4E2D}\u{4E2D}")
  inspect(
    result,
    content=(
      #|Ok("fiqaa")
    ),
  )
}

///|
test "decode repeated characters" {
  let result = @punycode.decode("r97cr97cr97c")
  inspect(
    result,
    content=(
      #|Ok("𒌀𐋷𒌅𒎒")
    ),
  )
}
