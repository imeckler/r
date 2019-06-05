open Core_kernel

module Digit = struct
  type t = int
end

module Permutation = struct
  type t = int array
end

module Alphabetic = struct
  type t = char
end

module Lat_long = struct
  type t = {latitude: float * [`N | `S]; longitude: float * [`W | `E]}

  let to_string {latitude= lat, lat_dir; longitude= long, long_dir} =
    sprintf "%f° %c %f° %c" lat
      (match lat_dir with `N -> 'N' | `S -> 'S')
      long
      (match long_dir with `E -> 'E' | `W -> 'W')
end

module Direction = struct
  type t = Left | Right [@@deriving sexp]

  let to_string = Fn.compose String.lowercase (sprintf !"%{sexp:t}")
end
