let test_points = [
  { Io.x = 0.0; y = 0.0 };
  { Io.x = 1.0; y = 1.0 };
  { Io.x = 2.0; y = 2.0 };
  { Io.x = 3.0; y = 3.0 };
]

let () =
  let seq = List.to_seq test_points in
  let windows = Stream_processor.sliding_window 2 (fun () -> seq ()) in
  Seq.iter (fun (window, is_first, is_last) ->
    Printf.printf "Window: [";
    List.iter (fun p -> Printf.printf "%.1f " p.Io.x) window;
    Printf.printf "] first=%b last=%b\n" is_first is_last;
    flush stdout
  ) windows
