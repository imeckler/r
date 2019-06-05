open Core

type t =
  | Should_I of string
  | Generate of {quantity: int; kind: Kind.e option}
  | Simple of int
  | Permute of string list

let kinds =
  [ ("yesno", Kind.T Should_I)
  ; ("direction", T Direction)
  ; ("digit", T Digit)
  ; ("bit", T Bit)
  ; ("geo", T Lat_long)
  ; ("alpha", T Alphabetic) ]

let simple ~seed _quantity =
  List.iter kinds ~f:(fun (name, T k) ->
      printf "%s: %s\n" name
        Kind.(to_string k (Generator.sample (generator k) ~seed)) )

let run ?seed t =
  let seed =
    match seed with
    | None ->
        Randomness.Seed.create ()
    | Some s ->
        Randomness.Seed.of_string s
  in
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
        let sep = Kind.separator k in
        Sequence.take Generator.(sample ~seed (sequence gen)) quantity
        |> Sequence.iter ~f:(fun t ->
               print_string (Kind.to_string k t) ;
               print_string sep ) ;
        printf "\n" )

let bail_with fmt = ksprintf (fun s -> print_endline s ; exit 1) fmt

let setup_tab_completion () =
  let inp = Unix.open_process_in "env COMMAND_OUTPUT_INSTALLATION_BASH=1 r" in
  let code = In_channel.input_all inp in
  let read_line () = In_channel.(input_line_exn stdin) in
  match Unix.close_process_in inp with
  | Error _e ->
      bail_with "Could not find r. Is it on your path?"
  | Ok () ->
      let rc =
        match Sys.getenv "HOME" with
        | None ->
            bail_with "Environment variable HOME not set."
        | Some home ->
            List.find_map [".bash_profile"; ".profile"; ".bashrc"] ~f:(fun s ->
                let path = home ^/ s in
                Option.some_if (Sys.file_exists path = `Yes) path )
            |> Option.value ~default:(home ^/ ".profile")
      in
      let rc =
        printf
          "Going to append a few lines to ~/%s for autocompletion. Ok? [n/y/f]\n\
           (default is 'no', use 'f' to choose a different file)\n\
           %!"
          (Filename.basename rc) ;
        match String.lowercase (read_line ()) with
        | "y" | "yes" ->
            rc
        | "f" ->
            read_line ()
        | _ ->
            bail_with "Exiting."
      in
      Out_channel.output_string (Out_channel.create ~append:true rc) code ;
      printf
        "Run `source %s` to enable auto-completion in this shell, or open a \
         new one.\n\
         %!"
        rc

let cmd c =
  let open Command.Let_syntax in
  let open Command.Param in
  let%map t = c
  and seed = flag "seed" (optional string) ~doc:"Randomness seed." in
  fun () -> run ?seed t

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
              (cmd
                 (let%map args =
                    anon (non_empty_sequence_as_list ("word" %: string))
                  in
                  Should_I (String.concat args ~sep:" "))) ) ] )
  in
  let quantity = anon (maybe_with_default 1 ("quantity" %: int)) in
  let simple =
    ( "all"
    , Command.basic
        ~summary:"See the same randomness in several different forms"
        (cmd
           (let%map quantity = quantity in
            Simple quantity)) )
  in
  let setup_tab_completion =
    ( "setup-tab-completion"
    , Command.basic ~summary:"Set up tab completion for r."
        (return (fun () -> setup_tab_completion ())) )
  in
  Command.group ~summary:"r"
    ( setup_tab_completion :: permute :: should :: simple
    :: List.map
         ~f:(fun (name, k) ->
           ( name
           , Command.basic
               ~summary:(sprintf "Generate one or more %ss" name)
               (cmd
                  (let%map quantity =
                     anon (maybe_with_default 1 ("quantity" %: int))
                   in
                   Generate {quantity; kind= Some k})) ) )
         kinds )
