(* Модуль для работы с вводом/выводом данных *)

type point = { x : float; y : float }

(* Разбор строки в формате CSV *)
let parse_line line =
  try
    let line = String.trim line in
    if String.length line = 0 then None
    else
      (* Пытаемся разбить по различным разделителям *)
      let parts =
        if String.contains line ';' then String.split_on_char ';' line
        else if String.contains line '\t' then String.split_on_char '\t' line
        else if String.contains line ',' then String.split_on_char ',' line
        else String.split_on_char ' ' line
      in
      match parts with
      | [ x_str; y_str ] ->
          let x = float_of_string (String.trim x_str) in
          let y = float_of_string (String.trim y_str) in
          Some { x; y }
      | _ -> None
  with _ -> None

(* Читает точки из stdin в ленивом режиме *)
let read_points_lazy () =
  let rec read_next () =
    try
      let line = input_line stdin in
      match parse_line line with
      | Some point -> Seq.Cons (point, read_next)
      | None -> read_next ()
    with End_of_file -> Seq.Nil
  in
  read_next

(* Вывод точки *)
let print_point method_name point =
  Printf.printf "%s: %g %g\n" method_name point.x point.y;
  flush stdout
