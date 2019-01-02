import Player from './player'
import { GlowFilter } from 'pixi-filters'

export default class Fly extends Player {
  constructor (props) {
    super(props)
    this.x = props.x
    this.y = props.y
    this.serverX = props.x
    this.serverY = props.y
    this.id = props.id
    this.hp = props.hp
    this.maxHp = props.maxHp
    this.name = props.name
    this.speed = props.speed

    let textureArray = []
    for (let i = 1; i < 4; i++) {
      let texture = PIXI.Texture.fromImage('fly_' + i + '.png')
      textureArray.push(texture)
    }
    let mc = new PIXI.extras.AnimatedSprite(textureArray)

    this.shield = new PIXI.Sprite(PIXI.Texture.fromImage('images/shield.png'))
    this.sword = new PIXI.Sprite(PIXI.Texture.fromImage('images/sword.png'))

    this.shield.x -= 5
    this.shield.y -= 2
    this.sword.anchor.y = 0.62
    this.sword.anchor.x = 0.5
    window.sword = this.sword
    this.sword.rotation = props.sword_rotation

    this.sword.x -= 15
    this.sword.y += 5

    mc.anchor.x = mc.anchor.y = 0.5
    mc.play()
    mc.animationSpeed = 0.1
    this.addChild(mc)
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
      font: '10px monospace',
      fill: '#ffffff',
      stroke: '#000000',
      align: 'center',
      strokeThickness: 1
    }
    this.nameText = new PIXI.Text(this.name, nameStyle)
    this.nameText.x -= this.nameText.width / 2
    this.nameText.y -= 55
    this.addChild(this.nameText)
    // this.swordHitBox = new PIXI.Graphics()
    // this.swordHitBox.beginFill(0x888)
    // this.swordHitBox.drawRect(-17, 3, 5, 5)
    // this.swordHitBox.endFill()
    // this.addChild(this.swordHitBox)

    // this.swordHitBoxTwo = new PIXI.Graphics()
    // this.swordHitBoxTwo.beginFill(0x222)
    // this.swordHitBoxTwo.drawRect(0, 0, 5, 5)
    // this.swordHitBoxTwo.endFill()
    // this.addChild(this.swordHitBoxTwo)
    this.__DEBUG__updateSwordHitbox()

    window.last_added_fly = this
  }

  __DEBUG__updateSwordHitbox () {
    const x = Math.sin(this.sword.rotation) * 50
    const y = -Math.cos(this.sword.rotation) * 55
  }

  rotateSword (newRotation) {
    if (this.stabbing) return
    this.sword.rotation = newRotation
    this.__DEBUG__updateSwordHitbox()
  }

  updateVariables (obj, viewport) {
    if (this.localPlayer && this.hp < obj.hp && obj.hp === this.maxHp) {
      viewport.moveCenter(obj.x, obj.y)
    }
    this.serverX = obj.x
    this.serverY = obj.y
    this.hp = obj.hp
    this.rotateSword(obj.sword_rotation)
    this.updateHealthBar()

    if (Math.abs(Math.abs(this.serverX) - Math.abs(this.x)) > 100) {
      this.x = this.serverX
      this.y = this.serverY
    }
  }

  update () {
    const now = new Date().getTime()

    const delta = now - (this.lastMovementUpdateTime || now)

    const speed = this.speed / delta / 1.83

    // console.log(this.speed)

    // move 200 every second so
    // 200 / fps
    if (this.y > this.serverY) {
      this.y -= speed
      if (this.y < this.serverY) {
        this.y = this.serverY
      }
    } else if (this.y < this.serverY) {
      this.y += speed
      if (this.y > this.serverY) {
        this.y = this.serverY
      }
    }

    if (this.x > this.serverX) {
      // console.log(`delta: ${delta}, this.speed: ${this.speed}`)

      this.x -= speed
      if (this.x < this.serverX) {
        this.x = this.serverX
      }
    } else if (this.x < this.serverX) {
      this.x += speed
      if (this.x > this.serverX) {
        this.x = this.serverX
      }
    }

    this.lastMovementUpdateTime = new Date().getTime()
  }

  updateHealthBar () {
    this.healthGreen.width = 50 * (this.hp / this.maxHp)
  }

  takeDamage (amt) {
    // console.log(amt, this.hp, this.maxHp)
    this.hp -= amt
    this.updateHealthBar()

    // this.healthGreen.x = -25 + ((1 / 50) * (this.hp / this.maxHp)) / 2
    // this.healthGreen.x = (-25 * (this.hp / this.maxHp)) / 2
  }

  stab (players) {
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
