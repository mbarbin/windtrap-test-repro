let%expect_test "module a registers" =
  Shared_state.log := !Shared_state.log @ [ "a" ];
  List.iter print_endline !Shared_state.log;
  [%expect
    {|b
a|}]
;;
