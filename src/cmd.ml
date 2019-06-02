open Core_kernel

type t =
  | Should_I of string
  | Generate of { quantity: int; kind : Kind.e option }
  | Default
  | Permute of string list

let run t = 
  let seed = Randomness.Seed.create () in
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

