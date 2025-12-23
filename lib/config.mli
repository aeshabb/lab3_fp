(** Configuration module for interpolation program *)

(** Interpolation method type *)
type interpolation_method =
  | Linear  (** Linear interpolation *)
  | Newton  (** Newton polynomial interpolation *)

type config = {
  methods : interpolation_method list;
      (** List of interpolation methods to apply *)
  step : float;  (** Step size for generating interpolated points *)
  window_size : int;  (** Size of sliding window for interpolation *)
}
(** Configuration record *)

val default_config : config
(** Default configuration with no methods, step=1.0, window_size=2 *)

val parse_args : unit -> config
(** Parse command-line arguments and return configuration *)

val method_name : interpolation_method -> string
(** Get string name for interpolation method *)
