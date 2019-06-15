import { Socket } from 'phoenix'
import { Game } from './game'

window.keypresses = {
  KeyA: false,
  KeyD: false,
  KeyW: false,
  KeyS: false,
  ArrowLeft: false,
  ArrowRight: false,
  ArrowUp: false,
  ArrowDown: false
}
window.last_keypresses = JSON.parse(JSON.stringify(window.keypresses))


let game = new Game()

const socketUrl =
  window.location.host.split('.')[2] === 'hwcdn'
    ? '//meaty-spiffy-hermitcrab.gigalixirapp.com/socket'
    : '/socket'
let socket = new Socket(socketUrl, { params: { token: window.userToken } })

window.pooh = Socket
/* Begin Add */

// window.joinGame = function (event) {
//   console.log('join game fren')
//   event.preventDefault()
//   event.stopPropagation()
// }
let channel
document.getElementById('join-game-form').onsubmit = function (event) {
  event.preventDefault()
  event.stopPropagation()

  const nickname = document.getElementById('nickname-form').value

  channel = socket.channel('game', {
    nickname
  })

  setupGameChannel(channel)

  this.parentNode.parentNode.removeChild(this.parentNode)
}

const setupGameChannel = channel => {
  channel.on('shout', function (payload) {
    // listen to the 'shout' event
    var { socket_id, message } = payload // get name from payload or set default
    game.playerShouts(socket_id, message)

  })

  channel.on('connect', function (payload) {
    console.log('connect', payload)
    const { players, new_player } = payload // New Player is me : )
    // listen to the 'shout' event
    var li = document.createElement('li') // creaet new list item DOM element
    var name = payload.name || 'guest' // get name from payload or set default

    // li.innerHTML = "<b> SOMEONE CONNECTED</b>"; // set li contents
    // ul.appendChild(li); // append to list
    // console.log(players)
    players.forEach(player => {
      game.addPlayer(player)
    })
  })

  channel.on('stab', function (payload) {
    const { socket_id, hit_players_data } = payload
    game.playerStabs(socket_id)
    hit_players_data.forEach(obj => {
      game.playerIsHit(obj)
    })
  })

  channel.on('explosion', function (playload) {
    game.createExplosion({
      x: playload.x,
      y: playload.y
    })
  })

  channel.on('disconnect', function (payload) {
    console.log('disconnect', payload)
    game.removePlayerById(payload.socket_id)
  })

  channel.on('debug shape', function (payload) {
    game.debugShape(payload)
  })

  channel.on('respawn', function (payload) {
    game.respawnPlayer(payload)
  })


  channel.on('initialize', function (payload) {
    console.log('Initialize ', payload)
    // listen to the 'shout' event
    const { new_player } = payload
    const local_player_id = new_player.socket_id
    game.setLocalPlayer(local_player_id)
  })

  channel.on('update_player', function (payload) {
    game.updatePlayer({ ...payload })
  })

  window.stab = obj => {
    // console.log('stabbing with ', obj)
    channel.push('stab', {})
  }

  window.rotate = obj => {
    const { amount } = obj
    channel.push('fly-rotate', {
      amount
    })
  }

  setupKeys(channel)

  channel.join() // join the channel.

  channel.push('connect', {
    // send the message to the server on "shout" channel
    // name: 'Admin',     // get value of "name" of person sending the message
    // message: 'Someone joined the server'    // get message text (value) from msg input field.
  })
}

const setupKeys = channel => {
  var ul = document.getElementById('msg-list') // list of messages.
  var msg = document.getElementById('msg') // message input field

  document.addEventListener('keydown', function (event) {
    if (document.activeElement.id == "msg") return;

    const down = true

    const { code } = event

    if (window.keypresses[code]) return
    window.keypresses[code] = true
    channel.push('move', {
      moving: {
        left: window.keypresses["KeyA"] || window.keypresses["ArrowLeft"],
        right: window.keypresses["KeyD"] || window.keypresses["ArrowRight"],
        up: window.keypresses["KeyW"] || window.keypresses["ArrowUp"],
        down: window.keypresses["KeyS"] || window.keypresses["ArrowDown"]
      }
    })
  })

  document.addEventListener('keyup', function (event) {
    if (document.activeElement.id == "msg") return;

    const down = false

    const { code } = event
    window.keypresses[code] = false

    channel.push('move', {
      moving: {
        left: window.keypresses["KeyA"] || window.keypresses["ArrowLeft"],
        right: window.keypresses["KeyD"] || window.keypresses["ArrowRight"],
        up: window.keypresses["KeyW"] || window.keypresses["ArrowUp"],
        down: window.keypresses["KeyS"] || window.keypresses["ArrowDown"]
      }
    })

  })

  // "listen" for the [Enter] window.keypress event to send a message:
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
          msg.blur()
          msg.style.opacity = .1
        } else {
          if (document.activeElement.id == "msg") {
            msg.blur()
            msg.style.opacity = .1
          } else {
            msg.focus()
            msg.style.opacity = .9
          }



        }

        break
    }
  })

  document.oncontextmenu = event => {
    event.preventDefault()
    event.stopPropagation()
  }

  setInterval(() => {
    const refresh = window.last_keypresses.a != window.keypresses.a || window.last_keypresses.d != window.keypresses.d || window.last_keypresses.w != window.keypresses.w || window.last_keypresses.s != window.keypresses.s

    if (refresh) {
      channel.push('move', {
        moving: {
          left: window.keypresses["KeyA"] || window.keypresses["ArrowLeft"],
          right: window.keypresses["KeyD"] || window.keypresses["ArrowRight"],
          up: window.keypresses["KeyW"] || window.keypresses["ArrowUp"],
          down: window.keypresses["KeyS"] || window.keypresses["ArrowUp"]
        }
      })
    }
    window.last_keypresses = JSON.parse(JSON.stringify(window.keypresses))


  }, 500)
  window.onblur = function () {
    game.blurred = true

    // channel.push('move', {
    //   moving: {
    //     left: false,
    //     right: false,
    //     up: false,
    //     down: false
    //   }
    // })

    Object.keys(window.keypresses).forEach(code => {
      if (window.keypresses[code]) {
        let direction
        switch (code) {
          case 'KeyD':
          case 'ArrowLeft':
            direction = 'right'
            break
          case 'KeyA':
          case 'ArrowRight':

            direction = 'left'
            break
          case 'KeyW':
          case 'ArrowUp':

            direction = 'up'
            break
          case 'KeyS':
          case 'ArrowDown':

            direction = 'down'
            break
        }

        channel.push('move', {
          down: false,
          direction
        })

        window.keypresses[code] = false
      }
    })
  }
}

/* End Add */

socket.connect()

export default socket
