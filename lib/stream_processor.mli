(** Stream processing module with sliding window *)

type point = Io.point
(** A 2D point *)

val sliding_window : int -> 'a Seq.t -> ('a list * bool * bool) Seq.t
(** Create a sliding window of given size over a sequence. Returns a sequence of
    (buffer, is_first, is_last) tuples *)

val process_stream :
  Config.config -> point Seq.t -> (Config.interpolation_method * point) Seq.t
(** Process input stream with interpolation using given configuration. Returns a
    sequence of (method, interpolated_point) pairs *)
