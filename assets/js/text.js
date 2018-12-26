export default class Text extends PIXI.Container {
  constructor (props) {
    super(props)
    this.props = props
    const { x, y, width, height } = props

    this.spawnTime = new Date()
    this.duration = props.duration || 500

    this.message = new PIXI.Text(props.message)
    this.addChild(this.message)
  }

  update () {
    const percentDone = (new Date() - this.spawnTime) / 100

    if (this.props.fade) {
      this.alpha = 1 / percentDone
    }

    if (new Date() - this.spawnTime >= this.duration) {
      this.removeChild(this.message)
    }
  }
}
