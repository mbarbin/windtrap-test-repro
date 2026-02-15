let state = ref "initial"
let log : string list ref = ref []
let config : int option ref = ref None

let set_config_exn value =
  match !config with
  | None -> config := Some value
  | Some _ -> failwith "config already set"
;;

let get_config_or_default ~default =
  match !config with
  | Some v -> v
  | None ->
    config := Some default;
    default
;;
