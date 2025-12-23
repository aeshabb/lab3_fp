(* Модуль алгоритмов интерполяции *)

type point = Io.point

(* Линейная интерполяция между двумя точками *)
let linear_interpolate p1 p2 x =
  if p1.Io.x = p2.Io.x then p1.Io.y
  else
    let k = (p2.Io.y -. p1.Io.y) /. (p2.Io.x -. p1.Io.x) in
    p1.Io.y +. (k *. (x -. p1.Io.x))

(* Вычисление разделенных разностей для метода Ньютона *)
let divided_differences points =
  let n = List.length points in
  let table = Array.make_matrix n n 0.0 in

  (* Инициализация первого столбца значениями y *)
  List.iteri (fun i p -> table.(i).(0) <- p.Io.y) points;

  (* Вычисление разделенных разностей *)
  for j = 1 to n - 1 do
    for i = 0 to n - j - 1 do
      let xi = (List.nth points i).Io.x in
      let xj = (List.nth points (i + j)).Io.x in
      table.(i).(j) <- (table.(i + 1).(j - 1) -. table.(i).(j - 1)) /. (xj -. xi)
    done
  done;

  Array.to_list (Array.init n (fun i -> table.(0).(i)))

(* Интерполяция методом Ньютона *)
let newton_interpolate points x =
  let coeffs = divided_differences points in
  let x_vals = List.map (fun p -> p.Io.x) points in

  let rec eval coeffs x_vals acc term =
    match (coeffs, x_vals) with
    | [], _ | _, [] -> acc
    | c :: cs, x0 :: xs ->
        let new_acc = acc +. (c *. term) in
        let new_term = term *. (x -. x0) in
        eval cs xs new_acc new_term
  in

  eval coeffs x_vals 0.0 1.0

(* Интерполяция с использованием выбранного метода *)
let interpolate method_type points x =
  match method_type with
  | Config.Linear ->
      if List.length points >= 2 then
        linear_interpolate (List.hd points) (List.nth points 1) x
      else (List.hd points).Io.y
  | Config.Newton -> newton_interpolate points x

(* Тип стратегии для определения какие X-координаты выводить для окна *)
type strategy =
  point list ->
  bool ->
  bool ->
  float ->
  float ->
  float ->
  float list ->
  float list

(* Генерирует последовательность x-координат с заданным шагом от базовой точки *)
let generate_x_points_from_base base_x x_min x_max step =
  let first_k = ceil ((x_min -. base_x) /. step) in
  let rec gen k =
    let x = base_x +. (k *. step) in
    if x > x_max +. (step *. 0.001) then []
    else if x >= x_min -. (step *. 0.001) then x :: gen (k +. 1.0)
    else gen (k +. 1.0)
  in
  gen first_k

(* Стратегия для линейной интерполяции *)
let linear_strategy _points is_first is_last _x_min _x_max _step all_points =
  if is_first && is_last then all_points
  else if is_last then []
  else if is_first then all_points
  else
    let x_min =
      if List.length _points > 0 then (List.hd _points).Io.x else _x_min
    in
    List.filter (fun x -> x > x_min +. (_step *. 0.001)) all_points

(* Стратегия для полиномиальной интерполяции Ньютона *)
let newton_strategy points is_first is_last _x_min _x_max _step all_points =
  if is_first && is_last then all_points
  else if is_first then
    let last_idx = List.length points - 1 in
    let x_last = (List.nth points last_idx).Io.x in
    List.filter (fun x -> x <= x_last +. (_step *. 0.001)) all_points
  else
    let prev_last_idx = List.length points - 2 in
    let x_prev_last = (List.nth points prev_last_idx).Io.x in
    List.filter (fun x -> x > x_prev_last +. (_step *. 0.001)) all_points

(* Получить стратегию для метода интерполяции *)
let get_strategy method_type =
  match method_type with
  | Config.Linear -> linear_strategy
  | Config.Newton -> newton_strategy
