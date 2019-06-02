open Core_kernel
open Types

(* Maybe you give a quantity like

   r 1 'test'

   gives one bit, one alpha, one number, an ordering on 1 object, etc.

   r perm these are the words

   permute them randomly?
   *)

module Kind = struct
  type _ t =
    | Should_I : [`Yes | `No] t
    | Bit : bool t
    | Digit : Digit.t t
    | Alphabetic : Alphabetic.t t

  let generator (type a) : a t -> a Generator.t =
    function
    | Bit -> Generator.bit
    | Digit -> Generator.digit
    | Alphabetic -> Generator.alphabetic
    | Should_I -> Generator.(map bit ~f:(fun b -> if b then `Yes else `No))

  let to_string (type a)  : a t -> a -> string = function
    | Bit -> fun b -> if b then "1" else "0"
    | Digit -> Int.to_string
    | Alphabetic -> Char.to_string
    | Should_I -> function
      | `Yes -> "yes"
      | `No -> "no"

  type e = T : _ t -> e
end

let urandom_seed () : string =
  let c = In_channel.create ~binary:true "/dev/urandom" in
  let total = 32 in
  let buf = Bytes.create total in
  let rec go bytes_read =
    if bytes_read < total then begin
      let r = In_channel.input c ~buf ~pos:bytes_read ~len:(total - bytes_read) in
      go (bytes_read + r)
    end
  in
  go 0;
  In_channel.close c;
  Bytes.to_string buf

module Quantified_kind = struct
  type 'a t = { quantity: int; kind : 'a Kind.t }

(*     | Permutation -> Generator.permutation *)
end

module Cmd = struct
  type t =
    | Should_I of string
    | Generate of { quantity: int; kind : Kind.e option }
    | Default
    | Permute of string list

  let run t = 
    let seed = urandom_seed () in
    match t with
    | Default -> ()
    | Should_I s ->
      let fmt : (_, _, _) format =
        begin match Generator.(sample ~seed (Kind.generator Should_I)) with
        | `Yes -> "Yes, you should %s.\n" 
        | `No -> "No, you shouldn't %s.\n"
        end
      in
      printf fmt s
    | Permute xs ->
      Generator.(sample ~seed (permuted (Array.of_list xs)))
      |> String.concat_array ~sep:" "
      |> print_endline

    | Generate { quantity; kind } ->
      match kind with
      | None -> ()
      | Some (T k) ->
        let gen = Kind.generator k in
        Sequence.take Generator.(sample ~seed (sequence gen))
          quantity
        |> Sequence.iter ~f:(fun t -> 
            print_string (Kind.to_string k t));
        printf "\n"
end

let command =
  let open Command.Let_syntax in
  let open Command.Param in
  let permute =
    ( "permute",
      Command.basic ~summary:"Permute a list of items" (
        let%map args = anon  (non_empty_sequence_as_list ("item" %: string)) in
        fun () -> Cmd.run (Permute args)
      )
    )
  in
  let should =
    ( "should",
      Command.group ~summary:""
        [ "i",
          Command.basic ~summary:"Should you do something" (
            let%map args = anon (non_empty_sequence_as_list ("word" %: string)) in
            fun () ->
              Cmd.run (Should_I (String.concat args ~sep:" " ))
          )
        ]
    )
  in

  Command.group ~summary:"r" (permute :: should :: List.map ~f:(fun (name, k) ->
      (name,
      Command.basic ~summary:(sprintf "Generate one or more %ss" name)  (
          let%map quantity = anon (maybe_with_default 1 ("quantity" %: int)) in
          fun () ->
            Cmd.run (Generate { quantity; kind=Some k })
        ))
    )
    [ "bit", Kind.T Bit
    ; "digit", T Digit
    ; "alpha", T Alphabetic
    ; "yesno", T Should_I
    ])

module Command_line = struct
  type 'a t =
    | Done of 'a
    | Choice of 'a t list
    | Command of string * 'a t
                  

  let t =
    Choice (List.map ~f:(fun (name, k) -> Command (name, Done k))
      [ "bit", Kind.T Bit
      ; "digit", T Digit
      ; "alpha", T Alphabetic
      ])

end

module Parse = struct
  include Angstrom

  let map x ~f = Angstrom.(<$>) f x
  module Let_syntax = struct
    module Open_on_rhs = struct end
    let map = map
    let both x y = Angstrom.((fun x y -> (x, y)) <$> x <*> y)
    let return = Angstrom.return
    let bind t ~f = Angstrom.(t >>= f)
  end

  let word t =
    let%map x = t
    and () = skip_while Char.is_whitespace in
    x

  let int =
    Int.of_string <$> take_while1 Char.is_digit 

  let quantified_kind s k =
    let%map _ = word (string s)
    and n = option 1 int in
    (n, k)

  let cmd =
    List.map
      [ "bit", Kind.T Bit
      ; "digit", T Digit
      ; "alpha", T Alphabetic
      ]
      ~f:(fun (s, k) -> quantified_kind s k)
    |> choice 
    |> map ~f:(fun (n, k) -> Cmd.Generate { quantity=n; kind=Some k})
end

let () = Core.Command.run command
