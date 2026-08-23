import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  select(event) {
    const name = event.currentTarget.dataset.tabsNameParam

    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.tabsNameParam === name
      tab.classList.toggle("bg-white", active)
      tab.classList.toggle("border-ash-border", active)
      tab.classList.toggle("text-ash-text", active)
      tab.classList.toggle("text-ash-sub", !active)
    })

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.tabsName !== name)
    })
  }
}
