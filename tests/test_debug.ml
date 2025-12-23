let () =
  let config =
    { Config.methods = [ Config.Linear ]; step = 0.7; window_size = 2 }
  in
  print_endline "Config created";
  Printf.printf "Step: %f, Window: %d\n" config.step config.window_size;

  let points =
    [
      { Io.x = 0.0; y = 0.0 };
      { Io.x = 1.0; y = 1.0 };
      { Io.x = 2.0; y = 2.0 };
      { Io.x = 3.0; y = 3.0 };
    ]
  in

  let seq = List.to_seq points in
  let result = Stream_processor.process_stream config seq in

  Seq.iter
    (fun (method_type, point) ->
      Printf.printf "%s: %g %g\n"
        (Config.method_name method_type)
        point.Io.x point.Io.y)
    result
