open Core_kernel
open Types

type _ t =
  | Should_I : [`Yes | `No] t
  | Bit : bool t
  | Digit : Digit.t t
  | Alphabetic : Alphabetic.t t
  | Lat_long : Lat_long.t t
  | Direction : Direction.t t

let separator (type a) : a t -> string = function
  | Should_I ->
      " "
  | Bit ->
      ""
  | Digit ->
      ""
  | Alphabetic ->
      ""
  | Lat_long ->
      ", "
  | Direction ->
      " "

let generator (type a) : a t -> a Generator.t = function
  | Bit ->
      Generator.bit
  | Digit ->
      Generator.digit
  | Alphabetic ->
      Generator.alphabetic
  | Should_I ->
      Generator.(map bit ~f:(fun b -> if b then `Yes else `No))
  | Direction ->
      Generator.(map bit ~f:(fun b -> if b then Direction.Left else Right))
  | Lat_long ->
      Generator.(
        map
          (tuple2 (dup2 float) (dup2 bit))
          ~f:(fun ((x, y), (n, e)) ->
            { Lat_long.latitude= (90. *. x, if n then `N else `S)
            ; longitude= (180. *. y, if e then `E else `W) } ))

let to_string (type a) : a t -> a -> string = function
  | Bit ->
      fun b -> if b then "1" else "0"
  | Digit ->
      Int.to_string
  | Alphabetic ->
      Char.to_string
  | Should_I -> (
      function `Yes -> "yes" | `No -> "no" )
  | Direction ->
      Direction.to_string
  | Lat_long ->
      Lat_long.to_string

type e = T : _ t -> e
