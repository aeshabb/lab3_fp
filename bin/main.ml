(* Главный модуль программы *)

let () =
  (* Парсинг аргументов командной строки *)
  let config = Interpolation.Config.parse_args () in
  
  (* Читаем поток точек из stdin *)
  let input_seq = Interpolation.Io.read_points_lazy () in
  
  (* Обрабатываем поток с интерполяцией *)
  let output_seq = Interpolation.Stream_processor.process_stream config input_seq in
  
  (* Выводим результаты построчно с немедленным flush *)
  Seq.iter (fun (method_type, point) ->
    Interpolation.Io.print_point (Interpolation.Config.method_name method_type) point;
    flush stdout  (* Немедленно выводим результат *)
  ) output_seq;
  
  (* Финальный flush на случай буферизации *)
  flush stdout
