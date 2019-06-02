open Core_kernel

(* Maybe you give a quantity like

   r 1 'test'

   gives one bit, one alpha, one number, an ordering on 1 object, etc.

   r perm these are the words

   permute them randomly?
   *)

let command =
  let open Command.Let_syntax in
  let open Command.Param in
  let permute =
    ( "permute"
    , Command.basic ~summary:"Permute a list of items"
        (let%map args = anon (non_empty_sequence_as_list ("item" %: string)) in
         fun () -> Cmd.run (Permute args)) )
  in
  let should =
    ( "should"
    , Command.group ~summary:""
        [ ( "i"
          , Command.basic ~summary:"Should you do something"
              (let%map args =
                 anon (non_empty_sequence_as_list ("word" %: string))
               in
               fun () -> Cmd.run (Should_I (String.concat args ~sep:" "))) ) ]
    )
  in
  Command.group ~summary:"r"
    ( permute :: should
    :: List.map
         ~f:(fun (name, k) ->
           ( name
           , Command.basic
               ~summary:(sprintf "Generate one or more %ss" name)
               (let%map quantity =
                  anon (maybe_with_default 1 ("quantity" %: int))
                in
                fun () -> Cmd.run (Generate {quantity; kind= Some k})) ) )
         [ ("bit", Kind.T Bit)
         ; ("digit", T Digit)
         ; ("alpha", T Alphabetic)
         ; ("yesno", T Should_I) ] )

let () = Core.Command.run command
