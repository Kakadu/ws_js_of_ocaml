open Js_of_ocaml
open Libserver

(* On server-side we can use pure OCaml with
  https://github.com/vbmithr/ocaml-websocket
  and abandone nodeJS
*)

let () =
  let _path = Js.Unsafe.js_expr "require('path')" in
  let http : http Js.t = Js.Unsafe.js_expr "require('http')" in
  let webSocket = Js.Unsafe.js_expr "require('ws')" in
  let app =
    let e = Express.create () in
    let app = Express.app e in
    app##use (Express.static e (__dirname ())) |> ignore ;
    app in
  let server : server Js.t = http##createServer app in
  let wss : socket Js.t =
    let hack : (_ -> _ Js.t) Js.constr = webSocket##._Server in
    new%js hack (Js.Unsafe.obj [|("server", Js.Unsafe.inject server)|]) in
  Firebug.console##log wss ;
  wss##on (Js.string "connection") (fun (ws : socket Js.t) ->
      Firebug.console##log (Js.string "connection") ;
      let id =
        Timers.set_interval ~timeout:100 (fun () ->
            let info = process##memoryUsage () in
            (* Firebug.console##log info ; *)
            ws##send (Json.output info) (fun () -> ()) ) in
      Firebug.console##log (Js.string "started client interval") ;
      wss##on (Js.string "connection") (fun () ->
          Firebug.console##log (Js.string "stopping client interval") ;
          Timers.clear_interval id ) )
  |> ignore ;
  server##listen 8080 (fun () ->
      Firebug.console##log (Js.string "Listening for port 8080") )

let __original _ =
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
        console.log(id);

        ws.on('close', function () {
          console.log('stopping client interval');
          clearInterval(id);
        });
      });

      server.listen(8080, function () {
        console.log('Listening on http://localhost:8080');
      });


    |}
