export default class Text extends PIXI.Container {
  constructor (props) {
    super(props)
    this.props = props
    const { x, y, width, height } = props

    this.spawnTime = new Date()
    this.duration = props.duration || 500

    let message = new PIXI.Text(props.message)
    this.addChild(message)
  }

  update () {
    const percentDone = (new Date() - this.spawnTime) / 100

    this.alpha = 1 / percentDone

    if (new Date() - this.spawnTime >= this.duration + 0.5) {
      this.removeChild(this.debugRect)
    }
  }
}
