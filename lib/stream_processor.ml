(* Модуль для потоковой обработки данных с окном *)

type point = Io.point

(* Определяет диапазон точек для интерполяции на основе функции-стратегии *)
let get_interpolation_points points is_first is_last x_min x_max step base_x
    strategy =
  let all_points =
    Interpolation_alg.generate_x_points_from_base base_x x_min x_max step
  in
  strategy points is_first is_last x_min x_max step all_points

(* Обработка окна точек для одного метода интерполяции *)
let process_window interpolate_fn strategy window step is_first is_last base_x =
  let window_list = List.of_seq window in
  if List.length window_list = 0 then []
  else
    let x_min = (List.hd window_list).Io.x in
    let x_max = (List.hd (List.rev window_list)).Io.x in
    let x_points =
      get_interpolation_points window_list is_first is_last x_min x_max step
        base_x strategy
    in
    List.map
      (fun x ->
        let y = interpolate_fn window_list x in
        { Io.x; y })
      x_points

(* Скользящее окно для потоковой обработки *)
let sliding_window size seq =
  let rec aux buffer was_full seq_fun () =
    match seq_fun () with
    | Seq.Nil ->
        (* Конец данных *)
        if was_full then
          (* Последнее окно уже было выведено - не дублируем *)
          Seq.Nil
        else if List.length buffer >= size then
          (* Есть полное окно, которое еще не выводили - выводим как последнее *)
          Seq.Cons ((buffer, false, true), fun () -> Seq.Nil)
        else if List.length buffer > 0 then
          (* Есть неполное окно - выводим как первое и последнее одновременно *)
          Seq.Cons ((buffer, true, true), fun () -> Seq.Nil)
        else Seq.Nil
    | Seq.Cons (x, next) ->
        let new_buffer = buffer @ [ x ] in
        if List.length new_buffer < size then
          (* Буфер еще не заполнен - продолжаем накапливать *)
          aux new_buffer false next ()
        else if List.length buffer < size then
          (* Первое полное окно *)
          Seq.Cons ((new_buffer, true, false), aux new_buffer true next)
        else
          (* Промежуточное окно *)
          let shifted_buffer = List.tl buffer @ [ x ] in
          Seq.Cons ((shifted_buffer, false, false), aux shifted_buffer true next)
  in
  aux [] false seq

(* Основная функция потоковой обработки *)
let process_stream config input_seq =
  let methods = config.Config.methods in
  let step = config.Config.step in
  let window_size = config.Config.window_size in

  (* Это единственное место где ref необходим для ленивой обработки *)
  let base_x_ref = ref None in
  let cached_seq =
    Seq.map
      (fun point ->
        (match !base_x_ref with
        | None -> base_x_ref := Some point.Io.x
        | Some _ -> ());
        point)
      input_seq
  in

  let windows = sliding_window window_size cached_seq in

  let process_window_for_all_methods (window, is_first, is_last) =
    let base_x = match !base_x_ref with Some x -> x | None -> 0.0 in
    List.concat_map
      (fun method_type ->
        let interpolate_fn = Interpolation_alg.interpolate method_type in
        let strategy = Interpolation_alg.get_strategy method_type in
        let points =
          process_window interpolate_fn strategy (List.to_seq window) step
            is_first is_last base_x
        in
        List.map (fun p -> (method_type, p)) points)
      methods
  in

  Seq.concat_map
    (fun w -> List.to_seq (process_window_for_all_methods w))
    windows
