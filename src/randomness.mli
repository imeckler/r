open Core_kernel

val create : seed:string -> (unit -> bool) Staged.t
