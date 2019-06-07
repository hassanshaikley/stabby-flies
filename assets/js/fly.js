import Player from './player'
import { GlowFilter } from 'pixi-filters'

export default class Fly extends Player {
  constructor(props) {
    super(props)
    this.x = props.x
    this.y = props.y
    this.serverX = props.x
    this.serverY = props.y
    this.socket_id = props.socket_id
    this.hp = props.hp
    this.maxHp = props.max_hp
    this.name = props.name
    this.nickname = props.nickname
    this.speed = props.speed
    this.kill_count = props.kill_count

    let textureArray = []
    for (let i = 1; i < 4; i++) {
      let texture = PIXI.Texture.from('fly_' + i + '.png')
      textureArray.push(texture)
    }
    this.fly_animation = new PIXI.AnimatedSprite(textureArray)

    this.shield = new PIXI.Sprite(PIXI.Texture.from('images/shield.png'))
    this.sword = new PIXI.Sprite(PIXI.Texture.from('images/sword.png'))

    this.shield.x -= 5
    this.shield.y -= 2
    this.sword.anchor.y = 0.62
    this.sword.anchor.x = 0.5
    window.sword = this.sword
    this.sword.rotation = props.sword_rotation

    this.sword.x -= 15
    this.sword.y += 5

    this.fly_animation.anchor.x = this.fly_animation.anchor.y = 0.5
    this.fly_animation.play()
    this.fly_animation.animationSpeed = 0.1
    this.addChild(this.fly_animation)
    this.addChild(this.shield)
    this.addChild(this.sword)

    this.healthBar = new PIXI.Container()

    this.healthRed = new PIXI.Graphics()
    this.healthRed.beginFill(0xff0000)
    this.healthRed.drawRect(-25, -35, 50, 5)
    this.healthRed.endFill()

    this.healthGreen = new PIXI.Graphics()
    this.healthGreen.beginFill(0x00ff00)
    this.healthGreen.drawRect(-25, -35, 50, 5)
    this.healthGreen.endFill()

    // rectangle.anchor.x = 0.5
    this.healthBar.addChild(this.healthRed)
    this.healthBar.addChild(this.healthGreen)
    this.addChild(this.healthBar)
    this.updateHealthBar()

    var nameStyle = {
      font: 'monospace',
      fill: '#ffffff',
      stroke: '#000000',
      align: 'center',
      fontSize: 16,
      strokeThickness: 1
    }
    this.nameText = new PIXI.Text(this.nickname, nameStyle)
    this.nameText.x -= this.nameText.width / 2
    this.nameText.y -= 55
    this.addChild(this.nameText)


    var shoutTextStyle = {
      font: 'monospace',
      fontSize: 12,
      fill: '#ffffff',
      align: 'center'
    }

    this.shoutText = new PIXI.Text("", shoutTextStyle)
    this.shoutText.x = - this.shoutText.width / 2
    this.shoutText.y -= 65
    this.addChild(this.shoutText)

    this.__DEBUG__updateSwordHitbox()

    window.last_added_fly = this
  }

  __DEBUG__updateSwordHitbox() {
    const x = Math.sin(this.sword.rotation) * 50
    const y = -Math.cos(this.sword.rotation) * 55
  }

  rotateSword(newRotation) {
    if (this.stabbing) return
    this.sword.rotation = newRotation
    this.__DEBUG__updateSwordHitbox()
  }

  shout(message) {
    console.log("Shouting ", message)

    this.shoutText.text = message;
    this.shoutText.x = - this.shoutText.width / 2


    this.resetShoutTimer()
  }

  resetShoutTimer() {
    if (this.shoutTimer) {
      clearTimeout(this.shoutTimer)
    }

    this.shoutTimer = setTimeout(() => {
      this.shoutText.text = ""
      this.shoutText.x = - this.shoutText.width / 2

    }, 5000)

  }

  updateVariables(obj, viewport) {
    if (this.localPlayer && this.hp < obj.hp && obj.hp === this.maxHp) {
      viewport.moveCenter(obj.x, obj.y)
    }
    this.serverX = obj.x
    this.serverY = obj.y
    this.hp = obj.hp
    this.speed = obj.speed

    this.kill_count = obj.kill_count
    this.rotateSword(obj.sword_rotation)
    this.updateHealthBar()

    // I guess this is good if it ever gets super laggy
    if (Math.abs(Math.abs(this.serverX) - Math.abs(this.x)) > 200) {
      this.x = this.serverX
      this.y = this.serverY
    }
  }

  wearCrown() {
    let crownTextureArray = []
    for (let i = 0; i < 3; i++) {
      let crownTexture = PIXI.Texture.from('images/fly_crown' + i + '.png')
      crownTextureArray.push(crownTexture)
    }
    this.crown = new PIXI.AnimatedSprite(crownTextureArray)

    this.crown.anchor.x = this.crown.anchor.y = 0.5
    this.crown.animationSpeed = 0.1
    this.crown.play()
    this.crown._currentTime = this.fly_animation._currentTime

    this.removeChild(this.sword)
    this.addChild(this.crown)
    this.addChild(this.sword)
  }
  removeCrown() {
    this.removeChild(this.crown)
  }

  prediction(speed) {
    let ySpeed = 0;
    let xSpeed = 0;
    if (window.keypresses.w) {
      ySpeed -= speed
    }
    if (window.keypresses.s) {
      ySpeed += speed
    }
    if (window.keypresses.a) {
      xSpeed -= speed;
    }
    if (window.keypresses.d) {
      xSpeed += speed;
    }

    this.x += xSpeed;
    this.y += ySpeed;
  }
  update() {
    const { localPlayer, lastMovementUpdateTime, serverY, serverX } = this;
    const now = new Date().getTime()

    const delta = now - (lastMovementUpdateTime || now)
    const speed = this.speed / delta / 1.93

    let predict = (this.x == this.serverX) && (this.y == this.serverY);

    if (this.y > serverY) {
      this.y -= speed
      predict = false
      if (this.y < serverY && !window.keypresses.s) {
        this.y = serverY
      }
    } else if (this.y < serverY) {
      predict = false
      this.y += speed
      if (this.y > serverY && !window.keypresses.w) {
        this.y = serverY
      }
    }

    if (this.x > serverX) {
      predict = false

      this.x -= speed
      if (this.x < serverX && !window.keypresses.a) {
        this.x = serverX
      }
    } else if (this.x < serverX) {
      predict = false

      this.x += speed
      if (this.x > serverX && !window.keypresses.d) {
        this.x = serverX
      }
    }

    predict && this.localPlayer && this.prediction(speed)
    this.lastMovementUpdateTime = new Date().getTime()
  }

  updateHealthBar() {
    this.healthGreen.width = 50 * (this.hp / this.maxHp)
  }

  takeDamage(amt) {
    this.hp -= amt
    this.updateHealthBar()
  }

  stab(players) {
    if (this.stabbing) return
    this.stabbing = true

    const prevx = this.sword.x
    const prevy = this.sword.y

    const x = Math.sin(this.sword.rotation) * 20
    const y = -Math.cos(this.sword.rotation) * 20

    this.sword.y += y
    this.sword.x += x

    const swordBounds = this.sword.getBounds()

    this.sword.filters = [new GlowFilter()]

    setTimeout(() => {
      this.stabbing = false
      this.sword.y = prevy
      this.sword.x = prevx
      this.sword.filters = []
    }, 200)
  }
}
