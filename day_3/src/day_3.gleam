import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("file.txt")

  //Part 1.
  let parser = Parser(input: input, parsed: [])
  let Parser(_, parsed) = read_instructions(parser)
  let product = parsed |> list.fold(0, fn(acc, p) { acc + { multiply(p) } })
  io.debug(product)

  //Part 2.
  let parser = ParserTwo(input: input, parsed: [], instruction: Do)
  let ParserTwo(_, parsed, _) = read_instructions_two(parser)
  let product = parsed |> list.fold(0, fn(acc, p) { acc + { multiply(p) } })
  io.debug(product)
}

fn multiply(parsed: String) -> Int {
  let assert Ok(#(a, b)) = parsed |> string.split_once(",")
  { int.parse(a) |> result.unwrap(0) } * { int.parse(b) |> result.unwrap(0) }
}

type Parser {
  Parser(input: String, parsed: List(String))
}

type Instruction {
  Do
  Dont
}

type ParserTwo {
  ParserTwo(input: String, parsed: List(String), instruction: Instruction)
}

fn read_instructions(parser: Parser) -> Parser {
  case parser.input {
    "" -> parser
    "mul(" <> rest -> {
      let parser = try_read_instruction(parser, rest, "")
      read_instructions(parser)
    }
    rest -> {
      let parser = skip_invalid_instruction(parser, rest)
      read_instructions(parser)
    }
  }
}

fn skip_invalid_instruction(parser: Parser, rest: String) -> Parser {
  case string.starts_with(rest, "mul(") {
    True -> Parser(input: rest, parsed: parser.parsed)
    False -> {
      case rest {
        "" -> Parser(input: "", parsed: parser.parsed)
        _ ->
          skip_invalid_instruction(
            parser,
            string.slice(rest, 1, string.length(rest)),
          )
      }
    }
  }
}

fn try_read_instruction(parser: Parser, rest: String, acc: String) -> Parser {
  case rest |> string.pop_grapheme {
    Ok(#(")", rest)) -> {
      //io.debug(parser)
      let assert Ok(re) = regexp.from_string("\\d{1,3},\\d{1,3}")
      case regexp.check(re, acc) {
        True -> Parser(input: rest, parsed: [acc, ..parser.parsed])
        False -> skip_invalid_instruction(parser, rest)
      }
    }
    Ok(#(",", rest)) -> try_read_instruction(parser, rest, acc <> ",")
    Ok(a) -> {
      case int.parse(a.0) {
        Ok(_) -> try_read_instruction(parser, a.1, acc <> a.0)
        Error(_) -> skip_invalid_instruction(parser, a.1)
      }
    }
    Error(_) -> skip_invalid_instruction(parser, rest)
  }
}

fn read_instructions_two(parser: ParserTwo) -> ParserTwo {
  case parser.input {
    "" -> parser
    "mul(" <> rest -> {
      let parser = try_read_instruction_two(parser, rest, "")
      read_instructions_two(parser)
    }
    "don't()" <> rest -> {
      let parser =
        ParserTwo(input: rest, parsed: parser.parsed, instruction: Dont)
      read_instructions_two(parser)
    }
    "do()" <> rest -> {
      let parser =
        ParserTwo(input: rest, parsed: parser.parsed, instruction: Do)
      read_instructions_two(parser)
    }
    rest -> {
      let parser = skip_invalid_instruction_two(parser, rest)
      read_instructions_two(parser)
    }
  }
}

fn skip_invalid_instruction_two(parser: ParserTwo, rest: String) -> ParserTwo {
  case rest {
    "mul(" <> _ -> ParserTwo(..parser, input: rest)
    "do()" <> _ -> ParserTwo(..parser, input: rest)
    "don't()" <> _ -> ParserTwo(..parser, input: rest)
    "" -> ParserTwo(..parser, input: "")
    _ ->
      skip_invalid_instruction_two(
        parser,
        string.slice(rest, 1, string.length(rest)),
      )
  }
}

fn try_read_instruction_two(
  parser: ParserTwo,
  rest: String,
  acc: String,
) -> ParserTwo {
  case rest |> string.pop_grapheme {
    Ok(#(")", rest)) -> {
      case parser.instruction {
        Do -> {
          let assert Ok(re) = regexp.from_string("\\d{1,3},\\d{1,3}")
          case regexp.check(re, acc) {
            True ->
              ParserTwo(
                input: rest,
                parsed: [acc, ..parser.parsed],
                instruction: Do,
              )
            False -> skip_invalid_instruction_two(parser, rest)
          }
        }
        Dont -> skip_invalid_instruction_two(parser, rest)
      }
    }
    Ok(#(",", rest)) -> try_read_instruction_two(parser, rest, acc <> ",")
    Ok(a) -> {
      case int.parse(a.0) {
        Ok(_) -> try_read_instruction_two(parser, a.1, acc <> a.0)
        Error(_) -> skip_invalid_instruction_two(parser, a.1)
      }
    }
    Error(_) -> skip_invalid_instruction_two(parser, rest)
  }
}
