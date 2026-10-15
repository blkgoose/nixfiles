// Make Jellyfin Web usable with the projector's d-pad, which only moves a mouse cursor:
// force the TV layout, put a transparent overlay over the page that swallows all mouse input, turn every cursor
// movement into an arrow key press, and turn OK (mouse button) into a click on the focused element.
// The cursor stops at the screen edges (no events there) and nothing from JS can move it back.
(function () {
  try {
    localStorage.setItem('layout', 'tv');
  } catch (e) {}

  var KEYS = {
    left: { key: 'ArrowLeft', code: 'ArrowLeft', keyCode: 37 },
    up: { key: 'ArrowUp', code: 'ArrowUp', keyCode: 38 },
    right: { key: 'ArrowRight', code: 'ArrowRight', keyCode: 39 },
    down: { key: 'ArrowDown', code: 'ArrowDown', keyCode: 40 }
  };

  function press(k) {
    var target = document.activeElement || document.body;
    ['keydown', 'keyup'].forEach(function (type) {
      var e = new KeyboardEvent(type, { key: k.key, code: k.code, bubbles: true, cancelable: true });
      Object.defineProperty(e, 'keyCode', { get: function () { return k.keyCode; } });
      Object.defineProperty(e, 'which', { get: function () { return k.keyCode; } });
      target.dispatchEvent(e);
    });
  }

  function install() {
    var style = document.createElement('style');
    style.textContent = 'html, body, * { cursor: none !important; }';
    document.head.appendChild(style);

    var overlay = document.createElement('div');
    overlay.style.cssText = 'position:fixed;left:0;top:0;right:0;bottom:0;z-index:2147483647;background:transparent;cursor:none';
    document.body.appendChild(overlay);

    overlay.addEventListener('mousemove', function (e) {
      e.stopPropagation();
      var dx = e.movementX || 0;
      var dy = e.movementY || 0;
      if (!dx && !dy) return;
      press(Math.abs(dx) >= Math.abs(dy) ? (dx < 0 ? KEYS.left : KEYS.right) : (dy < 0 ? KEYS.up : KEYS.down));
    });

    overlay.addEventListener('mousedown', function (e) {
      e.preventDefault();
      e.stopPropagation();
      var el = document.activeElement;
      if (el && el !== document.body) el.click();
    });

    ['mouseup', 'click', 'contextmenu', 'dblclick', 'wheel'].forEach(function (type) {
      overlay.addEventListener(type, function (e) {
        e.preventDefault();
        e.stopPropagation();
      });
    });
  }

  if (document.body) install();
  else window.addEventListener('DOMContentLoaded', install);
})();
