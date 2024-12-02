import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("file.txt")
  let tups = input |> string.split("\n")
  let tups =
    tups
    |> list.map(fn(t) {
      t |> string.split_once("   ") |> result.unwrap(#("0", "0"))
    })
  let inputs = build_lists(tups, [], [])

  //Part 1.
  let inp1 = list.sort(inputs.0, int.compare)
  let inp2 = list.sort(inputs.1, int.compare)
  let sum = calculate(inp1, inp2, 0)
  io.debug(sum)

  //Part 2.
  let groups =
    inputs.0
    |> list.fold(dict.new(), fn(acc, i) {
      let v = dict.get(acc, i) |> result.unwrap(0)
      dict.insert(acc, i, v + 1)
    })

  let scores =
    inputs.1
    |> list.map(fn(i) { i * { dict.get(groups, i) |> result.unwrap(0) } })

  io.debug(int.sum(scores))
}

fn build_lists(tups: List(#(String, String)), arr1, arr2) {
  case tups {
    [] -> #(arr1, arr2)
    [h, ..rest] ->
      build_lists(rest, [{ int.parse(h.0) |> result.unwrap(0) }, ..arr1], [
        { int.parse(h.1) |> result.unwrap(0) },
        ..arr2
      ])
  }
}

fn calculate(input1, input2, sum) {
  case input1, input2 {
    [h1, ..rest1], [h2, ..rest2] ->
      calculate(rest1, rest2, sum + int.absolute_value(h1 - h2))
    [], [] -> sum
    _, _ -> 0
    // Should never happen since the lists are the same length.
  }
}
