let%expect_test "mutate and print" =
  Shared_state.state := "mutated";
  print_string !Shared_state.state;
  [%expect {| mutated |}]
;;

let%expect_test "only print" =
  print_string !Shared_state.state;
  [%expect {| mutated |}]
;;
