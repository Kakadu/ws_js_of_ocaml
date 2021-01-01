open Js_of_ocaml

(* TODO: invent right type here *)
type usable

class type app =
  object
    method use : usable Js.t -> unit Js.meth
  end

module Express = struct
  open Js.Unsafe

  type t

  let create () = Js.Unsafe.js_expr "require('express')"
  let app : t -> app Js.t = fun e -> fun_call (Js.Unsafe.inject e) [||]

  let static : t -> Js.js_string -> usable Js.t =
   fun e path -> meth_call (inject e) "static" [|inject path|]
end

class type socket =
  object
    method on : Js.js_string Js.t -> ('a -> unit) -> unit Js.meth

    method send : 'a -> (unit -> unit) -> unit Js.meth
  end

class type server =
  object
    method listen : int -> (unit -> unit) -> unit Js.meth
  end

class type http =
  object
    method createServer : app Js.t -> server Js.t Js.meth
  end

class type memoryUsage = object end

class type process =
  object
    method memoryUsage : unit -> memoryUsage Js.t Js.meth
  end

let __dirname () : Js.js_string = Js.Unsafe.eval_string "__dirname"
let process : process Js.t = Js.Unsafe.js_expr "process"

module Timers : sig
  type interval

  val set_interval : timeout:int -> (unit -> unit) -> interval
  val clear_interval : interval -> unit
end = struct
  (* https://nodejs.org/api/timers.html#timers_timers *)

  type interval

  let set_interval ~timeout f =
    let open Js.Unsafe in
    Js.Unsafe.fun_call
      (Js.Unsafe.js_expr "setInterval")
      [|Js.Unsafe.inject f; inject timeout|]

  let clear_interval : interval -> unit = Js.Unsafe.variable "clearInterval"
end
