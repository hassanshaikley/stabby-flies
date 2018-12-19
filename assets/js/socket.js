import { Socket } from "phoenix";
import { Game } from "./game";

const keypresses = {

}


let game = new Game();

let socket = new Socket("/socket", { params: { token: window.userToken } });

/* Begin Add */

var channel = socket.channel("room:game", {}); // connect to chat "room"

channel.on("shout", function(payload) {
  // listen to the 'shout' event
  var li = document.createElement("li"); // creaet new list item DOM element
  var { name, message } = payload; // get name from payload or set default
  li.innerHTML = "<b>" + name + "</b>: " + message; // set li contents
  ul.appendChild(li); // append to list
});

channel.on("connect", function(payload) {
  console.log("connect", payload)
  const {players, new_player} = payload // New Player is me : )
  // listen to the 'shout' event
  var li = document.createElement("li"); // creaet new list item DOM element
  var name = payload.name || "guest"; // get name from payload or set default

  // li.innerHTML = "<b> SOMEONE CONNECTED</b>"; // set li contents
  // ul.appendChild(li); // append to list
  // console.log(players)
  (players).forEach((player) => {
    game.addPlayer(player);
  })
});

channel.on("disconnect", function(payload) {
  console.log("disconnect", payload)
  game.removePlayerById(payload.id)
})

channel.join(); // join the channel.

var ul = document.getElementById("msg-list"); // list of messages.
var msg = document.getElementById("msg"); // message input field

// window.onbeforeunload = onPageClose;
// function onPageClose(){
//   channel.push("disconnect", {
//   });
// }

window.createExplosion = position => {
  channel.push('explosion', {
    position: position
  })
}

document.addEventListener('keydown', function (event) {
  const down = true

  const { key } = event
  if (keypresses[key]) return

  switch (key) {
    case 'd':
      keypresses['d'] = true
      channel.push('move', {
        direction: 'right',
        down
      })
      break
    case 'a':
      keypresses['a'] = true
      channel.push('move', {
        direction: 'left',
        down
      })
      break
    case 'w':
      keypresses['w'] = true
      channel.push('move', {
        direction: 'up',
        down
      })
      break
    case 's':
      keypresses['s'] = true
      channel.push('move', {
        direction: 'down',
        down
      })
      break
  }
})

document.addEventListener('keyup', function (event) {
  const down = false

  const { key } = event
  if (keypresses[key]) {
    keypresses[key] = false
  }

  switch (event.key) {
    case 'd':
      channel.push('move', {
        direction: 'right',
        down
      })
      break
    case 'a':
      channel.push('move', {
        direction: 'left',
        down
      })
      break
    case 'w':
      channel.push('move', {
        direction: 'up',
        down
      })
      break
    case 's':
      channel.push('move', {
        direction: 'down',
        down
      })
      break
  }
})

// "listen" for the [Enter] keypress event to send a message:
document.addEventListener('keypress', function (event) {
  switch (event.key) {
    case 'Enter':
      if (msg.value.length > 0) {
        // don't sent empty msg.
        channel.push('shout', {
          // send the message to the server on "shout" channel
          name: 'Guest', // get value of "name" of person sending the message
          message: msg.value // get message text (value) from msg input field.
        })
        msg.value = '' // reset the message input field for next message.
      }

      break
  }
})

// document.addEventListener("click", function(event) {
//   console.log(event)
//   if (event.type !== "click") {
//     return
//   }
//   const x = event.screenX
//   const y = event.screenY

// });

console.log('attempting connection')
channel.push('connect', {
  // send the message to the server on "shout" channel
  // name: 'Admin',     // get value of "name" of person sending the message
  // message: 'Someone joined the server'    // get message text (value) from msg input field.
})

channel.on('initialize', function (payload) {
  console.log('Initialize ', payload)
  // listen to the 'shout' event
  const { new_player } = payload
  const local_player_id = new_player.socket_id
  game.setLocalPlayer(local_player_id)
})

channel.on('update_player', function (payload) {
  console.log('update_player', payload)
  const { socket_id, x, y } = payload
  game.updatePlayer({
    id: socket_id,
    x,
    y
  })
})

/* End Add */

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect();

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })

export default socket;
