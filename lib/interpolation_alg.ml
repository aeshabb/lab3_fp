(* Модуль алгоритмов интерполяции *)

type point = Io.point

(* Линейная интерполяция между двумя точками *)
let linear_interpolate p1 p2 x =
  if p1.Io.x = p2.Io.x then p1.Io.y
  else
    let k = (p2.Io.y -. p1.Io.y) /. (p2.Io.x -. p1.Io.x) in
    p1.Io.y +. k *. (x -. p1.Io.x)

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
    match coeffs, x_vals with
    | [], _ | _, [] -> acc
    | c :: cs, x0 :: xs ->
        let new_acc = acc +. c *. term in
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
      else
        (List.hd points).Io.y
  | Config.Newton ->
      newton_interpolate points x
