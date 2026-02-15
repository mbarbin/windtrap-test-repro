val state : string ref
val log : string list ref
val config : int option ref
val set_config_exn : int -> unit
val get_config_or_default : default:int -> int
