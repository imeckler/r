open Core_kernel
open Types

type 'a t = choose:(unit -> bool) -> 'a

let bit : bool t = fun ~choose -> choose ()

let map (t : 'a t) ~f ~choose = f (t ~choose)

let n_bit_int ~n : int t =
 fun ~choose ->
  let rec go acc i =
    if i = n then acc
    else go ((acc lsl 1) lor if choose () then 1 else 0) (i + 1)
  in
  go 0 0

let rec int n ~choose =
  let r = n_bit_int ~n:(Int.ceil_log2 n) ~choose in
  if r < n then r else int n ~choose

let digit : Digit.t t = int 10

let alphabetic : Alphabetic.t t =
 fun ~choose -> Char.of_int_exn (Char.to_int 'a' + int ~choose 26)

(* Uses n * log n ~= log n! bits of randomness *)
let shuffle arr ~choose =
  let n = Array.length arr in
  let rec go pos =
    let remaining = n - pos in
    if remaining > 0 then (
      let to_pos = pos + int remaining ~choose in
      Array.swap arr pos to_pos ;
      go (pos + 1) )
  in
  go 0

let permuted t ~choose =
  let a = Array.copy t in
  shuffle a ~choose ; a

let permutation n : Permutation.t t =
 fun ~choose ->
  let a = Array.init n ~f:Fn.id in
  shuffle a ~choose ; a

let sample t ~seed = t ~choose:(unstage (Randomness.create ~seed))

let sequence t ~choose =
  Sequence.unfold ~init:() ~f:(fun () -> Some (t ~choose, ()))

let list ~length t ~choose =
  (* List.init initializes the list backwards. *)
  List.rev (List.init length ~f:(fun _ -> t ~choose))

let tuple2 t1 t2 ~choose = (t1 ~choose, t2 ~choose)

let tuple3 t1 t2 t3 ~choose = (t1 ~choose, t2 ~choose, t3 ~choose)

let dup2 t = tuple2 t t

let dup3 t = tuple3 t t t

let float ~choose =
  let bits = 10 in
  let denom = Float.of_int (1 lsl bits) in
  Float.of_int (n_bit_int ~n:bits ~choose) /. denom
