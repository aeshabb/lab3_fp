(** Interpolation algorithms module *)

type point = Io.point
(** A 2D point *)

val linear_interpolate : point -> point -> float -> float
(** Linear interpolation between two points at x *)

val newton_interpolate : point list -> float -> float
(** Newton polynomial interpolation for a list of points at x *)

val interpolate : Config.interpolation_method -> point list -> float -> float
(** Interpolate using the specified method *)

type strategy =
  point list ->
  bool ->
  bool ->
  float ->
  float ->
  float ->
  float list ->
  float list
(** Strategy function type for determining which x-coordinates to output for a
    window *)

val generate_x_points_from_base : float -> float -> float -> float -> float list
(** Generate x-coordinates with given step from base point between x_min and
    x_max *)

val get_strategy : Config.interpolation_method -> strategy
(** Get the interpolation strategy for a given method *)
