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

    let shield = new PIXI.Sprite(PIXI.Texture.fromImage('images/shield.png'))
    let sword = new PIXI.Sprite(PIXI.Texture.fromImage('images/sword.png'))

    shield.x -= 5
    shield.y -= 2

    sword.x -= 25
    sword.y -= 30

    mc.anchor.x = mc.anchor.y = 0.5
    mc.play()
    mc.animationSpeed = 0.1
    this.addChild(mc)
    this.addChild(shield)
    this.addChild(sword)

    window.last_added_fly = this
  }
}
