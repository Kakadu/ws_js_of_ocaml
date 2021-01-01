open Js_of_ocaml

let () =
  let rss = Dom_html.getElementById "rss" in
  let heapTotal = Dom_html.getElementById "heapTotal" in
  let heapUsed = Dom_html.getElementById "heapUsed" in
  let external_ = Dom_html.getElementById "external" in
  let host = Dom_html.window##.location##.host in
  let url = (Js.string "ws://")##concat host in
  (* Firebug.console##log url ; *)
  let ws = new%js WebSockets.webSocket url in
  ws##.onmessage := Dom.no_handler ;
  ws##.onmessage :=
    Dom.handler (fun event ->
        let data = Json.unsafe_input event##.data in
        rss##.textContent := data##.rss ;
        heapTotal##.textContent := data##.heapTotal ;
        heapUsed##.textContent := data##.heapUsed ;
        external_##.textContent := data##.external_ ;
        Js._true ) ;
  ()

(*
let _ =
  Js.Unsafe.eval_string
    {|
      (function() {
        const rss = document.getElementById('rss');
        const heapTotal = document.getElementById('heapTotal');
        const heapUsed = document.getElementById('heapUsed');
        const external = document.getElementById('external');
        const ws = new WebSocket(`ws://${location.host}`);

        ws.onmessage = function(event) {
          const data = JSON.parse(event.data);

          rss.textContent = data.rss;
          heapTotal.textContent = data.heapTotal;
          heapUsed.textContent = data.heapUsed;
          external.textContent = data.external;
        };
      })();
    |} *)
