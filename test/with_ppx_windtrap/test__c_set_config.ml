let%expect_test "set config to 42" =
  (match Shared_state.set_config_exn 42 with
   | () -> Printf.printf "config set to %d\n" (Option.get !Shared_state.config)
   | exception exn -> Printf.printf "raised: %s\n" (Printexc.to_string exn));
  [%expect {|raised: Failure("config already set")|}]
;;
