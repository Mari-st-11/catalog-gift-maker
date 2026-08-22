import { Controller } from "@hotwired/stimulus"
import { createIcons, icons } from "lucide"

// data-lucide="xxx" が付いた要素をLucideのSVGアイコンに描画する。
// Turbo Driveのページ遷移でもStimulusのconnect()は毎回呼ばれるため、window.onloadより確実。
export default class extends Controller {
  connect() {
    createIcons({ icons })
  }
}
