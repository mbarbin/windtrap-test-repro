let%expect_test "read config with lazy default" =
  let v = Shared_state.get_config_or_default ~default:0 in
  Printf.printf "config = %d\n" v;
  [%expect {|config = 0|}]
;;
