(** I/O module for reading and writing data points *)

type point = { x : float; y : float }
(** A 2D point with x and y coordinates *)

val parse_line : string -> point option
(** Parse a line from CSV/TSV/space-separated format into a point. Returns None
    if the line cannot be parsed. *)

val read_points_lazy : unit -> point Seq.t
(** Read points from stdin as a lazy sequence *)

val print_point : string -> point -> unit
(** Print a point with method name prefix *)
