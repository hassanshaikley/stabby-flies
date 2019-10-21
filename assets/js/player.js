export default class Player extends PIXI.Container {
  constructor(props) {
    super(props)

    this.localPlayer = false;
    this[props] = props
    window.woop = this
  }
}
