open Core_kernel
open Types

type 'a t

val map : 'a t -> f:('a -> 'b) -> 'b t

val sample : 'a t -> seed:Randomness.Seed.t -> 'a

val bit : bool t
val int : int -> int t
val digit : Digit.t t
val alphabetic : Alphabetic.t t
val permuted : 'a array -> 'a array t
val permutation : int -> int array t

val list : length:int -> 'a t -> 'a list t
val sequence : 'a t -> 'a Sequence.t t

