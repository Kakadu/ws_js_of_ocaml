open Js_of_ocaml

(* On server-side we can use pure OCaml with
  https://github.com/vbmithr/ocaml-websocket
  and abandone nodeJS
*)

(*
type app

class type server = object
  method listen: int -> (unit -> unit) -> unit Js.meth
end
class type http = object
  method createServer: app -> server Js.t Js.meth

end
class type io = object
  method on : Js.js_string -> ('a -> unit) -> unit Js.meth
end

(* let http : http Js.t = Js.Unsafe.js_expr "require('http')" *)
(* let express: unit -> app  = Js.Unsafe.js_expr "require('express')" *)
(* let io : server -> 'io = Js.Unsafe.js_expr "require('socket.io')" *)
(*
let () =
  let port = 6666 in
  let app = express () in
  let server = http##createServer app in
  server##listen port (fun () ->
    Firebug.console##log (Js.string @@ Printf.sprintf "Server listening at port %d"  port)
    ) *)

open Common_server
open Shared

module S = BsSocket.Server.Make(Shared.Messages)

let __ () =
  let app =
    (* let e = Express.create () in *)
    Express.app ()
  in
  let server = S.create_with_http(app) in
  S.on_connect server (fun socket ->
    S.Socket.on socket (function
      | Messages.Ping -> ()
      | Pong -> ()
    )
  );
  let port = 6666 in
  Http.listen (S.server server) 6666 (fun () ->
    printf "Server started at port %d" port
    )




let __ _ =
  let express : unit -> _ = Js.Unsafe.js_expr "require('express')" in
  let _app = express () in

  (* let _server : Common_server.server Js.t = Js.Unsafe.eval_s {| require('http').createServer(app); |} in *)
  let _server : Common_server.server Js.t = Common_server.http##createServer _app in
  (* let _server : Common_server.server Js.t = Common_server.http##createServer _app in
  let socket_io : Common_server.server Js.t -> Common_server.io Js.t =
    Js.Unsafe.js_expr {| require('socket.io') |} in
  let _io  = socket_io _server in *)
  let _io  =
    let open Js.Unsafe in
    fun_call (Js.Unsafe.js_expr "require('socket.io')") [| inject _server |]
  in

  (* let _ = Js.Unsafe.js_expr {| server.listen(port, () => {
      // console.log('Server listening at port %d', 6666);
    });
   |}
  in *)
  (* Firebug.console##log socket_io; *)
  Firebug.console##log _io;
  let port = 6666 in
  _server##listen port  (fun () ->
    printf "Server started at port %d" port
    );
  (* let _ = Js.Unsafe.js_expr ({|
    const express = require('express');
    const app = express();
    const server = require('http').createServer(app);
    const io = require('socket.io')(server);

    server.listen(port, () => {
      console.log('Server listening at port %d', 6666);
    });

  |})
  in *)
  ()
*)

let _ =
  Js.Unsafe.eval_string
    {|

      'use strict';

      const express = require('express');
      const path = require('path');
      const { createServer } = require('http');

      //const WebSocket = require('../../');
      const WebSocket = require('ws');

      const app = express();
      //app.use(express.static(path.join(__dirname, '../../../server/public')));
      app.use(express.static(__dirname));

      const server = createServer(app);
      const wss = new WebSocket.Server({ server });

      wss.on('connection', function (ws) {
        console.log('connection');
        const id = setInterval(function () {
          ws.send(JSON.stringify(process.memoryUsage()), function () {
            //
            // Ignore errors.
            //
          });
        }, 100);
        console.log('started client interval');

        ws.on('close', function () {
          console.log('stopping client interval');
          clearInterval(id);
        });
      });

      server.listen(8080, function () {
        console.log('Listening on http://localhost:8080');
      });


    |}
