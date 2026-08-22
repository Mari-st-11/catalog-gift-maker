import { Controller } from "@hotwired/stimulus"

// 横スクロールカルーセルの、現在位置に応じたドットインジケーター同期
export default class extends Controller {
  static targets = ["scroller", "dot"]

  connect() {
    this.scrollerTarget.addEventListener("scroll", this.updateDots.bind(this))
  }

  updateDots() {
    const cards = this.scrollerTarget.children
    if (cards.length < 2) return

    const cardWidth = cards[1].offsetLeft - cards[0].offsetLeft
    const index = Math.round(this.scrollerTarget.scrollLeft / cardWidth)

    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("bg-gold", i === index)
      dot.classList.toggle("bg-ash-border", i !== index)
    })
  }
}
