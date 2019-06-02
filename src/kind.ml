open Core_kernel
open Types

type _ t =
  | Should_I : [`Yes | `No] t
  | Bit : bool t
  | Digit : Digit.t t
  | Alphabetic : Alphabetic.t t

let generator (type a) : a t -> a Generator.t = function
  | Bit ->
      Generator.bit
  | Digit ->
      Generator.digit
  | Alphabetic ->
      Generator.alphabetic
  | Should_I ->
      Generator.(map bit ~f:(fun b -> if b then `Yes else `No))

let to_string (type a) : a t -> a -> string = function
  | Bit ->
      fun b -> if b then "1" else "0"
  | Digit ->
      Int.to_string
  | Alphabetic ->
      Char.to_string
  | Should_I -> (
      function `Yes -> "yes" | `No -> "no" )

type e = T : _ t -> e
