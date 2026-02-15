let%expect_test "module b registers" =
  Shared_state.log := !Shared_state.log @ [ "b" ];
  List.iter print_endline !Shared_state.log;
  [%expect {| b |}]
;;
