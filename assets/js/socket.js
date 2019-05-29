import { Socket } from 'phoenix'
import { Game } from './game'

const keypresses = {
  a: false,
  d: false,
  w: false,
  s: false
}

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

  channel = socket.channel('room:game', {
    nickname
  })

  setupGameChannel(channel)

  console.log(this.parentNode.parentNode.removeChild(this.parentNode))
}

const setupGameChannel = channel => {
  channel.on('shout', function (payload) {
    // listen to the 'shout' event
    var li = document.createElement('li') // creaet new list item DOM element
    var { name, message } = payload // get name from payload or set default
    li.innerHTML = '<b>' + name + '</b>: ' + message // set li contents
    ul.appendChild(li) // append to list
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
    // game.debugShape({ ...payload.stab_hitbox, shape: 'rectangle' })
  })

  channel.on('disconnect', function (payload) {
    console.log('disconnect', payload)
    game.removePlayerById(payload.socket_id)
  })

  channel.on('debug shape', function (payload) {
    game.debugShape(payload)
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

    // event.preventDefault()
    // event.stopPropagation()
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

    // event.preventDefault()
    // event.stopPropagation()
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

    // event.preventDefault()
    // event.stopPropagation()
  })

  document.oncontextmenu = event => {
    event.preventDefault()
    event.stopPropagation()
  }

  setInterval(() => {
    channel.push('move', {
      moving: {
        left: keypresses["a"],
        right: keypresses["d"],
        up: keypresses["w"],
        down: keypresses["s"]
      }
    })

  }, 25)
  window.onblur = function () {
    game.blurred = true
    Object.keys(keypresses).forEach(key => {
      if (keypresses[key]) {
        let direction
        switch (key) {
          case 'd':
            direction = 'right'
            break
          case 'a':
            direction = 'left'
            break
          case 'w':
            direction = 'up'
            break
          case 's':
            direction = 'down'
            break
        }

        channel.push('move', {
          down: false,
          direction
        })

        keypresses[key] = false
      }
    })
  }
}

/* End Add */

socket.connect()

export default socket
