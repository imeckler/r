open Core_kernel

module Seed = struct
  type t = string

  let create () : t =
    let c = In_channel.create ~binary:true "/dev/urandom" in
    let total = 32 in
    let buf = Bytes.create total in
    let rec go bytes_read =
      if bytes_read < total then
        let r =
          In_channel.input c ~buf ~pos:bytes_read ~len:(total - bytes_read)
        in
        go (bytes_read + r)
    in
    go 0 ; In_channel.close c ; Bytes.to_string buf
end

let stream =
  let open Digestif in
  let h = blake2s 32 in
  let split_in_two s =
    let n = String.length s in
    let k = String.length s / 2 in
    (String.sub s ~pos:0 ~len:k, String.sub s ~pos:k ~len:(n - k))
  in
  let blake2s s = to_raw_string h (digest_string h s) in
  let bits s =
    Sequence.init (String.length s) ~f:(fun i -> s.[i])
    |> Sequence.concat_map ~f:(fun c ->
           let c = Char.to_int c in
           Sequence.init 8 ~f:(fun i -> (c lsr i) land 1 = 1) )
  in
  fun ~seed ->
    Sequence.unfold ~init:seed ~f:(fun s -> Some (split_in_two (blake2s s)))
    |> Sequence.concat_map ~f:bits

let create ~seed =
  let seq = ref (stream ~seed) in
  stage (fun () ->
      let x, s = Sequence.next !seq |> Option.value_exn in
      seq := s ;
      x )
