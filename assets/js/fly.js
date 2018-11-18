import Player from "./player";

export default class Fly extends Player {
  constructor(props) {
    super(props);
    this.x = props.x;
    this.y = props.y;
    this.id = props.id;

    let textureArray = [];
    for (let i = 1; i < 4; i++) {
      let texture = PIXI.Texture.fromImage("fly_" + i +".png");
      textureArray.push(texture);
    }
    let mc = new PIXI.extras.AnimatedSprite(textureArray);
    mc.anchor.x = .5
    mc.anchor.y = .5
    mc.play()
    mc.animationSpeed = .1
    this.addChild(mc)
    window.last_added_fly = this
  }
}
