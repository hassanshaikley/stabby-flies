export default class Debug extends PIXI.Container {
  constructor (props) {
    super(props)
    this.props = props
    const { x, y, width, height } = props

    this.spawnTime = new Date()
    this.duration = 500

    this.debugRect = new PIXI.Graphics()
    this.debugRect.beginFill(0xff0000)
    this.debugRect.drawRect(x, y, width, height)
    this.debugRect.endFill()
    this.addChild(this.debugRect)
  }

  update () {
    const percentDone = (new Date() - this.spawnTime) / 100

    this.alpha = 1 / percentDone

    if (new Date() - this.spawnTime >= this.duration + 0.5) {
      this.removeChild(this.debugRect)
    }
  }
}
