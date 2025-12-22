(* Конфигурация программы *)

type interpolation_method =
  | Linear
  | Newton

type config = {
  methods : interpolation_method list;
  step : float;
  window_size : int;
}

let default_config = {
  methods = [];
  step = 1.0;
  window_size = 2;
}

let parse_args () =
  (* Используем ref только для Arg.parse, который требует мутабельные ссылки *)
  let methods_ref = ref [] in
  let step_ref = ref 1.0 in
  let window_size_ref = ref 2 in
  
  let spec_list = [
    ("--linear", Arg.Unit (fun () -> methods_ref := Linear :: !methods_ref), "Use linear interpolation");
    ("--newton", Arg.Unit (fun () -> methods_ref := Newton :: !methods_ref), "Use Newton interpolation");
    ("--step", Arg.Set_float step_ref, "Set interpolation step (default: 1.0)");
    ("-n", Arg.Set_int window_size_ref, "Set window size for interpolation (default: 2)");
  ] in
  
  let usage_msg = "Interpolation program. Usage: my_lab3 [options]" in
  Arg.parse spec_list (fun _ -> ()) usage_msg;
  
  (* После парсинга извлекаем значения и больше не используем ref *)
  let methods = !methods_ref in
  let step = !step_ref in
  let window_size = !window_size_ref in
  
  let final_methods = 
    if List.length methods = 0 then [Linear] 
    else List.rev methods 
  in
  
  {
    methods = final_methods;
    step = step;
    window_size = window_size;
  }

let method_name = function
  | Linear -> "linear"
  | Newton -> "newton"
