///|
pub enum IdnaError {
  InvalidCharacter
  InvalidHyphenPosition
  InvalidPunycode
  BidiError
  JoinerError
  LabelTooLong
  DomainTooLong
}

pub type IdnaErrorList = Array[IdnaError]