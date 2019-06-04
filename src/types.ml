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
end
