open Js_of_ocaml
open Js_of_ocaml_lwt

let () =
  let button = Dom_html.getElementById "send" in
  let host = Dom_html.window##.location##.host in
  let url = (Js.string "ws://")##concat host in
  (* Firebug.console##log url ; *)
  let conn = new%js WebSockets.webSocket url in
  conn##.onopen :=
    Dom.handler (fun _ ->
        Firebug.console##log (Js.string "WebSocket is open now.");
        Js._true );
  conn##.onclose :=
    Dom.handler (fun _ ->
        Firebug.console##log (Js.string "WebSocket is closed now.");
        Js._true );
  conn##.onerror :=
    Dom.handler (fun ev ->
        Firebug.console##log (Js.string "WebSocket error observed:", ev);
        Js._true );
  conn##.onmessage :=
    Dom.handler (fun event ->
        let chat = Dom_html.getElementById "chat" in
        chat##.innerHTML := chat##.innerHTML##concat event##.data;
        Js._true );
  let name : Dom_html.inputElement Js.t =
    Obj.magic @@ Dom_html.getElementById "name" in
  let message : Dom_html.inputElement Js.t =
    Obj.magic @@ Dom_html.getElementById "message" in
  Lwt_js_events.async (fun () ->
      Lwt_js_events.clicks button (fun _ev _ ->
          let data =
            (Js.string "<p>")##concat_4
              name##.value (Js.string ": ") message##.value (Js.string "</p>")
          in
          (* Firebug.console##log (Js.string "sending ", data); *)
          (* Send composed message to the server *)
          conn##send data;
          (* clear input fields name.value *)
          name##.value := Js.string "";
          message##.value := Js.string "";
          Lwt.return () ) )

let __ _original =
  Js.Unsafe.eval_string
    {|
      (function() {
        const connection = new WebSocket("ws://localhost:8080");
        const button = document.querySelector("#send");

        connection.onopen = (event) => {
            console.log("WebSocket is open now.");
        };

        connection.onclose = (event) => {
            console.log("WebSocket is closed now.");
        };

        connection.onerror = (event) => {
            console.error("WebSocket error observed:", event);
        };

        connection.onmessage = (event) => {
          // append received message from the server to the DOM element
          const chat = document.querySelector("#chat");
          chat.innerHTML += event.data;
        };

        button.addEventListener("click", () => {
          const name = document.querySelector("#name");
          const message = document.querySelector("#message");
          const data = `<p>${name.value}: ${message.value}</p>`;

          // Send composed message to the server
          console.log("sending " + data);
          connection.send(data);

          // clear input fields
          name.value = "";
          message.value = "";
        });
      })();
    |}
