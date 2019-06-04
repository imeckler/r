open Core_kernel

type t =
  | Should_I of string
  | Generate of {quantity: int; kind: Kind.e option}
  | Simple of int
  | Permute of string list

let kinds =
  [ ("yesno", Kind.T Should_I)
  ; ("digit", T Digit)
  ; ("bit", T Bit)
  ; ("geo", T Lat_long)
  ; ("alpha", T Alphabetic) ]

let simple ~seed _quantity =
  List.iter kinds ~f:(fun (name, T k) ->
      printf "%s: %s\n" name
        Kind.(to_string k (Generator.sample (generator k) ~seed)) )

let run t =
  let seed = Randomness.Seed.create () in
  match t with
  | Simple n ->
      simple ~seed n
  | Should_I s ->
      let fmt : (_, _, _) format =
        match Generator.sample ~seed (Kind.generator Should_I) with
        | `Yes ->
            "Yes, you should %s.\n"
        | `No ->
            "No, you shouldn't %s.\n"
      in
      printf fmt s
  | Permute xs ->
      Generator.(sample ~seed (permuted (Array.of_list xs)))
      |> String.concat_array ~sep:" "
      |> print_endline
  | Generate {quantity; kind} -> (
    match kind with
    | None ->
        ()
    | Some (T k) ->
        let gen = Kind.generator k in
        Sequence.take Generator.(sample ~seed (sequence gen)) quantity
        |> Sequence.iter ~f:(fun t -> print_string (Kind.to_string k t)) ;
        printf "\n" )

let command =
  let open Command.Let_syntax in
  let open Command.Param in
  let permute =
    ( "permute"
    , Command.basic ~summary:"Permute a list of items"
        (let%map args = anon (non_empty_sequence_as_list ("item" %: string)) in
         fun () -> run (Permute args)) )
  in
  let should =
    ( "should"
    , Command.group ~summary:""
        [ ( "i"
          , Command.basic ~summary:"Should you do something"
              (let%map args =
                 anon (non_empty_sequence_as_list ("word" %: string))
               in
               fun () -> run (Should_I (String.concat args ~sep:" "))) ) ] )
  in
  let quantity = anon (maybe_with_default 1 ("quantity" %: int)) in
  let simple =
    ( "all"
    , Command.basic
        ~summary:"See the same randomness in several different forms"
        (let%map quantity = quantity in
         fun () -> run (Simple quantity)) )
  in
  Command.group ~summary:"r"
    ( permute :: should :: simple
    :: List.map
         ~f:(fun (name, k) ->
           ( name
           , Command.basic
               ~summary:(sprintf "Generate one or more %ss" name)
               (let%map quantity =
                  anon (maybe_with_default 1 ("quantity" %: int))
                in
                fun () -> run (Generate {quantity; kind= Some k})) ) )
         kinds )
