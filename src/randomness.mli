open Core_kernel

module Seed : sig
  type t

  val create : unit -> t
end

val create : seed:Seed.t -> (unit -> bool) Staged.t
