open Js_of_ocaml
open Libserver

(* On server-side we can use pure OCaml with
  https://github.com/vbmithr/ocaml-websocket
  and abandone nodeJS
*)

class type ['a] js_set =
  object
    method forEach : ('a -> unit) -> unit Js.meth
  end

let () =
  let _path = Js.Unsafe.js_expr "require('path')" in
  let http : http Js.t = Js.Unsafe.js_expr "require('http')" in
  let webSocket = Js.Unsafe.js_expr "require('ws')" in
  let app =
    let e = Express.create () in
    let app = Express.app e in
    app##use (Express.static e (__dirname ()));
    app in
  let server : server Js.t = http##createServer app in
  let wss : socket Js.t =
    let hack : (_ -> _ Js.t) Js.constr = webSocket##._Server in
    new%js hack (Js.Unsafe.obj [|("server", Js.Unsafe.inject server)|]) in
  (* Firebug.console##log wss; *)
  wss##on (Js.string "connection") (fun (ws : socket Js.t) ->
      (* Firebug.console##log (Js.string "connection"); *)
      ws##on (Js.string "message") (fun _data ->
          (* Firebug.console##log (Js.string "got message"); *)
          (* Firebug.console##log wss##.clients; *)
          let clients : 'a js_set Js.t = wss##.clients in
          clients##forEach (fun client ->
              Firebug.console##log client;
              if client##.readyState = WebSockets.OPEN then
                (* Firebug.console##log (Js.string "sending something"); *)
                client##send _data () ) ) )
  |> ignore;
  server##listen 8080 (fun () ->
      Firebug.console##log (Js.string "Listening for port 8080") )

let __oriinal _ =
  Js.Unsafe.eval_string
    {|

      'use strict';

      const express = require('express');
      const path = require('path');
      const { createServer } = require('http');

      //const WebSocket = require('../../');
      const WebSocket = require('ws');

      const app = express();
      app.use(express.static(__dirname));
      //app.use(express.static(path.join(__dirname, '../../../server/public')));


      const server = createServer(app);
      const wss = new WebSocket.Server({ server });

      wss.on('connection', (ws) => {

        // runs a callback on message event
        ws.on('message', (data) => {

          // sends the data to all connected clients
          wss.clients.forEach((client) => {
              if (client.readyState === WebSocket.OPEN) {
                client.send(data);
              }
          });
        });
      });

      server.listen(8080, function () {
        console.log('Listening on http://localhost:8080');
      });


    |}
