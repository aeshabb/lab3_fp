(* Модуль для потоковой обработки данных с окном *)

type point = Io.point

(* Генерирует последовательность x-координат с заданным шагом от базовой точки *)
let generate_x_points_from_base base_x x_min x_max step =
  (* Находим первую точку >= x_min, кратную шагу от base_x *)
  let first_k = ceil ((x_min -. base_x) /. step) in
  let rec gen k =
    let x = base_x +. (k *. step) in
    if x > x_max +. (step *. 0.001) then []
    else if x >= x_min -. (step *. 0.001) then
      x :: gen (k +. 1.0)
    else
      gen (k +. 1.0)
  in
  gen first_k

(* Определяет диапазон точек для интерполяции на основе функции-стратегии *)
let get_interpolation_points points is_first is_last x_min x_max step base_x strategy =
  let all_points = generate_x_points_from_base base_x x_min x_max step in
  strategy points is_first is_last x_min x_max step all_points

(* Стратегия для линейной интерполяции *)
let linear_strategy _points is_first is_last _x_min _x_max _step all_points =
  if is_first && is_last then
    (* Единственное окно - выводим все *)
    all_points  
  else if is_last then
    (* Последнее окно - не выводим, все уже выведено *)
    []
  else if is_first then
    (* Первое окно - выводим все точки *)
    all_points
  else
    (* Промежуточное окно - выводим точки СТРОГО после x_min *)
    let x_min = if List.length _points > 0 then (List.hd _points).Io.x else _x_min in
    List.filter (fun x -> x > x_min +. (_step *. 0.001)) all_points

(* Стратегия для полиномиальной интерполяции Ньютона *)
let newton_strategy points is_first is_last _x_min _x_max _step all_points =
  if is_first && is_last then
    (* Единственное окно - выводим все *)
    all_points
  else if is_first then
    (* Первое окно - выводим от начала до последней точки окна включительно *)
    let last_idx = List.length points - 1 in
    let x_last = (List.nth points last_idx).Io.x in
    List.filter (fun x -> x <= x_last +. (_step *. 0.001)) all_points
  else
    (* Все остальные окна - выводим от ПОСЛЕДНЕЙ точки предыдущего окна (НЕ включая) до конца *)
    (* Последняя точка предыдущего окна = третья с конца текущего окна *)
    let prev_last_idx = List.length points - 2 in
    let x_prev_last = (List.nth points prev_last_idx).Io.x in
    List.filter (fun x -> x > x_prev_last +. (_step *. 0.001)) all_points

(* Получить стратегию для метода интерполяции *)
let get_strategy method_type =
  match method_type with
  | Config.Linear -> linear_strategy
  | Config.Newton -> newton_strategy

(* Обработка окна точек для одного метода интерполяции *)
let process_window interpolate_fn strategy window step is_first is_last base_x =
  let window_list = List.of_seq window in
  if List.length window_list = 0 then []
  else
    let x_min = (List.hd window_list).Io.x in
    let x_max = (List.hd (List.rev window_list)).Io.x in
    let x_points = get_interpolation_points window_list is_first is_last x_min x_max step base_x strategy in
    List.map (fun x ->
      let y = interpolate_fn window_list x in
      { Io.x; y }
    ) x_points

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
        else
          Seq.Nil
    | Seq.Cons (x, next) ->
        let new_buffer = buffer @ [x] in
        if List.length new_buffer < size then
          (* Буфер еще не заполнен - продолжаем накапливать *)
          aux new_buffer false next ()
        else if List.length buffer < size then
          (* Первое полное окно *)
          Seq.Cons ((new_buffer, true, false), aux new_buffer true next)
        else
          (* Промежуточное окно *)
          let shifted_buffer = (List.tl buffer) @ [x] in
          Seq.Cons ((shifted_buffer, false, false), aux shifted_buffer true next)
  in
  aux [] false seq

(* Извлекает первый элемент из последовательности без мутабельности *)
let get_first_element seq =
  match seq () with
  | Seq.Nil -> None
  | Seq.Cons (x, _) -> Some x

(* Основная функция потоковой обработки *)
let process_stream config input_seq =
  let methods = config.Config.methods in
  let step = config.Config.step in
  let window_size = config.Config.window_size in
  
  (* Получаем базовую точку из первого элемента последовательности *)
  (* Используем ref ТОЛЬКО для кеширования base_x при первом чтении *)
  (* Это единственное место где ref необходим для ленивой обработки *)
  let base_x_ref = ref None in
  let cached_seq = Seq.map (fun point ->
    (match !base_x_ref with
    | None -> base_x_ref := Some point.Io.x
    | Some _ -> ());
    point
  ) input_seq in
  
  let windows = sliding_window window_size cached_seq in
  
  let process_window_for_all_methods (window, is_first, is_last) =
    let base_x = match !base_x_ref with
      | Some x -> x
      | None -> 0.0
    in
    List.concat_map (fun method_type ->
      let interpolate_fn = Interpolation_alg.interpolate method_type in
      let strategy = get_strategy method_type in
      let points = process_window interpolate_fn strategy (List.to_seq window) step is_first is_last base_x in
      List.map (fun p -> (method_type, p)) points
    ) methods
  in
  
  Seq.concat_map (fun w -> List.to_seq (process_window_for_all_methods w)) windows
