import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  //Part 1.
  let assert Ok(input) = simplifile.read("file.txt")
  let reports =
    input
    |> string.split("\n")
    |> list.map(fn(r) {
      r
      |> string.split(" ")
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    })

  let valid_reports = reports |> list.filter(fn(r) { report_valid(r) })
  io.debug(list.length(valid_reports) - 1)
  //my editer inserts empty line to the end of file.txt

  //Part 2.
  let count =
    reports
    |> list.filter(fn(r) { fix(r) })
    |> list.length
  io.debug(count - 1)
}

fn report_valid(report: List(Int)) {
  report_ordered(report, fn(x, y) { x > y })
  || report_ordered(report, fn(x, y) { x < y })
}

fn fix(report: List(Int)) {
  can_be_fixed(report, fn(x, y) { x > y }, False, 0)
  || can_be_fixed(report, fn(x, y) { x < y }, False, 0)
}

fn report_ordered(report, f: fn(Int, Int) -> Bool) {
  case report {
    [] | [_] -> True
    [x, y, ..rest] ->
      case valid_step(x, y) {
        True -> False
        False -> f(x, y) && report_ordered([y, ..rest], f)
      }
  }
}

fn can_be_fixed(report, f, fixed, previous) {
  case report, fixed, previous {
    [], _, _ | [_], _, _ -> True
    [x, y, ..rest], True, _ ->
      case valid_step(x, y) {
        True -> False
        False -> f(x, y) && report_ordered([y, ..rest], f)
      }
    [x, y, ..rest], False, 0 ->
      case valid_step(x, y) {
        True ->
          can_be_fixed([y, ..rest], f, True, x)
          || can_be_fixed([x, ..rest], f, True, x)
        False -> {
          case f(x, y) {
            True -> can_be_fixed([y, ..rest], f, False, x)
            False ->
              can_be_fixed([y, ..rest], f, True, x)
              || can_be_fixed([x, ..rest], f, True, x)
          }
        }
      }
    [x, y, ..rest], False, previous ->
      case valid_step(x, y) {
        True ->
          can_be_fixed([previous, y, ..rest], f, True, x)
          || can_be_fixed([previous, x, ..rest], f, True, previous)
        False -> {
          case f(x, y) {
            True -> can_be_fixed([y, ..rest], f, False, x)
            False ->
              can_be_fixed([previous, y, ..rest], f, True, x)
              || can_be_fixed([previous, x, ..rest], f, True, previous)
          }
        }
      }
  }
}

fn valid_step(x, y) {
  int.absolute_value(x - y) > 3 || int.absolute_value(x - y) < 1 || x == y
}
