import Player from './player'
import { setupCanvas } from './utils/'
import Fly from './fly'

// import {MotionBlurFilter} from '@pixi/filter-motion-blur';
import { BloomFilter } from '@pixi/filter-bloom'
import { OutlineFilter } from '@pixi/filter-outline'
import { CRTFilter } from '@pixi/filter-crt'

import Explosion from './explosion'
import Debug from './debug'
import Text from './text'

var Viewport = require('pixi-viewport')

export class Game {
  constructor (props = {}) {
    this.props = props
    this.display = undefined
    this.engine = undefined
    this.loaded = false

    window.__game = this

    this.state = {
      camera: {
        x: 5,
        y: 5
      }
    }

    this.players = []

    this.gameObjects = []

    this.app = new PIXI.Application({
      width: window.innerWidth,
      height: window.innerHeight
    })
    setupCanvas(this.app)
    this.app.renderer.backgroundColor = 0x69243e

    this.app.renderer.autoResize = true

    this.viewport = new Viewport({
      screenWidth: window.innerWidth,
      screenHeight: window.innerHeight,
      worldWidth: 3000,
      worldHeight: 1000,
      interaction: this.app.renderer.interaction, // the interaction module is important for wheel() to work properly when renderer.view is placed or scaled,
      x: 1500
    })

    this.viewport.on('clicked', event => {
      const { x, y } = event.world
      window.stab()
    })

    this.viewport.fit()

    this.viewport
      .wheel({ percent: 0.03 })
      .clamp({
        left: 0,
        right: 3000,
        bottom: 400,
        top: -150
      })
      // .zoomPercent(1.5)
      .decelerate()

    this.viewport.position.set(1500, 200)

    this.viewport.emit(new Event('moved-end', {}))

    this.viewport.filters = []

    this.app.stage.addChild(this.viewport)

    PIXI.loader
      .add('/images/spritesheet.json')
      .load(this.spritesLoaded.bind(this))
  }

  playerIsHit (payload) {
    const { damage, id } = payload

    const player = this.players.find(player => {
      return player.id == id
    })

    this.createExplosion({
      x: player.x,
      y: player.y
    })
    player && player.takeDamage(damage)
  }

  createExplosion (position) {
    const explosion = new Explosion(position)
    this.viewport.addChild(explosion)
    this.gameObjects.push(explosion)
  }

  playerStabs (id) {
    const player = this.players.find(player => {
      return player.id == id
    })

    player && player.stab(this.players)
  }

  playerRotates (id, currentRotation) {
    const player = this.players.find(player => {
      return player.id == id
    })

    player && player.rotateSword(currentRotation)
  }

  setLocalPlayer (id) {
    const player = this.players.find(player => {
      return player.id == id
    })
    if (!player) {
      setTimeout(this.setLocalPlayer.bind(this, id), 5)
      return
    }
    this.setPlayerFilters()

    this.viewport.follow(player, { speed: 60 })
    this.viewport.fit(player, 500, 500)
    player.filters = [new OutlineFilter(3, 0x101010)]

    player.localPlayer = true
  }

  setPlayerFilters () {
    this.players.forEach(_player => {
      !_player.localPlayer &&
        (_player.filters = [new OutlineFilter(3, 0xbb2222)])
    })
  }

  spritesLoaded (obj) {
    const floor = new PIXI.extras.TilingSprite(
      PIXI.Texture.fromImage('earthen_floor.png'),
      5000,
      100
    )

    const bg = new PIXI.extras.TilingSprite(
      PIXI.Texture.fromImage('bg.png'),
      5000,
      600
    )

    bg.y = -200
    this.viewport.addChild(bg)

    for (let i = 0; i < 10; i++) {
      const cloud = new PIXI.Sprite(PIXI.Texture.fromImage('cloud.png'))

      const x = Math.floor(Math.random() * 3000)
      const y = Math.floor(Math.random() * 150) - 100
      cloud.x = x
      cloud.y = y
      this.viewport.addChild(cloud)
    }

    floor.filters = [new OutlineFilter(3, 0x101010)]

    let rectangle = new PIXI.Graphics()
    // rectangle.beginFill(0x66CC00);
    rectangle.beginFill(0x303030)
    rectangle.drawRect(0, 300, 5000, window.innerHeight)
    rectangle.endFill()
    this.viewport.addChild(rectangle)

    floor.y = 200

    this.viewport.addChild(floor)
    this.loaded = true

    const messageone = new Text({
      message: 'Hello & Welcome',
      duration: 1000
    })
    const messagetwo =
      'WASD to move\nLeft click stab\nRight click rotate\nctrl-right lcick counter rotate'
    setTimeout(() => {
      this.app.stage.addChild(messageone)
      this.gameObjects.push(messageone)
    }, 1000)
    setTimeout(() => {
      this.app.stage.addChild(messagetwo)
      this.gameObjects.push(messagetwo)
    }, 2000)

    // this.viewport.addChild(messageone)

    requestAnimationFrame(this.animate.bind(this))
  }

  animate () {
    // this.explosion.update()
    this.gameObjects.forEach((gameObject, index) => {
      gameObject.update()
      if (gameObject.children.length === 0) {
        this.gameObjects.splice(index, 1)
      }
    })
    requestAnimationFrame(this.animate.bind(this))
  }

  addPlayer (obj) {
    if (!this.loaded) {
      setTimeout(this.addPlayer.bind(this, obj), 1)
      return
    }

    const alreadyThere = this.players.find(player => {
      return player.id == obj.socket_id
    })
    if (alreadyThere) {
      return
    }

    const player = new Fly({ ...obj, id: obj.socket_id })

    this.players.push(player)
    this.drawPlayer(player)
    this.setPlayerFilters()
  }
  updatePlayer (obj) {
    const { id, x, y, hp } = obj
    let player = this.players.find(player => player.id == id)
    // console.log(obj)
    // player.x = x
    // player.y = y
    // player.hp = hp
    player.updateVariables(obj)
  }

  removePlayerById (id) {
    const playerIndex = this.players.findIndex(player => player.id == id)
    const player = this.players[playerIndex]
    this.viewport.removeChild(player)
    this.players.splice(playerIndex, 1)
  }

  drawPlayer (player) {
    this.viewport.addChild(player)
  }

  debugShape (obj) {
    const { shape } = obj
    switch (shape) {
      case 'circle':
        break
      case 'rectangle':
        const debug = new Debug(obj)
        this.viewport.addChild(debug)
        this.gameObjects.push(debug)
        break
      default:
        throw `Woops: unreqcognized shape ${shape}`
    }
  }
}
