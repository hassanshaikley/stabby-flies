import Player from './player'

export default class Fly extends Player {
  constructor (props) {
    super(props)
    this.x = props.x
    this.y = props.y
    this.id = props.id

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

    window.last_added_fly = this
  }

  rotateSword () {
    console.log(' iam doing an rotateSword fren')
    this.sword.rotation += window.ROTATION_VALUE
  }
}
