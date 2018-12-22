import Player from './player'

export default class Fly extends Player {
  constructor (props) {
    super(props)
    this.x = props.x
    this.y = props.y
    this.id = props.id
    this.hp = props.hp
    this.maxHp = props.hp

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

    window.last_added_fly = this
  }

  rotateSword () {
    console.log(' iam doing an rotateSword fren')
    this.sword.rotation += window.ROTATION_VALUE
  }

  takeDamage (amt) {
    console.log(amt, this.hp, this.maxHp)
    this.hp -= amt
    this.healthGreen.width = 50 * (this.hp / this.maxHp)

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

    players.forEach(player => {
      console.log(player)
    })

    setTimeout(() => {
      this.stabbing = false
      this.sword.y = prevy
      this.sword.x = prevx
    }, 200)
  }
}
